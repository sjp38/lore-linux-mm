From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 6/6] mmu_rmap_notifier: Skeleton for complex
	driver that uses its own rmaps
Date: Fri, 08 Feb 2008 14:06:22 -0800
Message-ID: <20080208220657.029243317@sgi.com>
References: <20080208220616.089936205@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=mmu_rmap_skeleton
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

The skeleton for the rmap notifier leaves the invalidate_page method of
the mmu_notifier empty and hooks a new invalidate_page callback into the
global chain for mmu_rmap_notifiers.

There are seveal simplifications in here to avoid making this too complex.
The reverse maps need to consit of references to vma f.e.

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>

---
 Documentation/mmu_notifier/skeleton_rmap.c |  265 +++++++++++++++++++++++++++++
 1 file changed, 265 insertions(+)

Index: linux-2.6/Documentation/mmu_notifier/skeleton_rmap.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/mmu_notifier/skeleton_rmap.c	2008-02-08 13:25:28.000000000 -0800
@@ -0,0 +1,265 @@
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/pagemap.h>
+
+/*
+ * Skeleton for an mmu notifier with rmap callbacks and sleeping during
+ * invalidate_page.
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
+	int invalidates;	/* Number of active range_invalidate */
+
+       /* Rmap support */
+       struct list_head list;	/* rmap list of my_mmu structs */
+       unsigned long base;
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
+	dec_active(m);	/* Enables new references */
+}
+
+/*
+ * Populate a page.
+ *
+ * A return value of-EAGAIN means please retry this operation.
+ *
+ * Acuisition of mmap_sem can be omitted if the caller already holds
+ * the semaphore.
+ */
+struct page *my_mmu_populate_page(struct my_mmu *m,
+	struct vm_area_struct *vma,
+	unsigned long address, int write)
+{
+	struct page *page = ERR_PTR(-EAGAIN);
+	int err;
+
+	/*
+	 * No need to do anything if a range invalidate is running
+	 * Could use a wait queue here to avoid returning -EAGAIN.
+	 */
+	if (m->invalidates)
+		goto out;
+
+	down_read(&vma->vm_mm->mmap_sem);
+	err = get_user_pages(current, vma->vm_mm, address, 1,
+						write, 1, &page, NULL);
+
+	up_read(&vma->vm_mm->mmap_sem);
+	if (err < 0) {
+		page = ERR_PTR(err);
+		goto out;
+	}
+	lock_page(page);
+
+	/*
+	 * The page is now locked and we are holding a refcount on it.
+	 * So things are tied down. Now we can check the page status.
+	 */
+	if (page_mapped(page)) {
+		/* Could do some preprocessing here. Can sleep */
+		spin_lock(&m->lock);
+		if (!m->invalidates)
+			my_mmu_insert_page(m, address, page_to_pfn(page));
+		spin_unlock(&m->lock);
+		/* Could do some postprocessing here. Can sleep */
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
+	/* No concurrent processes thus no worries about RCU */
+	list_del(&m->list);
+	kfree(m);
+	printk(KERN_INFO "MMU Notifier terminating\n");
+}
+
+static struct mmu_notifier_ops my_mmu_ops = {
+	my_mmu_release,
+	NULL,		/* No aging function */
+	NULL,		/* No atomic invalidate_page function */
+	my_mmu_invalidate_range_begin,
+	my_mmu_invalidate_range_end
+};
+
+/* Rmap specific fields */
+static LIST_HEAD(my_mmu_list);
+static struct rw_semaphore listlock;
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
+	spin_lock_init(&m->lock);
+
+	/*
+	 * mmap_sem handling can be omitted if it is guaranteed that
+	 * the context from which my_mmu_attach_to_process is called
+	 * is already holding a writelock on mmap_sem.
+	 */
+	down_write(&mm->mmap_sem);
+	mmu_notifier_register(&m->notifier, mm);
+	up_write(&mm->mmap_sem);
+	down_write(&listlock);
+	list_add(&m->list, &my_mmu_list);
+	up_write(&listlock);
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
+
+static void my_sleeping_invalidate_page(struct my_mmu *m, unsigned long address)
+{
+	/* Must be provided */
+	spin_lock(&m->lock);	/* Only taken to ensure mmu data integrity */
+	my_mmu_zap_page(m, address);
+	spin_unlock(&m->lock);
+	printk(KERN_INFO "Sleeping invalidate_page %p address=%lx\n",
+                                                               m, address);
+}
+
+static unsigned long my_mmu_find_addr(struct my_mmu *m, struct page *page)
+{
+	/* Determine the address of a page in a mmu segment */
+	return -EFAULT;
+}
+
+/*
+ * A reference must be held on the page passed and the page passed
+ * must be locked. No spinlocks are held. invalidate_page() is held
+ * off by us holding the page lock.
+ */
+static void my_mmu_rmap_invalidate_page(struct mmu_rmap_notifier *mrn,
+							struct page *page)
+{
+	struct my_mmu *m;
+
+	BUG_ON(!PageLocked(page));
+	down_read(&listlock);
+	list_for_each_entry(m, &my_mmu_list, list) {
+		unsigned long address = my_mmu_find_addr(m, page);
+
+		if (address != -EFAULT)
+			my_sleeping_invalidate_page(m, address);
+	}
+	up_read(&listlock);
+}
+
+static struct mmu_rmap_notifier_ops my_mmu_rmap_ops = {
+	.invalidate_page = my_mmu_rmap_invalidate_page
+};
+
+static struct mmu_rmap_notifier my_mmu_rmap_notifier = {
+	.ops = &my_mmu_rmap_ops
+};
+
+static int __init my_mmu_init(void)
+{
+	mmu_rmap_notifier_register(&my_mmu_rmap_notifier);
+	return 0;
+}
+
+late_initcall(my_mmu_init);
+

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
