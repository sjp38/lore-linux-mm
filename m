From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 4/6] mmu_notifier: Skeleton driver for a simple
	mmu_notifier
Date: Fri, 08 Feb 2008 14:06:20 -0800
Message-ID: <20080208220656.540801108@sgi.com>
References: <20080208220616.089936205@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=mmu_skeleton
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

This is example code for a simple device driver interface to unmap
pages that were externally mapped.

Locking is simple through a single lock that is used to protect the
device drivers data structures as well as a counter that tracks the
active invalidates on a single address space.

The invalidation of extern ptes must be possible with code that does
not require sleeping. The lock is taken for all driver operations on
the mmu that the driver manages. Locking could be made more sophisticated
but I think this is going to be okay for most uses.

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>

---
 Documentation/mmu_notifier/skeleton.c |  239 ++++++++++++++++++++++++++++++++++
 1 file changed, 239 insertions(+)

Index: linux-2.6/Documentation/mmu_notifier/skeleton.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/mmu_notifier/skeleton.c	2008-02-08 13:14:16.000000000 -0800
@@ -0,0 +1,239 @@
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/pagemap.h>
+
+/*
+ * Skeleton for an mmu notifier without rmap callbacks and no need to slepp
+ * during invalidate_page().
+ *
+ * (C) 2008 Silicon Graphics, Inc.
+ * 		Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
+ *
+ * Note that the locking is fairly basic. One can add various optimizations
+ * here and there. There is a single lock for an address space which should be
+ * satisfactory for most cases. If not then the lock can be split like the
+ * pte_lock in Linux. It is most likely best to place the locks in the
+ * page table structure or into whatever the external mmu uses to
+ * track the mappings.
+ */
+
+struct my_mmu {
+	/* MMU notifier specific fields */
+	struct mmu_notifier notifier;
+	spinlock_t lock;	/* Protects counter and invidual zaps */
+	int invalidates;	/* Number of active range_invalidates */
+};
+
+/*
+ * Called with m->lock held
+ */
+static void my_mmu_insert_page(struct my_mmu *m,
+		unsigned long address, unsigned long pfn)
+{
+	/* Must be provided */
+	printk(KERN_INFO "insert page %p address=%lx pfn=%ld\n",
+							m, address, pfn);
+}
+
+/*
+ * Called with m->lock held (optional but usually required to
+ * protect data structures of the driver).
+ */
+static void my_mmu_zap_page(struct my_mmu *m, unsigned long address)
+{
+	/* Must be provided */
+	printk(KERN_INFO "zap page %p address=%lx\n", m, address);
+}
+
+/*
+ * Called with m->lock held
+ */
+static void my_mmu_zap_range(struct my_mmu *m,
+	unsigned long start, unsigned long end, int atomic)
+{
+	/* Must be provided */
+	printk(KERN_INFO "zap range %p address=%lx-%lx atomic=%d\n",
+						m, start, end, atomic);
+}
+
+/*
+ * Zap an individual page.
+ *
+ * The page must be locked and a refcount on the page must
+ * be held when this function is called. The page lock is also
+ * acquired when new references are established and the
+ * page lock effecively takes on the role of synchronization.
+ *
+ * The m->lock is only taken to preserve the integrity fo the
+ * drivers data structures since we may also race with
+ * invalidate_range() which will likely access the same mmu
+ * control structures.
+ * m->lock is therefore optional here.
+ */
+static void my_mmu_invalidate_page(struct mmu_notifier *mn,
+	struct mm_struct *mm, unsigned long address)
+{
+	struct my_mmu *m = container_of(mn, struct my_mmu, notifier);
+
+	spin_lock(&m->lock);
+	my_mmu_zap_page(m, address);
+	spin_unlock(&m->lock);
+}
+
+/*
+ * Increment and decrement of the number of range invalidates
+ */
+static inline void inc_active(struct my_mmu *m)
+{
+	spin_lock(&m->lock);
+	m->invalidates++;
+	spin_unlock(&m->lock);
+}
+
+static inline void dec_active(struct my_mmu *m)
+{
+	spin_lock(&m->lock);
+	m->invalidates--;
+	spin_unlock(&m->lock);
+}
+
+static void my_mmu_invalidate_range_begin(struct mmu_notifier *mn,
+	struct mm_struct *mm, unsigned long start, unsigned long end,
+	int atomic)
+{
+	struct my_mmu *m = container_of(mn, struct my_mmu, notifier);
+
+	inc_active(m);	/* Holds off new references */
+	my_mmu_zap_range(m, start, end, atomic);
+}
+
+static void my_mmu_invalidate_range_end(struct mmu_notifier *mn,
+	struct mm_struct *mm, unsigned long start, unsigned long end,
+	int atomic)
+{
+	struct my_mmu *m = container_of(mn, struct my_mmu, notifier);
+
+	dec_active(m);		/* Enables new references */
+}
+
+/*
+ * Populate a page.
+ *
+ * A return value of-EAGAIN means please retry this operation.
+ *
+ * Acquisition of mmap_sem can be omitted if the caller already holds
+ * the semaphore.
+ */
+struct page *my_mmu_populate_page(struct my_mmu *m,
+	struct vm_area_struct *vma,
+	unsigned long address, int atomic, int write)
+{
+	struct page *page = ERR_PTR(-EAGAIN);
+	int err;
+
+	/* No need to do anything if a range invalidate is running */
+	if (m->invalidates)
+		goto out;
+
+	if (atomic) {
+
+		if (!down_read_trylock(&vma->vm_mm->mmap_sem))
+			goto out;
+
+		/* No concurrent invalidates */
+		page = follow_page(vma, address, FOLL_GET +
+					(write ? FOLL_WRITE : 0));
+
+		up_read(&vma->vm_mm->mmap_sem);
+		if (!page || IS_ERR(page) || TestSetPageLocked(page))
+			goto out;
+
+	} else {
+
+		down_read(&vma->vm_mm->mmap_sem);
+		err = get_user_pages(current, vma->vm_mm, address, 1,
+						write, 1, &page, NULL);
+
+		up_read(&vma->vm_mm->mmap_sem);
+		if (err < 0) {
+			page = ERR_PTR(err);
+			goto out;
+		}
+		lock_page(page);
+
+	}
+
+	/*
+	 * The page is now locked and we are holding a refcount on it.
+	 * So things are tied down. Now we can check the page status.
+	 */
+	if (page_mapped(page)) {
+		/*
+		 * Must take the m->lock here to hold off concurrent
+		 * invalidate_range_b/e. Serialization with invalidate_page()
+		 * occurs because we are holding the page lock.
+		 */
+		spin_lock(&m->lock);
+		if (!m->invalidates)
+			my_mmu_insert_page(m, address, page_to_pfn(page));
+		spin_unlock(&m->lock);
+	}
+	unlock_page(page);
+	put_page(page);
+out:
+	return page;
+}
+
+/*
+ * All other threads accessing this mm_struct must have terminated by now.
+ */
+static void my_mmu_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct my_mmu *m = container_of(mn, struct my_mmu, notifier);
+
+	my_mmu_zap_range(m, 0, TASK_SIZE, 0);
+	kfree(m);
+	printk(KERN_INFO "MMU Notifier detaching\n");
+}
+
+static struct mmu_notifier_ops my_mmu_ops = {
+	my_mmu_release,
+	NULL,			/* No aging function */
+	my_mmu_invalidate_page,
+	my_mmu_invalidate_range_begin,
+	my_mmu_invalidate_range_end
+};
+
+/*
+ * This function must be called to activate callbacks from a process
+ */
+int my_mmu_attach_to_process(struct mm_struct *mm)
+{
+	struct my_mmu *m = kzalloc(sizeof(struct my_mmu), GFP_KERNEL);
+
+	if (!m)
+		return -ENOMEM;
+
+	m->notifier.ops = &my_mmu_ops;
+	spin_lock_init(&mm->lock);
+
+	/*
+	 * mmap_sem handling can be omitted if it is guaranteed that
+	 * the context from which my_mmu_attach_to_process is called
+	 * is already holding a writelock on mmap_sem.
+	 */
+	down_write(&mm->mmap_sem);
+	mmu_notifier_register(&m->notifier, mm);
+	up_write(&mm->mmap_sem);
+
+	/*
+	 * RCU sync is expensive but necessary if we need to guarantee
+	 * that multiple threads running on other cpus have seen the
+	 * notifier changes.
+	 */
+	synchronize_rcu();
+	return 0;
+}
+

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
