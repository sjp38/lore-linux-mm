Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 245986B0692
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:08:46 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l95-v6so4285158otl.17
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:08:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t23-v6si1361391ote.146.2018.05.11.12.08.44
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:08:44 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
Date: Fri, 11 May 2018 20:06:14 +0100
Message-Id: <20180511190641.23008-14-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

Add two new ioctls for VFIO containers. VFIO_IOMMU_BIND_PROCESS creates a
bond between a container and a process address space, identified by a
Process Address Space ID (PASID). Devices in the container append this
PASID to DMA transactions in order to access the process' address space.
The process page tables are shared with the IOMMU, and mechanisms such as
PCI ATS/PRI are used to handle faults. VFIO_IOMMU_UNBIND_PROCESS removes a
bond created with VFIO_IOMMU_BIND_PROCESS.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

---
v1->v2:
* Simplify mm_exit
* Can be built as module again
---
 drivers/vfio/vfio_iommu_type1.c | 449 ++++++++++++++++++++++++++++++--
 include/uapi/linux/vfio.h       |  76 ++++++
 2 files changed, 504 insertions(+), 21 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 5c212bf29640..2902774062b8 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -30,6 +30,7 @@
 #include <linux/iommu.h>
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/ptrace.h>
 #include <linux/rbtree.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
@@ -60,6 +61,7 @@ MODULE_PARM_DESC(disable_hugepages,
 
 struct vfio_iommu {
 	struct list_head	domain_list;
+	struct list_head	mm_list;
 	struct vfio_domain	*external_domain; /* domain for external user */
 	struct mutex		lock;
 	struct rb_root		dma_list;
@@ -90,6 +92,14 @@ struct vfio_dma {
 struct vfio_group {
 	struct iommu_group	*iommu_group;
 	struct list_head	next;
+	bool			sva_enabled;
+};
+
+struct vfio_mm {
+#define VFIO_PASID_INVALID	(-1)
+	int			pasid;
+	struct mm_struct	*mm;
+	struct list_head	next;
 };
 
 /*
@@ -1238,6 +1248,164 @@ static int vfio_iommu_replay(struct vfio_iommu *iommu,
 	return 0;
 }
 
+static int vfio_iommu_mm_exit(struct device *dev, int pasid, void *data)
+{
+	struct vfio_mm *vfio_mm;
+	struct vfio_iommu *iommu = data;
+
+	mutex_lock(&iommu->lock);
+	list_for_each_entry(vfio_mm, &iommu->mm_list, next) {
+		if (vfio_mm->pasid == pasid) {
+			list_del(&vfio_mm->next);
+			kfree(vfio_mm);
+			break;
+		}
+	}
+	mutex_unlock(&iommu->lock);
+
+	return 0;
+}
+
+static int vfio_iommu_sva_init(struct device *dev, void *data)
+{
+	return iommu_sva_device_init(dev, IOMMU_SVA_FEAT_IOPF, 0,
+				     vfio_iommu_mm_exit);
+}
+
+static int vfio_iommu_sva_shutdown(struct device *dev, void *data)
+{
+	iommu_sva_device_shutdown(dev);
+
+	return 0;
+}
+
+struct vfio_iommu_sva_bind_data {
+	struct vfio_mm *vfio_mm;
+	struct vfio_iommu *iommu;
+	int count;
+};
+
+static int vfio_iommu_sva_bind_dev(struct device *dev, void *data)
+{
+	struct vfio_iommu_sva_bind_data *bind_data = data;
+
+	/* Multi-device groups aren't support for SVA */
+	if (bind_data->count++)
+		return -EINVAL;
+
+	return __iommu_sva_bind_device(dev, bind_data->vfio_mm->mm,
+				       &bind_data->vfio_mm->pasid,
+				       IOMMU_SVA_FEAT_IOPF, bind_data->iommu);
+}
+
+static int vfio_iommu_sva_unbind_dev(struct device *dev, void *data)
+{
+	struct vfio_mm *vfio_mm = data;
+
+	return __iommu_sva_unbind_device(dev, vfio_mm->pasid);
+}
+
+static int vfio_iommu_bind_group(struct vfio_iommu *iommu,
+				 struct vfio_group *group,
+				 struct vfio_mm *vfio_mm)
+{
+	int ret;
+	bool enabled_sva = false;
+	struct vfio_iommu_sva_bind_data data = {
+		.vfio_mm	= vfio_mm,
+		.iommu		= iommu,
+		.count		= 0,
+	};
+
+	if (!group->sva_enabled) {
+		ret = iommu_group_for_each_dev(group->iommu_group, NULL,
+					       vfio_iommu_sva_init);
+		if (ret)
+			return ret;
+
+		group->sva_enabled = enabled_sva = true;
+	}
+
+	ret = iommu_group_for_each_dev(group->iommu_group, &data,
+				       vfio_iommu_sva_bind_dev);
+	if (ret && data.count > 1)
+		iommu_group_for_each_dev(group->iommu_group, vfio_mm,
+					 vfio_iommu_sva_unbind_dev);
+	if (ret && enabled_sva) {
+		iommu_group_for_each_dev(group->iommu_group, NULL,
+					 vfio_iommu_sva_shutdown);
+		group->sva_enabled = false;
+	}
+
+	return ret;
+}
+
+static void vfio_iommu_unbind_group(struct vfio_group *group,
+				    struct vfio_mm *vfio_mm)
+{
+	iommu_group_for_each_dev(group->iommu_group, vfio_mm,
+				 vfio_iommu_sva_unbind_dev);
+}
+
+static void vfio_iommu_unbind(struct vfio_iommu *iommu,
+			      struct vfio_mm *vfio_mm)
+{
+	struct vfio_group *group;
+	struct vfio_domain *domain;
+
+	list_for_each_entry(domain, &iommu->domain_list, next)
+		list_for_each_entry(group, &domain->group_list, next)
+			vfio_iommu_unbind_group(group, vfio_mm);
+}
+
+static int vfio_iommu_replay_bind(struct vfio_iommu *iommu,
+				  struct vfio_group *group)
+{
+	int ret = 0;
+	struct vfio_mm *vfio_mm;
+
+	list_for_each_entry(vfio_mm, &iommu->mm_list, next) {
+		/*
+		 * Ensure that mm doesn't exit while we're binding it to the new
+		 * group. It may already have exited, and the mm_exit notifier
+		 * might be waiting on the IOMMU mutex to remove this vfio_mm
+		 * from the list.
+		 */
+		if (!mmget_not_zero(vfio_mm->mm))
+			continue;
+		ret = vfio_iommu_bind_group(iommu, group, vfio_mm);
+		/*
+		 * Use async to avoid triggering an mm_exit callback right away,
+		 * which would block on the mutex that we're holding.
+		 */
+		mmput_async(vfio_mm->mm);
+
+		if (ret)
+			goto out_unbind;
+	}
+
+	return 0;
+
+out_unbind:
+	list_for_each_entry_continue_reverse(vfio_mm, &iommu->mm_list, next)
+		vfio_iommu_unbind_group(group, vfio_mm);
+
+	return ret;
+}
+
+static void vfio_iommu_free_all_mm(struct vfio_iommu *iommu)
+{
+	struct vfio_mm *vfio_mm, *next;
+
+	/*
+	 * No need for unbind() here. Since all groups are detached from this
+	 * iommu, bonds have been removed.
+	 */
+	list_for_each_entry_safe(vfio_mm, next, &iommu->mm_list, next)
+		kfree(vfio_mm);
+	INIT_LIST_HEAD(&iommu->mm_list);
+}
+
 /*
  * We change our unmap behavior slightly depending on whether the IOMMU
  * supports fine-grained superpages.  IOMMUs like AMD-Vi will use a superpage
@@ -1313,6 +1481,44 @@ static bool vfio_iommu_has_sw_msi(struct iommu_group *group, phys_addr_t *base)
 	return ret;
 }
 
+static int vfio_iommu_try_attach_group(struct vfio_iommu *iommu,
+				       struct vfio_group *group,
+				       struct vfio_domain *cur_domain,
+				       struct vfio_domain *new_domain)
+{
+	struct iommu_group *iommu_group = group->iommu_group;
+
+	/*
+	 * Try to match an existing compatible domain.  We don't want to
+	 * preclude an IOMMU driver supporting multiple bus_types and being
+	 * able to include different bus_types in the same IOMMU domain, so
+	 * we test whether the domains use the same iommu_ops rather than
+	 * testing if they're on the same bus_type.
+	 */
+	if (new_domain->domain->ops != cur_domain->domain->ops ||
+	    new_domain->prot != cur_domain->prot)
+		return 1;
+
+	iommu_detach_group(cur_domain->domain, iommu_group);
+
+	if (iommu_attach_group(new_domain->domain, iommu_group))
+		goto out_reattach;
+
+	if (vfio_iommu_replay_bind(iommu, group))
+		goto out_detach;
+
+	return 0;
+
+out_detach:
+	iommu_detach_group(new_domain->domain, iommu_group);
+
+out_reattach:
+	if (iommu_attach_group(cur_domain->domain, iommu_group))
+		return -EINVAL;
+
+	return 1;
+}
+
 static int vfio_iommu_type1_attach_group(void *iommu_data,
 					 struct iommu_group *iommu_group)
 {
@@ -1410,28 +1616,16 @@ static int vfio_iommu_type1_attach_group(void *iommu_data,
 	if (iommu_capable(bus, IOMMU_CAP_CACHE_COHERENCY))
 		domain->prot |= IOMMU_CACHE;
 
-	/*
-	 * Try to match an existing compatible domain.  We don't want to
-	 * preclude an IOMMU driver supporting multiple bus_types and being
-	 * able to include different bus_types in the same IOMMU domain, so
-	 * we test whether the domains use the same iommu_ops rather than
-	 * testing if they're on the same bus_type.
-	 */
 	list_for_each_entry(d, &iommu->domain_list, next) {
-		if (d->domain->ops == domain->domain->ops &&
-		    d->prot == domain->prot) {
-			iommu_detach_group(domain->domain, iommu_group);
-			if (!iommu_attach_group(d->domain, iommu_group)) {
-				list_add(&group->next, &d->group_list);
-				iommu_domain_free(domain->domain);
-				kfree(domain);
-				mutex_unlock(&iommu->lock);
-				return 0;
-			}
-
-			ret = iommu_attach_group(domain->domain, iommu_group);
-			if (ret)
-				goto out_domain;
+		ret = vfio_iommu_try_attach_group(iommu, group, domain, d);
+		if (ret < 0) {
+			goto out_domain;
+		} else if (!ret) {
+			list_add(&group->next, &d->group_list);
+			iommu_domain_free(domain->domain);
+			kfree(domain);
+			mutex_unlock(&iommu->lock);
+			return 0;
 		}
 	}
 
@@ -1442,6 +1636,10 @@ static int vfio_iommu_type1_attach_group(void *iommu_data,
 	if (ret)
 		goto out_detach;
 
+	ret = vfio_iommu_replay_bind(iommu, group);
+	if (ret)
+		goto out_detach;
+
 	if (resv_msi) {
 		ret = iommu_get_msi_cookie(domain->domain, resv_msi_base);
 		if (ret)
@@ -1547,6 +1745,11 @@ static void vfio_iommu_type1_detach_group(void *iommu_data,
 			continue;
 
 		iommu_detach_group(domain->domain, iommu_group);
+		if (group->sva_enabled) {
+			iommu_group_for_each_dev(iommu_group, NULL,
+						 vfio_iommu_sva_shutdown);
+			group->sva_enabled = false;
+		}
 		list_del(&group->next);
 		kfree(group);
 		/*
@@ -1562,6 +1765,7 @@ static void vfio_iommu_type1_detach_group(void *iommu_data,
 					vfio_iommu_unmap_unpin_all(iommu);
 				else
 					vfio_iommu_unmap_unpin_reaccount(iommu);
+				vfio_iommu_free_all_mm(iommu);
 			}
 			iommu_domain_free(domain->domain);
 			list_del(&domain->next);
@@ -1596,6 +1800,7 @@ static void *vfio_iommu_type1_open(unsigned long arg)
 	}
 
 	INIT_LIST_HEAD(&iommu->domain_list);
+	INIT_LIST_HEAD(&iommu->mm_list);
 	iommu->dma_list = RB_ROOT;
 	mutex_init(&iommu->lock);
 	BLOCKING_INIT_NOTIFIER_HEAD(&iommu->notifier);
@@ -1630,6 +1835,7 @@ static void vfio_iommu_type1_release(void *iommu_data)
 		kfree(iommu->external_domain);
 	}
 
+	vfio_iommu_free_all_mm(iommu);
 	vfio_iommu_unmap_unpin_all(iommu);
 
 	list_for_each_entry_safe(domain, domain_tmp,
@@ -1658,6 +1864,169 @@ static int vfio_domains_have_iommu_cache(struct vfio_iommu *iommu)
 	return ret;
 }
 
+static struct mm_struct *vfio_iommu_get_mm_by_vpid(pid_t vpid)
+{
+	struct mm_struct *mm;
+	struct task_struct *task;
+
+	task = find_get_task_by_vpid(vpid);
+	if (!task)
+		return ERR_PTR(-ESRCH);
+
+	/* Ensure that current has RW access on the mm */
+	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	put_task_struct(task);
+
+	if (!mm)
+		return ERR_PTR(-ESRCH);
+
+	return mm;
+}
+
+static long vfio_iommu_type1_bind_process(struct vfio_iommu *iommu,
+					  void __user *arg,
+					  struct vfio_iommu_type1_bind *bind)
+{
+	struct vfio_iommu_type1_bind_process params;
+	struct vfio_domain *domain;
+	struct vfio_group *group;
+	struct vfio_mm *vfio_mm;
+	struct mm_struct *mm;
+	unsigned long minsz;
+	int ret = 0;
+
+	minsz = sizeof(*bind) + sizeof(params);
+	if (bind->argsz < minsz)
+		return -EINVAL;
+
+	arg += sizeof(*bind);
+	if (copy_from_user(&params, arg, sizeof(params)))
+		return -EFAULT;
+
+	if (params.flags & ~VFIO_IOMMU_BIND_PID)
+		return -EINVAL;
+
+	if (params.flags & VFIO_IOMMU_BIND_PID) {
+		mm = vfio_iommu_get_mm_by_vpid(params.pid);
+		if (IS_ERR(mm))
+			return PTR_ERR(mm);
+	} else {
+		mm = get_task_mm(current);
+		if (!mm)
+			return -EINVAL;
+	}
+
+	mutex_lock(&iommu->lock);
+	if (!IS_IOMMU_CAP_DOMAIN_IN_CONTAINER(iommu)) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	list_for_each_entry(vfio_mm, &iommu->mm_list, next) {
+		if (vfio_mm->mm == mm) {
+			params.pasid = vfio_mm->pasid;
+			ret = copy_to_user(arg, &params, sizeof(params)) ?
+				-EFAULT : 0;
+			goto out_unlock;
+		}
+	}
+
+	vfio_mm = kzalloc(sizeof(*vfio_mm), GFP_KERNEL);
+	if (!vfio_mm) {
+		ret = -ENOMEM;
+		goto out_unlock;
+	}
+
+	vfio_mm->mm = mm;
+	vfio_mm->pasid = VFIO_PASID_INVALID;
+
+	list_for_each_entry(domain, &iommu->domain_list, next) {
+		list_for_each_entry(group, &domain->group_list, next) {
+			ret = vfio_iommu_bind_group(iommu, group, vfio_mm);
+			if (ret)
+				goto out_unbind;
+		}
+	}
+
+	list_add(&vfio_mm->next, &iommu->mm_list);
+
+	params.pasid = vfio_mm->pasid;
+	ret = copy_to_user(arg, &params, sizeof(params)) ? -EFAULT : 0;
+	if (ret)
+		goto out_delete;
+
+	mutex_unlock(&iommu->lock);
+	mmput(mm);
+	return 0;
+
+out_delete:
+	list_del(&vfio_mm->next);
+
+out_unbind:
+	/* Undo all binds that already succeeded */
+	vfio_iommu_unbind(iommu, vfio_mm);
+	kfree(vfio_mm);
+
+out_unlock:
+	mutex_unlock(&iommu->lock);
+	mmput(mm);
+	return ret;
+}
+
+static long vfio_iommu_type1_unbind_process(struct vfio_iommu *iommu,
+					    void __user *arg,
+					    struct vfio_iommu_type1_bind *bind)
+{
+	int ret = -EINVAL;
+	unsigned long minsz;
+	struct mm_struct *mm;
+	struct vfio_mm *vfio_mm;
+	struct vfio_iommu_type1_bind_process params;
+
+	minsz = sizeof(*bind) + sizeof(params);
+	if (bind->argsz < minsz)
+		return -EINVAL;
+
+	arg += sizeof(*bind);
+	if (copy_from_user(&params, arg, sizeof(params)))
+		return -EFAULT;
+
+	if (params.flags & ~VFIO_IOMMU_BIND_PID)
+		return -EINVAL;
+
+	/*
+	 * We can't simply call unbind with the PASID, because the process might
+	 * have died and the PASID might have been reallocated to another
+	 * process. Instead we need to fetch that process mm by PID again to
+	 * make sure we remove the right vfio_mm.
+	 */
+	if (params.flags & VFIO_IOMMU_BIND_PID) {
+		mm = vfio_iommu_get_mm_by_vpid(params.pid);
+		if (IS_ERR(mm))
+			return PTR_ERR(mm);
+	} else {
+		mm = get_task_mm(current);
+		if (!mm)
+			return -EINVAL;
+	}
+
+	ret = -ESRCH;
+	mutex_lock(&iommu->lock);
+	list_for_each_entry(vfio_mm, &iommu->mm_list, next) {
+		if (vfio_mm->mm == mm) {
+			vfio_iommu_unbind(iommu, vfio_mm);
+			list_del(&vfio_mm->next);
+			kfree(vfio_mm);
+			ret = 0;
+			break;
+		}
+	}
+	mutex_unlock(&iommu->lock);
+	mmput(mm);
+
+	return ret;
+}
+
 static long vfio_iommu_type1_ioctl(void *iommu_data,
 				   unsigned int cmd, unsigned long arg)
 {
@@ -1728,6 +2097,44 @@ static long vfio_iommu_type1_ioctl(void *iommu_data,
 
 		return copy_to_user((void __user *)arg, &unmap, minsz) ?
 			-EFAULT : 0;
+
+	} else if (cmd == VFIO_IOMMU_BIND) {
+		struct vfio_iommu_type1_bind bind;
+
+		minsz = offsetofend(struct vfio_iommu_type1_bind, flags);
+
+		if (copy_from_user(&bind, (void __user *)arg, minsz))
+			return -EFAULT;
+
+		if (bind.argsz < minsz)
+			return -EINVAL;
+
+		switch (bind.flags) {
+		case VFIO_IOMMU_BIND_PROCESS:
+			return vfio_iommu_type1_bind_process(iommu, (void *)arg,
+							     &bind);
+		default:
+			return -EINVAL;
+		}
+
+	} else if (cmd == VFIO_IOMMU_UNBIND) {
+		struct vfio_iommu_type1_bind bind;
+
+		minsz = offsetofend(struct vfio_iommu_type1_bind, flags);
+
+		if (copy_from_user(&bind, (void __user *)arg, minsz))
+			return -EFAULT;
+
+		if (bind.argsz < minsz)
+			return -EINVAL;
+
+		switch (bind.flags) {
+		case VFIO_IOMMU_BIND_PROCESS:
+			return vfio_iommu_type1_unbind_process(iommu, (void *)arg,
+							       &bind);
+		default:
+			return -EINVAL;
+		}
 	}
 
 	return -ENOTTY;
diff --git a/include/uapi/linux/vfio.h b/include/uapi/linux/vfio.h
index 1aa7b82e8169..dc07752c8fe8 100644
--- a/include/uapi/linux/vfio.h
+++ b/include/uapi/linux/vfio.h
@@ -665,6 +665,82 @@ struct vfio_iommu_type1_dma_unmap {
 #define VFIO_IOMMU_ENABLE	_IO(VFIO_TYPE, VFIO_BASE + 15)
 #define VFIO_IOMMU_DISABLE	_IO(VFIO_TYPE, VFIO_BASE + 16)
 
+/*
+ * VFIO_IOMMU_BIND_PROCESS
+ *
+ * Allocate a PASID for a process address space, and use it to attach this
+ * process to all devices in the container. Devices can then tag their DMA
+ * traffic with the returned @pasid to perform transactions on the associated
+ * virtual address space. Mapping and unmapping buffers is performed by standard
+ * functions such as mmap and malloc.
+ *
+ * If flag is VFIO_IOMMU_BIND_PID, @pid contains the pid of a foreign process to
+ * bind. Otherwise the current task is bound. Given that the caller owns the
+ * device, setting this flag grants the caller read and write permissions on the
+ * entire address space of foreign process described by @pid. Therefore,
+ * permission to perform the bind operation on a foreign process is governed by
+ * the ptrace access mode PTRACE_MODE_ATTACH_REALCREDS check. See man ptrace(2)
+ * for more information.
+ *
+ * On success, VFIO writes a Process Address Space ID (PASID) into @pasid. This
+ * ID is unique to a process and can be used on all devices in the container.
+ *
+ * On fork, the child inherits the device fd and can use the bonds setup by its
+ * parent. Consequently, the child has R/W access on the address spaces bound by
+ * its parent. After an execv, the device fd is closed and the child doesn't
+ * have access to the address space anymore.
+ *
+ * To remove a bond between process and container, VFIO_IOMMU_UNBIND ioctl is
+ * issued with the same parameters. If a pid was specified in VFIO_IOMMU_BIND,
+ * it should also be present for VFIO_IOMMU_UNBIND. Otherwise unbind the current
+ * task from the container.
+ */
+struct vfio_iommu_type1_bind_process {
+	__u32	flags;
+#define VFIO_IOMMU_BIND_PID		(1 << 0)
+	__u32	pasid;
+	__s32	pid;
+};
+
+/*
+ * Only mode supported at the moment is VFIO_IOMMU_BIND_PROCESS, which takes
+ * vfio_iommu_type1_bind_process in data.
+ */
+struct vfio_iommu_type1_bind {
+	__u32	argsz;
+	__u32	flags;
+#define VFIO_IOMMU_BIND_PROCESS		(1 << 0)
+	__u8	data[];
+};
+
+/*
+ * VFIO_IOMMU_BIND - _IOWR(VFIO_TYPE, VFIO_BASE + 22, struct vfio_iommu_bind)
+ *
+ * Manage address spaces of devices in this container. Initially a TYPE1
+ * container can only have one address space, managed with
+ * VFIO_IOMMU_MAP/UNMAP_DMA.
+ *
+ * An IOMMU of type VFIO_TYPE1_NESTING_IOMMU can be managed by both MAP/UNMAP
+ * and BIND ioctls at the same time. MAP/UNMAP acts on the stage-2 (host) page
+ * tables, and BIND manages the stage-1 (guest) page tables. Other types of
+ * IOMMU may allow MAP/UNMAP and BIND to coexist, where MAP/UNMAP controls
+ * non-PASID traffic and BIND controls PASID traffic. But this depends on the
+ * underlying IOMMU architecture and isn't guaranteed.
+ *
+ * Availability of this feature depends on the device, its bus, the underlying
+ * IOMMU and the CPU architecture.
+ *
+ * returns: 0 on success, -errno on failure.
+ */
+#define VFIO_IOMMU_BIND		_IO(VFIO_TYPE, VFIO_BASE + 22)
+
+/*
+ * VFIO_IOMMU_UNBIND - _IOWR(VFIO_TYPE, VFIO_BASE + 23, struct vfio_iommu_bind)
+ *
+ * Undo what was done by the corresponding VFIO_IOMMU_BIND ioctl.
+ */
+#define VFIO_IOMMU_UNBIND	_IO(VFIO_TYPE, VFIO_BASE + 23)
+
 /* -------- Additional API for SPAPR TCE (Server POWERPC) IOMMU -------- */
 
 /*
-- 
2.17.0
