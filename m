Date: Thu, 26 Oct 2006 14:13:36 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061026041336.GD6046@localhost.localdomain>
References: <20061025100929.GA11040@localhost.localdomain> <000001c6f8b3$1d4bd020$a389030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6f8b3$1d4bd020$a389030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 08:59:18PM -0700, Chen, Kenneth W wrote:
> David Gibson wrote on Wednesday, October 25, 2006 3:09 AM
> > > And almost(?) all the backtracking could be taken out if i_mutex
> > > were held; hugetlbfs_file_mmap is already taking i_mutex within
> > > mmap_sem (contrary to usual mm lock ordering, but probably okay
> > > since hugetlbfs has no read/write, though lockdep may need teaching).
> > > Though serializing these faults at all is regrettable.
> > 
> > Um, yes.  Especially when I was in the middle of attempting to
> > de-serialize it.  Christoph Lameter has userspace stuff to do hugepage
> > initialization (clearing mostly), in parallal, which obviously won't
> > work with the serialization.  I have a tentative patch to address it,
> 
> I used to argue dearly on how important it is to allow parallel hugetlb
> faults for scalability, but somehow lost my ground in the midst of flurry
> development.  Glad to see it is coming back.

Ok.  Fwiw, my experimental patch for this, which I wrote in response
to Christoph Lameter's concerns is below.  It will need revision in
the face of whatever fix Hugh comes up with for the i_size problems.

> > which replaces the hugetlb_instantiation_mutex with a table of
> > mutexes, hashed on address_space and offset (or struct mm and address
> > for MAP_PRIVATE).  Originally I tried to simply remove the mutex, and
> > just retry faults when we got an OOM but a race was detected.  After
> > several variants each on 2 or 3 basic approaches, each of which turned
> > out to be less race-free than I originally thought, I gave up and went
> > with the hashed mutexes.  Either way though, there will still be
> > i_size issues to sort out.
> 
> We are trying to do too much in the fault path. One wild idea would be
> to zero out page in the free_huge_page().  E.g. all "free" pages sitting
> in the pool are ready to be handed out.  In the free_huge_page() path, we
> have a lot more freedom and can scale better because there are no owner yet,
> nor tricky race to worry about.  It will make the fault path faster.

Hrm.. that's an interesting idea.  One of the first things I attempted
with this deserialization thing was just to shrink the serialized
area, moving the hugepage clear out of the lock.  This turned out to
be impossible (or at least, much harder than I initially thought) due
to lock-ordering and various other constraints.  Doing the clear in
free_huge_age() addresses that quite neatly.

On the other hand, it won't help at all for COW faults - we still have
to copy a huge page.  And in addition, we will already have spent the
time to clear a page which we're just going to overwrite with a copy.

hugepage: Allow parallelization of the hugepage fault path

At present, the page fault path for hugepages is serialized by a
single mutex.  This is used to avoid spurious out-of-memory conditions
when the hugepage pool is fully utilized (two processes or threads can
race to instantiate the same mapping with the last hugepage from the
pool, the race loser returning VM_FAULT_OOM).  This problem is
specific to hugepages, because it is normal to want to use every
single hugepage in the system - with normal pages we simply assume
there will always be a few spare pages which can be used temporarily
until the race is resolved.

Unfortunately this serialization also means that clearing of hugepages
cannot be parallelized across multiple CPUs, which can lead to very
long process startup times when using large numbers of hugepages.

This patch improves the situation by replacing the single mutex with a
table of mutexes, selected based on a hash of the address_space and
file offset being faulted (or mm and virtual address for MAP_PRIVATE
mappings).

Index: working-2.6/mm/hugetlb.c
===================================================================
--- working-2.6.orig/mm/hugetlb.c	2006-10-23 13:50:31.000000000 +1000
+++ working-2.6/mm/hugetlb.c	2006-10-23 13:58:54.000000000 +1000
@@ -32,6 +32,13 @@ static unsigned int free_huge_pages_node
  */
 static DEFINE_SPINLOCK(hugetlb_lock);
 
+/*
+ * Serializes faults on the same logical page.  This is used to
+ * prevent spurious OOMs when the hugepage pool is fully utilized.
+ */
+static int num_fault_mutexes;
+static struct mutex *htlb_fault_mutex_table;
+
 static void clear_huge_page(struct page *page, unsigned long addr)
 {
 	int i;
@@ -160,6 +167,13 @@ static int __init hugetlb_init(void)
 	}
 	max_huge_pages = free_huge_pages = nr_huge_pages = i;
 	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
+
+	num_fault_mutexes = 2 * num_possible_cpus() - 1;
+	htlb_fault_mutex_table =
+		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
+	for (i = 0; i < num_fault_mutexes; i++)
+		mutex_init(&htlb_fault_mutex_table[i]);
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -458,19 +472,14 @@ static int hugetlb_cow(struct mm_struct 
 }
 
 int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, int write_access)
+		    struct address_space *mapping, unsigned long idx,
+		    unsigned long address, pte_t *ptep, int write_access)
 {
 	int ret = VM_FAULT_SIGBUS;
-	unsigned long idx;
 	unsigned long size;
 	struct page *page;
-	struct address_space *mapping;
 	pte_t new_pte;
 
-	mapping = vma->vm_file->f_mapping;
-	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
-		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
-
 	/*
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
@@ -535,28 +544,50 @@ backout:
 	goto out;
 }
 
+static int fault_mutex_hash(struct mm_struct *mm, struct vm_area_struct *vma,
+			    struct address_space *mapping,
+			    unsigned long pagenum, unsigned long address)
+{
+	void *p = mapping;
+
+	if (! (vma->vm_flags & VM_SHARED)) {
+		p = mm;
+		pagenum = address << HPAGE_SIZE;
+	}
+
+	return ((unsigned long)p + pagenum) % num_fault_mutexes;
+}
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access)
 {
 	pte_t *ptep;
 	pte_t entry;
 	int ret;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
+	struct address_space *mapping;
+	unsigned long idx;
+	int hash;
 
 	ptep = huge_pte_alloc(mm, address);
 	if (!ptep)
 		return VM_FAULT_OOM;
 
+	mapping = vma->vm_file->f_mapping;
+	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
+		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+
 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	mutex_lock(&hugetlb_instantiation_mutex);
+	hash = fault_mutex_hash(mm, vma, mapping, idx, address);
+	mutex_lock(&htlb_fault_mutex_table[hash]);
 	entry = *ptep;
 	if (pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
-		mutex_unlock(&hugetlb_instantiation_mutex);
+		ret = hugetlb_no_page(mm, vma, mapping, idx,
+				      address, ptep, write_access);
+		mutex_unlock(&htlb_fault_mutex_table[hash]);
 		return ret;
 	}
 
@@ -568,7 +599,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 		if (write_access && !pte_write(entry))
 			ret = hugetlb_cow(mm, vma, address, ptep, entry);
 	spin_unlock(&mm->page_table_lock);
-	mutex_unlock(&hugetlb_instantiation_mutex);
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
 
 	return ret;
 }


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
