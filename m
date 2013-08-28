Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 959FA6B0038
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:50:51 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so5961592pad.2
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:50:50 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 12/13] KVM: PPC: Add support for IOMMU in-kernel handling
Date: Wed, 28 Aug 2013 18:50:41 +1000
Message-Id: <1377679841-3822-1-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

This allows the host kernel to handle H_PUT_TCE, H_PUT_TCE_INDIRECT
and H_STUFF_TCE requests targeted an IOMMU TCE table without passing
them to user space which saves time on switching to user space and back.

Both real and virtual modes are supported. The kernel tries to
handle a TCE request in the real mode, if fails it passes the request
to the virtual mode to complete the operation. If it a virtual mode
handler fails, the request is passed to user space.

The first user of this is VFIO on POWER. Trampolines to the VFIO external
user API functions are required for this patch.

This adds a "SPAPR TCE IOMMU" KVM device to associate a logical bus
number (LIOBN) with an VFIO IOMMU group fd and enable in-kernel handling
of map/unmap requests. The device supports a single attribute which is
a struct with LIOBN and IOMMU fd. When the attribute is set, the device
establishes the connection between KVM and VFIO.

Tests show that this patch increases transmission speed from 220MB/s
to 750..1020MB/s on 10Gb network (Chelsea CXGB3 10Gb ethernet card).

Signed-off-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

---

Changes:
v9:
* KVM_CAP_SPAPR_TCE_IOMMU ioctl to KVM replaced with "SPAPR TCE IOMMU"
KVM device
* release_spapr_tce_table() is not shared between different TCE types
* reduced the patch size by moving VFIO external API
trampolines to separate patche
* moved documentation from Documentation/virtual/kvm/api.txt to
Documentation/virtual/kvm/devices/spapr_tce_iommu.txt

v8:
* fixed warnings from check_patch.pl

2013/07/11:
* removed multiple #ifdef IOMMU_API as IOMMU_API is always enabled
for KVM_BOOK3S_64
* kvmppc_gpa_to_hva_and_get also returns host phys address. Not much sense
for this here but the next patch for hugepages support will use it more.

2013/07/06:
* added realmode arch_spin_lock to protect TCE table from races
in real and virtual modes
* POWERPC IOMMU API is changed to support real mode
* iommu_take_ownership and iommu_release_ownership are protected by
iommu_table's locks
* VFIO external user API use rewritten
* multiple small fixes

2013/06/27:
* tce_list page is referenced now in order to protect it from accident
invalidation during H_PUT_TCE_INDIRECT execution
* added use of the external user VFIO API

2013/06/05:
* changed capability number
* changed ioctl number
* update the doc article number

2013/05/20:
* removed get_user() from real mode handlers
* kvm_vcpu_arch::tce_tmp usage extended. Now real mode handler puts there
translated TCEs, tries realmode_get_page() on those and if it fails, it
passes control over the virtual mode handler which tries to finish
the request handling
* kvmppc_lookup_pte() now does realmode_get_page() protected by BUSY bit
on a page
* The only reason to pass the request to user mode now is when the user mode
did not register TCE table in the kernel, in all other cases the virtual mode
handler is expected to do the job
---
 .../virtual/kvm/devices/spapr_tce_iommu.txt        |  37 +++
 arch/powerpc/include/asm/kvm_host.h                |   4 +
 arch/powerpc/kvm/book3s_64_vio.c                   | 310 ++++++++++++++++++++-
 arch/powerpc/kvm/book3s_64_vio_hv.c                | 122 ++++++++
 arch/powerpc/kvm/powerpc.c                         |   1 +
 include/linux/kvm_host.h                           |   1 +
 virt/kvm/kvm_main.c                                |   5 +
 7 files changed, 477 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/virtual/kvm/devices/spapr_tce_iommu.txt

diff --git a/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt b/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
new file mode 100644
index 0000000..4bc8fc3
--- /dev/null
+++ b/Documentation/virtual/kvm/devices/spapr_tce_iommu.txt
@@ -0,0 +1,37 @@
+SPAPR TCE IOMMU device
+
+Capability: KVM_CAP_SPAPR_TCE_IOMMU
+Architectures: powerpc
+
+Device type supported: KVM_DEV_TYPE_SPAPR_TCE_IOMMU
+
+Groups:
+  KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE
+  Attributes: single attribute with pair { LIOBN, IOMMU fd}
+
+This is completely made up device which provides API to link
+logical bus number (LIOBN) and IOMMU group. The user space has
+to create a new SPAPR TCE IOMMU device per a logical bus.
+
+LIOBN is a PCI bus identifier from PPC64-server (sPAPR) DMA hypercalls
+(H_PUT_TCE, H_PUT_TCE_INDIRECT, H_STUFF_TCE).
+IOMMU group is a minimal isolated device set which can be passed to
+the user space via VFIO.
+
+Right after creation the device is in uninitlized state and requires
+a KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE attribute to be set.
+The attribute contains liobn, IOMMU fd and flags:
+
+struct kvm_create_spapr_tce_iommu_linkage {
+	__u64 liobn;
+	__u32 fd;
+	__u32 flags;
+};
+
+The user space creates the SPAPR TCE IOMMU device, obtains
+an IOMMU fd via VFIO ABI and sets the attribute to the SPAPR TCE IOMMU
+device. At the moment of setting the attribute, the SPAPR TCE IOMMU
+device links LIOBN to IOMMU group and makes necessary steps
+to make sure that VFIO group will not disappear before KVM destroys.
+
+The kernel advertises this feature via KVM_CAP_SPAPR_TCE_IOMMU capability.
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index a23f132..c1a039d 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -181,6 +181,9 @@ struct kvmppc_spapr_tce_table {
 	struct kvm *kvm;
 	u64 liobn;
 	u32 window_size;
+	struct iommu_group *grp;		/* used for IOMMU groups */
+	struct kvm_create_spapr_tce_iommu_linkage link;
+	struct vfio_group *vfio_grp;		/* used for IOMMU groups */
 	struct page *pages[0];
 };
 
@@ -612,6 +615,7 @@ struct kvm_vcpu_arch {
 	u64 busy_preempt;
 
 	unsigned long *tce_tmp_hpas;	/* TCE cache for TCE_PUT_INDIRECT */
+	unsigned long tce_tmp_num;	/* Number of handled TCEs in cache */
 	enum {
 		TCERM_NONE,
 		TCERM_GETPAGE,
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 047b94c..95f9e1a 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -29,6 +29,8 @@
 #include <linux/anon_inodes.h>
 #include <linux/module.h>
 #include <linux/vfio.h>
+#include <linux/iommu.h>
+#include <linux/file.h>
 
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
@@ -201,9 +203,164 @@ fail:
 	return ret;
 }
 
-/* Converts guest physical address to host virtual address */
+static int kvmppc_spapr_tce_iommu_create(struct kvm_device *dev, u32 type)
+{
+	return 0;
+}
+
+static long kvmppc_spapr_tce_iommu_link(struct kvm_device *dev,
+		struct kvm_create_spapr_tce_iommu_linkage *args)
+{
+	struct kvm *kvm = dev->kvm;
+	struct kvmppc_spapr_tce_table *tt = NULL;
+	struct iommu_group *grp;
+	struct iommu_table *tbl;
+	struct file *vfio_filp;
+	struct vfio_group *vfio_grp;
+	int ret = -ENXIO, iommu_id;
+
+	/* Check this LIOBN hasn't been previously registered */
+	list_for_each_entry(tt, &kvm->arch.spapr_tce_tables, list) {
+		if (tt->liobn == args->liobn)
+			return -EBUSY;
+	}
+
+	vfio_filp = fget(args->fd);
+	if (!vfio_filp)
+		return -ENXIO;
+
+	/*
+	 * Lock the group. Fails if group is not viable or
+	 * does not have IOMMU set
+	 */
+	vfio_grp = kvmppc_vfio_group_get_external_user(vfio_filp);
+	if (IS_ERR_VALUE((unsigned long)vfio_grp))
+		goto fput_exit;
+
+	/* Get IOMMU ID, find iommu_group and iommu_table*/
+	iommu_id = kvmppc_vfio_external_user_iommu_id(vfio_grp);
+	if (iommu_id < 0)
+		goto grpput_fput_exit;
+
+	grp = iommu_group_get_by_id(iommu_id);
+	if (!grp)
+		goto grpput_fput_exit;
+
+	tbl = iommu_group_get_iommudata(grp);
+	if (!tbl)
+		goto grpput_fput_exit;
+
+	/* Create a TCE table descriptor and add into the descriptor list */
+	tt = kzalloc(sizeof(*tt), GFP_KERNEL);
+	if (!tt)
+		goto grpput_fput_exit;
+
+	tt->liobn = args->liobn;
+	tt->grp = grp;
+	tt->window_size = tbl->it_size << IOMMU_PAGE_SHIFT;
+	tt->vfio_grp = vfio_grp;
+
+	/* Add the TCE table descriptor to the descriptor list */
+	mutex_lock(&kvm->lock);
+	list_add(&tt->list, &kvm->arch.spapr_tce_tables);
+	mutex_unlock(&kvm->lock);
+
+	dev->private = tt;
+	tt->link = *args;
+
+	ret = 0;
+
+	goto fput_exit;
+
+grpput_fput_exit:
+	kvmppc_vfio_group_put_external_user(vfio_grp);
+fput_exit:
+	fput(vfio_filp);
+
+	return ret;
+}
+
+static int kvmppc_spapr_tce_iommu_set_attr(struct kvm_device *dev,
+		struct kvm_device_attr *attr)
+{
+	struct kvmppc_spapr_tce_table *tt = dev->private;
+	struct kvm_create_spapr_tce_iommu_linkage args;
+	void __user *argp = (void __user *) attr->addr;
+
+	switch (attr->group) {
+	case KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE:
+		if (tt)
+			return -EBUSY;
+
+		if (copy_from_user(&args, argp, sizeof(args)))
+			return -EFAULT;
+
+		return kvmppc_spapr_tce_iommu_link(dev, &args);
+	}
+	return -ENXIO;
+}
+
+static int kvmppc_spapr_tce_iommu_get_attr(struct kvm_device *dev,
+		struct kvm_device_attr *attr)
+{
+	struct kvmppc_spapr_tce_table *tt = dev->private;
+	void __user *argp = (void __user *) attr->addr;
+
+	switch (attr->group) {
+	case KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE:
+		if (!tt)
+			return -EFAULT;
+		if (copy_to_user(&tt->link, argp, sizeof(tt->link)))
+			return -EFAULT;
+		return 0;
+	}
+	return -ENXIO;
+}
+
+static int kvmppc_spapr_tce_iommu_has_attr(struct kvm_device *dev,
+		struct kvm_device_attr *attr)
+{
+	switch (attr->group) {
+	case KVM_DEV_SPAPR_TCE_IOMMU_ATTR_LINKAGE:
+		return 0;
+	}
+	return -ENXIO;
+}
+
+static void kvmppc_spapr_tce_iommu_destroy(struct kvm_device *dev)
+{
+	struct kvmppc_spapr_tce_table *tt = dev->private;
+	struct kvm *kvm = dev->kvm;
+
+	if (tt) {
+		mutex_lock(&kvm->lock);
+		list_del(&tt->list);
+
+		if (tt->vfio_grp)
+			kvmppc_vfio_group_put_external_user(tt->vfio_grp);
+		iommu_group_put(tt->grp);
+
+		kfree(tt);
+		mutex_unlock(&kvm->lock);
+	}
+	kfree(dev);
+}
+
+struct kvm_device_ops kvmppc_spapr_tce_iommu_ops = {
+	.name = "kvm-spapr-tce-iommu",
+	.create = kvmppc_spapr_tce_iommu_create,
+	.set_attr = kvmppc_spapr_tce_iommu_set_attr,
+	.get_attr = kvmppc_spapr_tce_iommu_get_attr,
+	.has_attr = kvmppc_spapr_tce_iommu_has_attr,
+	.destroy = kvmppc_spapr_tce_iommu_destroy,
+};
+
+/*
+ * Converts guest physical address to host virtual address.
+ * Also returns host physical address which is to put to TCE table.
+ */
 static void __user *kvmppc_gpa_to_hva_and_get(struct kvm_vcpu *vcpu,
-		unsigned long gpa, struct page **pg)
+		unsigned long gpa, struct page **pg, unsigned long *phpa)
 {
 	unsigned long hva, gfn = gpa >> PAGE_SHIFT;
 	struct kvm_memory_slot *memslot;
@@ -218,9 +375,140 @@ static void __user *kvmppc_gpa_to_hva_and_get(struct kvm_vcpu *vcpu,
 	if (get_user_pages_fast(hva & PAGE_MASK, 1, is_write, pg) != 1)
 		return ERROR_ADDR;
 
+	if (phpa)
+		*phpa = __pa((unsigned long) page_address(*pg)) |
+				(hva & ~PAGE_MASK);
+
 	return (void *) hva;
 }
 
+long kvmppc_h_put_tce_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce)
+{
+	struct page *pg = NULL;
+	unsigned long hpa;
+	void __user *hva;
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	/* Clear TCE */
+	if (!(tce & (TCE_PCI_READ | TCE_PCI_WRITE))) {
+		if (iommu_tce_clear_param_check(tbl, ioba, 0, 1))
+			return H_PARAMETER;
+
+		if (iommu_free_tces(tbl, ioba >> IOMMU_PAGE_SHIFT,
+				1, false))
+			return H_HARDWARE;
+
+		return H_SUCCESS;
+	}
+
+	/* Put TCE */
+	if (vcpu->arch.tce_rm_fail != TCERM_NONE) {
+		/* Retry iommu_tce_build if it failed in real mode */
+		vcpu->arch.tce_rm_fail = TCERM_NONE;
+		hpa = vcpu->arch.tce_tmp_hpas[0];
+	} else {
+		if (iommu_tce_put_param_check(tbl, ioba, tce))
+			return H_PARAMETER;
+
+		hva = kvmppc_gpa_to_hva_and_get(vcpu, tce, &pg, &hpa);
+		if (hva == ERROR_ADDR)
+			return H_HARDWARE;
+	}
+
+	if (!iommu_tce_build(tbl, ioba >> IOMMU_PAGE_SHIFT, &hpa, 1, false))
+		return H_SUCCESS;
+
+	pg = pfn_to_page(hpa >> PAGE_SHIFT);
+	if (pg)
+		put_page(pg);
+
+	return H_HARDWARE;
+}
+
+static long kvmppc_h_put_tce_indirect_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt, unsigned long ioba,
+		unsigned long __user *tces, unsigned long npages)
+{
+	long i = 0, start = 0;
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	switch (vcpu->arch.tce_rm_fail) {
+	case TCERM_NONE:
+		break;
+	case TCERM_GETPAGE:
+		start = vcpu->arch.tce_tmp_num;
+		break;
+	case TCERM_PUTTCE:
+		goto put_tces;
+	case TCERM_PUTLIST:
+	default:
+		WARN_ON(1);
+		return H_HARDWARE;
+	}
+
+	for (i = start; i < npages; ++i) {
+		struct page *pg = NULL;
+		unsigned long gpa;
+		void __user *hva;
+
+		if (get_user(gpa, tces + i))
+			return H_HARDWARE;
+
+		if (iommu_tce_put_param_check(tbl, ioba +
+					(i << IOMMU_PAGE_SHIFT), gpa))
+			return H_PARAMETER;
+
+		hva = kvmppc_gpa_to_hva_and_get(vcpu, gpa, &pg,
+				&vcpu->arch.tce_tmp_hpas[i]);
+		if (hva == ERROR_ADDR)
+			goto putpages_flush_exit;
+	}
+
+put_tces:
+	if (!iommu_tce_build(tbl, ioba >> IOMMU_PAGE_SHIFT,
+			vcpu->arch.tce_tmp_hpas, npages, false))
+		return H_SUCCESS;
+
+putpages_flush_exit:
+	for (--i; i >= 0; --i) {
+		struct page *pg;
+		pg = pfn_to_page(vcpu->arch.tce_tmp_hpas[i] >> PAGE_SHIFT);
+		if (pg)
+			put_page(pg);
+	}
+
+	return H_HARDWARE;
+}
+
+long kvmppc_h_stuff_tce_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_value, unsigned long npages)
+{
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+	unsigned long entry = ioba >> IOMMU_PAGE_SHIFT;
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	if (iommu_tce_clear_param_check(tbl, ioba, tce_value, npages))
+		return H_PARAMETER;
+
+	if (iommu_free_tces(tbl, entry, npages, false))
+		return H_HARDWARE;
+
+	return H_SUCCESS;
+}
+
 long kvmppc_h_put_tce(struct kvm_vcpu *vcpu,
 		unsigned long liobn, unsigned long ioba,
 		unsigned long tce)
@@ -232,6 +520,10 @@ long kvmppc_h_put_tce(struct kvm_vcpu *vcpu,
 	if (!tt)
 		return H_TOO_HARD;
 
+	if (tt->grp)
+		return kvmppc_h_put_tce_iommu(vcpu, tt, liobn, ioba, tce);
+
+	/* Emulated IO */
 	if (ioba >= tt->window_size)
 		return H_PARAMETER;
 
@@ -270,13 +562,20 @@ long kvmppc_h_put_tce_indirect(struct kvm_vcpu *vcpu,
 	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
 		return H_PARAMETER;
 
-	tces = kvmppc_gpa_to_hva_and_get(vcpu, tce_list, &pg);
+	tces = kvmppc_gpa_to_hva_and_get(vcpu, tce_list, &pg, NULL);
 	if (tces == ERROR_ADDR)
 		return H_TOO_HARD;
 
 	if (vcpu->arch.tce_rm_fail == TCERM_PUTLIST)
 		goto put_list_page_exit;
 
+	if (tt->grp) {
+		ret = kvmppc_h_put_tce_indirect_iommu(vcpu,
+			tt, ioba, tces, npages);
+		goto put_list_page_exit;
+	}
+
+	/* Emulated IO */
 	for (i = 0; i < npages; ++i) {
 		if (get_user(vcpu->arch.tce_tmp_hpas[i], tces + i)) {
 			ret = H_PARAMETER;
@@ -315,6 +614,11 @@ long kvmppc_h_stuff_tce(struct kvm_vcpu *vcpu,
 	if (!tt)
 		return H_TOO_HARD;
 
+	if (tt->grp)
+		return kvmppc_h_stuff_tce_iommu(vcpu, tt, liobn, ioba,
+				tce_value, npages);
+
+	/* Emulated IO */
 	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
 		return H_PARAMETER;
 
diff --git a/arch/powerpc/kvm/book3s_64_vio_hv.c b/arch/powerpc/kvm/book3s_64_vio_hv.c
index 2b2ce0a..c647990 100644
--- a/arch/powerpc/kvm/book3s_64_vio_hv.c
+++ b/arch/powerpc/kvm/book3s_64_vio_hv.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
 #include <linux/list.h>
+#include <linux/iommu.h>
 
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
@@ -191,6 +192,111 @@ static unsigned long kvmppc_rm_gpa_to_hpa_and_get(struct kvm_vcpu *vcpu,
 	return hpa;
 }
 
+static long kvmppc_rm_h_put_tce_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt, unsigned long liobn,
+		unsigned long ioba, unsigned long tce)
+{
+	int ret = 0;
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+	unsigned long hpa;
+	struct page *pg = NULL;
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	/* Clear TCE */
+	if (!(tce & (TCE_PCI_READ | TCE_PCI_WRITE))) {
+		if (iommu_tce_clear_param_check(tbl, ioba, 0, 1))
+			return H_PARAMETER;
+
+		if (iommu_free_tces(tbl, ioba >> IOMMU_PAGE_SHIFT, 1, true))
+			return H_TOO_HARD;
+
+		return H_SUCCESS;
+	}
+
+	/* Put TCE */
+	if (iommu_tce_put_param_check(tbl, ioba, tce))
+		return H_PARAMETER;
+
+	hpa = kvmppc_rm_gpa_to_hpa_and_get(vcpu, tce, &pg);
+	if (hpa != ERROR_ADDR) {
+		ret = iommu_tce_build(tbl, ioba >> IOMMU_PAGE_SHIFT,
+				&hpa, 1, true);
+	}
+
+	if (((hpa == ERROR_ADDR) && pg) || ret) {
+		vcpu->arch.tce_tmp_hpas[0] = hpa;
+		vcpu->arch.tce_tmp_num = 0;
+		vcpu->arch.tce_rm_fail = TCERM_PUTTCE;
+		return H_TOO_HARD;
+	}
+
+	return H_SUCCESS;
+}
+
+static long kvmppc_rm_h_put_tce_indirect_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt, unsigned long ioba,
+		unsigned long *tces, unsigned long npages)
+{
+	int i, ret;
+	unsigned long hpa;
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+	struct page *pg = NULL;
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	/* Check all TCEs */
+	for (i = 0; i < npages; ++i) {
+		if (iommu_tce_put_param_check(tbl, ioba +
+				(i << IOMMU_PAGE_SHIFT), tces[i]))
+			return H_PARAMETER;
+	}
+
+	/* Translate TCEs and go get_page() */
+	for (i = 0; i < npages; ++i) {
+		hpa = kvmppc_rm_gpa_to_hpa_and_get(vcpu, tces[i], &pg);
+		if (hpa == ERROR_ADDR) {
+			vcpu->arch.tce_tmp_num = i;
+			vcpu->arch.tce_rm_fail = TCERM_GETPAGE;
+			return H_TOO_HARD;
+		}
+		vcpu->arch.tce_tmp_hpas[i] = hpa;
+	}
+
+	/* Put TCEs to the table */
+	ret = iommu_tce_build(tbl, (ioba >> IOMMU_PAGE_SHIFT),
+			vcpu->arch.tce_tmp_hpas, npages, true);
+	if (ret == -EAGAIN) {
+		vcpu->arch.tce_rm_fail = TCERM_PUTTCE;
+		return H_TOO_HARD;
+	} else if (ret) {
+		return H_HARDWARE;
+	}
+
+	return H_SUCCESS;
+}
+
+static long kvmppc_rm_h_stuff_tce_iommu(struct kvm_vcpu *vcpu,
+		struct kvmppc_spapr_tce_table *tt,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_value, unsigned long npages)
+{
+	struct iommu_table *tbl = iommu_group_get_iommudata(tt->grp);
+
+	if (!tbl)
+		return H_RESCINDED;
+
+	if (iommu_tce_clear_param_check(tbl, ioba, tce_value, npages))
+		return H_PARAMETER;
+
+	if (iommu_free_tces(tbl, ioba >> IOMMU_PAGE_SHIFT, npages, true))
+		return H_TOO_HARD;
+
+	return H_SUCCESS;
+}
+
 long kvmppc_rm_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
 		      unsigned long ioba, unsigned long tce)
 {
@@ -201,6 +307,10 @@ long kvmppc_rm_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
 	if (!tt)
 		return H_TOO_HARD;
 
+	if (tt->grp)
+		return kvmppc_rm_h_put_tce_iommu(vcpu, tt, liobn, ioba, tce);
+
+	/* Emulated IO */
 	if (ioba >= tt->window_size)
 		return H_PARAMETER;
 
@@ -243,6 +353,13 @@ long kvmppc_rm_h_put_tce_indirect(struct kvm_vcpu *vcpu,
 		goto put_unlock_exit;
 	}
 
+	if (tt->grp) {
+		ret = kvmppc_rm_h_put_tce_indirect_iommu(vcpu,
+			tt, ioba, (unsigned long *)tces, npages);
+		goto put_unlock_exit;
+	}
+
+	/* Emulated IO */
 	for (i = 0; i < npages; ++i) {
 		ret = kvmppc_tce_validate(((unsigned long *)tces)[i]);
 		if (ret)
@@ -273,6 +390,11 @@ long kvmppc_rm_h_stuff_tce(struct kvm_vcpu *vcpu,
 	if (!tt)
 		return H_TOO_HARD;
 
+	if (tt->grp)
+		return kvmppc_rm_h_stuff_tce_iommu(vcpu, tt, liobn, ioba,
+				tce_value, npages);
+
+	/* Emulated IO */
 	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
 		return H_PARAMETER;
 
diff --git a/arch/powerpc/kvm/powerpc.c b/arch/powerpc/kvm/powerpc.c
index ccb578b..ea9af59 100644
--- a/arch/powerpc/kvm/powerpc.c
+++ b/arch/powerpc/kvm/powerpc.c
@@ -395,6 +395,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 		r = 1;
 		break;
 	case KVM_CAP_SPAPR_MULTITCE:
+	case KVM_CAP_SPAPR_TCE_IOMMU:
 		r = 1;
 		break;
 #endif
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 7a8c1b3..016df11 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -1053,6 +1053,7 @@ struct kvm_device *kvm_device_from_filp(struct file *filp);
 
 extern struct kvm_device_ops kvm_mpic_ops;
 extern struct kvm_device_ops kvm_xics_ops;
+extern struct kvm_device_ops kvmppc_spapr_tce_iommu_ops;
 
 #ifdef CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 1580dd4..34c3c22 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2282,6 +2282,11 @@ static int kvm_ioctl_create_device(struct kvm *kvm,
 		ops = &kvm_xics_ops;
 		break;
 #endif
+#ifdef CONFIG_SPAPR_TCE_IOMMU
+	case KVM_DEV_TYPE_SPAPR_TCE_IOMMU:
+		ops = &kvmppc_spapr_tce_iommu_ops;
+		break;
+#endif
 	default:
 		return -ENODEV;
 	}
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
