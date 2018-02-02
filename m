Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB4CF6B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 06:02:21 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z37so19298469qtj.15
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 03:02:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h20si1860380qta.418.2018.02.02.03.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 03:02:20 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w12AxIZ9074275
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 06:02:19 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fvmqndaky-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 06:02:18 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 2 Feb 2018 11:02:16 -0000
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 2 Feb 2018 12:02:10 +0100
MIME-Version: 1.0
In-Reply-To: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <471f59cc-b4f7-462a-b6e5-064aaf132132@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de

Hi Daniel,

On 01/02/2018 05:44, Daniel Jordan wrote:
> I'd like to propose a discussion of lru_lock scalability on the mm track.A 
> Since this is similar to Laurent Dufour's mmap_sem topic, it might make
> sense to discuss these around the same time.

I do agree, the scalability issue is not only due the mmap_sem, having a
larger discussion on this topic would make sense.

Cheers,
Laurent.

> 
> On large systems, lru_lock is one of the hottest locks in the kernel,
> showing up on many memory-intensive benchmarks such as decision support.A 
> It also inhibits scalability in many of the mm paths that could be
> parallelized, such as freeing pages during exit/munmap and inode eviction.
> 
> I'd like to discuss the following two ways of solving this problem, as well
> as any other approaches or ideas people have.
> 
> 
> 1) LRU batches
> --------------
> 
> This method, developed with Steve Sistare, is described in this RFC series:
> 
> A  https://lkml.org/lkml/2018/1/31/659
> 
> It introduces an array of locks, with each lock protecting certain batches
> of LRU pages.
> 
> A A A A A A  *ooooooooooo**ooooooooooo**ooooooooooo**oooo ...
> A A A A A A  |A A A A A A A A A A  ||A A A A A A A A A A  ||A A A A A A A A A A  ||
> A A A A A A A  \ batch 1 /A  \ batch 2 /A  \ batch 3 /
> 
> In this ASCII depiction of an LRU, a page is represented with either '*' or
> 'o'.A  An asterisk indicates a sentinel page, which is a page at the edge of
> a batch.A  An 'o' indicates a non-sentinel page.
> 
> To remove a non-sentinel LRU page, only one lock from the array is
> required.A  This allows multiple threads to remove pages from different
> batches simultaneously.A  A sentinel page requires lru_lock in addition to a
> lock from the array.
> 
> Full performance numbers appear in the last patch in the linked series
> above, but this prototype allows a microbenchmark to do up to 28% more page
> faults per second with 16 or more concurrent processes.
> 
> 
> 2) Locking individual pages
> ---------------------------
> 
> This work, developed in collaboration with Yossi Lev and Dave Dice, locks
> individual pages on the LRU for removal.A  It converts lru_lock from a
> spinlock to a rw_lock, using the read mode for concurrent removals and the
> write mode for other operations, i.e. those that need exclusive access to
> the LRU.
> 
> We hope to have a prototype and performance numbers closer to the time of
> the summit.
> 
> Here's a more detailed description of this approach from Yossi Lev, with
> code snippets to support the ideas.
> 
> /**
> * The proposed algorithm for concurrent removal of pages from an LRU list
> * relies on the ability to lock individual pages during removals.A  In the
> * implementation below, we support that by storing the NULL value in the next
> * field of the page's lru field.A  We can do that because the next field value
> * is not needed once a page is locked. If for some reason we need to maintain
> * the value of the next pointer during page removal, we could use its LSB for
> * the locking purpose, or any other bit in the page that we designate for this
> * purpose.
> */
> 
> #define PAGE_LOCKED_VALA A A  NULL
> 
> #define IS_LOCKED(lru)A A A A  (lru.next == PAGE_LOCKED_VAL)
> 
> 
> /**
> * We change the type of lru_lock from a regular spin lock (spinlock_t) to a
> read-write
> * spin lock (rwlock_t).A  Locking in read mode allows some operations to run
> * concurrently with each other, as long as functions that requires exclusive
> * access do not hold the lock in write mode.
> */
> typedef struct pglist_data {
> A A  // ...
> 
> A A  /* Write-intensive fields used by page reclaim */
> A A  ZONE_PADDING(_pad1_)
> A A  rwlock_tA A A  lru_lock;
> 
> A A  // ...
> } pg_data_t;
> 
> static inline rwlock_t *zone_lru_lock(struct zone *zone) {
> A A A A return &zone->zone_pgdat->lru_lock;
> }
> 
> 
> /**
> * A concurrent variant of del_page_from_lru_list
> *
> * Unlike the regular del_page_from_lru_list function, which must be called
> while
> * the lru_lock is held exclusively, here we are allowed to hold the lock in
> read
> * mode, allowing concurrent runs of the del_page_from_lru_list_concurrent
> function.
> *
> * The implementation assumes that the lru_lock is held in either read or write
> * mode on function entry.
> */
> void del_page_from_lru_list_concurrent(struct page *page,
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  struct lruvec *lruvec,
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  enum lru_list lru) {
> A A  /**
> A A A  * A removal of a page from the lru list only requires changing the prev
> and
> A A A  * next pointers in its neighboring pages.A  Thus, the only case where we
> A A A  * need to synchronize concurrent removal of pages is when the pages are
> A A A  * adjacent on the LRU.
> A A A  *
> A A A  * The key idea of the algorithm is to deal with this case by locking
> A A A  * individual pages, and requiring a thread that removes a page to acquire
> A A A  * the locks on both the page that it removes, and the predecessor of that
> A A A  * page. Specifically, the removal of page P1 with a predecessor P0 in the
> A A A  * LRU list requires locking both P1 and P0, and keeps P1 locked until P1's
> A A A  * removal is completed.A  Only then the lock on P0 is released, allowing it
> A A A  * to be removed as well.
> A A A  *
> A A A  * Note that while P1 is removed by thread T, T can manipulate the lru.prev
> A A A  * pointer of P1's successor page, even though T does not hold the lock on
> A A A  * that page.A  This is safe because the only thread other than T that
> may be
> A A A  * accessing the lru.prev pointer of P1's successor page is a thread that
> A A A  * tries to remove that page, and that thread cannot proceed with the
> A A A  * removal (and update the lru.prev of the successor page) as long as P1 is
> A A A  * the predecessor, and is locked by T.
> A A A  *
> A A A  * Since we expect the case of concurrent removal of adjacent pages to be
> A A A  * rare, locking of adjacent pages is expected to succeed without
> waiting in
> A A A  * the common case; thus we expect very little or no contention during
> A A A  * parallel removal of pages from the list.
> A A A  *
> A A A  * Implementation note: having the information of whether a page is locked
> A A A  * be encoded in the list_head structure simplifies the function code a
> bit,
> A A A  * as it does not need to deal differently with the corner case where we
> A A A  * remove the page at the front of the list (i.e. the most recently used
> A A A  * page); this is because the pointers to the head and tail of a list also
> A A A  * reside in a field of type list_head (stored in lruvec), so the
> A A A  * implementation treats this field as if it is the lru field of a page,
> and
> A A A  * locks it as the predecessor of the head page when it is removed.
> A A A  */
> 
> A A  /**
> A A A  * Step 1: lock our page (i.e. the page we need to remove); we only fail to
> A A A  * do so if our successor is in the process of being removed, in which case
> A A A  * we wait for its removal to finish, which will unlock our page.
> A A A  */
> A A  struct list_head *successor_p = READ_ONCE(page->lru.next);
> A A  while (successor_p == PAGE_LOCKED_VAL ||
> A A A A A A A A A  cmpxchg(&page->lru.next,
> A A A A A A A A A A A A A A A A A  successor_p, PAGE_LOCKED_VAL) != successor_p) {
> 
> A A A A A A  /* our successor is being removed, wait for it to finish */
> A A A A A A  cpu_relax();
> A A A A A A  successor_p = READ_ONCE(page->lru.next)
> A A  }
> 
> A A  /**
> A A A  * Step 2: our page is locked, successor_p holds the pointer to our
> A A A  * successor, which cannot be removed while our page is locked (as we are
> A A A  * the predecessor of that page).
> A A A  * Try locking our predecessor. Locking will only fail if our
> predecessor is
> A A A  * being removed (or was already removed), in which case we wait for its
> A A A  * removal to complete, and continue by trying to lock our new predecessor.
> A A A  *
> A A A  * Notes:
> A A A  *
> A A A  * 1. We detect that the predecessor is locked by checking whether its next
> A A A  * pointer points to our page's node (i.e., our lru field).A  If a thread is
> A A A  * in the process of removing our predecessor, the test will fail until we
> A A A  * have a new predecessor that is not in the process of being removed.
> A A A  * We therefore need to keep reading the value stored in our lru.prev field
> A A A  * every time an attempt to lock the predecessor fails.
> A A A  *
> A A A  * 2. The thread that removes our predecessor can update our lru.prev field
> A A A  * even though it doesn't hold the lock on our page.A  The reason is that we
> A A A  * only need to reference the lru.prev pointer of a page when we remove it
> A A A  * from the list, our page, is only used by a thread that removes our page,
> A A A  * and that thread cannot proceed with the removal as long as the
> A A A  * predecessor is
> A A A  *
> A A A  * 3. This is the part of the code that is responsible to check for the
> A A A  * corner case of the head page removal if locking a page was not be a
> A A A  * simple operation on a list_head field, because the head page does not
> A A A  * have a predecessor page that we can lock. We can avoid dealing with this
> A A A  * corner case because a) we lock a page simply by manipulating the next
> A A A  * pointer in a field of type list_head, and b) the lru field of the head
> A A A  * page points to an instance of the list_head type (this instance is not
> A A A  * part of a page, but it still has a next pointer that points to the head
> A A A  * page, so we can lock and unlock it just as if it is the lru field of a
> A A A  * predecessor page).
> A A A  *
> A A A  */
> A A  struct list_head *predecessor_p = READ_ONCE(page->lru.prev);
> A A  while (predecessor_p->next != &page->lru ||
> A A A A A A A A A  cmpxchg(&predecessor_p->next,
> A A A A A A A A A A A A A A A A A  &page->lru, PAGE_LOCKED_VAL) != &page->lru) {
> A A A A A A  /**
> A A A A A A A  * Our predecessor is being removed; wait till we have a new unlocked
> A A A A A A A  * predecessor
> A A A A A A A  */
> A A A A A A  cpu_relax();
> A A A A A A  predecessor_p = READ_ONCE(page->lru.prev);
> A A  }
> 
> A A  /**
> A A A  * Step 3: we now hold the lock on both our page (the one we need to
> remove)
> A A A  * and our predecessor page:A  link together our successor and predecessor
> A A A  * pages by updating their prev and next pointers, respectively.A  At that
> A A A  * point our node is removed, and we can safely release the lock on it by
> A A A  * updating its next pointer.
> A A A  *
> A A A  * Critically, we have to update the successor prev pointer _before_
> A A A  * updating the predecessor next pointer. The reason is that updating the
> A A A  * next pointer of a page unlocks that page, and unlocking our predecessor
> A A A  * page will allow it to be removed.A  Thus, we have to make sure that both
> A A A  * pages are properly linked together before releasing the lock on our
> A A A  * predecessor.
> A A A  *
> A A A  * We guarantee that by setting the successor prev pointer first, which
> will
> A A A  * now point to our predecessor while it is still locked.A  Thus, neither of
> A A A  * these pages can yet be removed. Only then we set the predecessor next
> A A A  * pointer, which also relinquishes our acquisition of its lock.
> A A A  *
> A A A  * For similar reasons, we only release the lock on our own node after the
> A A A  * successor points to its new predecessor.A  (With the way the code is
> A A A  * written above, this is not as critical because the successor will still
> A A A  * fail to remove itself as long as our next pointer does not point to it,
> A A A  * so having any value other than the pointer to the successor in our next
> A A A  * field is safe.A  That said, there is no reason to touch our next (or
> prev)
> A A A  * pointers before we're done with the page removal.
> A A A  */
> A A  WRITE_ONCE(successor_p->prev, predecessor_p);
> A A  WRITE_ONCE(predecessor_p->next, successor_p);
> 
> A A  /**
> A A A  * Cleanup (also releases the lock on our page).
> A A A  */
> A A  page->lru.next = LIST_POISON1;
> A A  page->lru.prev = LIST_POISON2;
> }
> 
> /*
> A A A  ------------------
> A A A  Further Discussion
> A A A  ------------------
> 
> A A A  As described above, the key observation behind the algorithm is that
> simple
> A A A  lru page removal operations can proceed in parallel with each other with
> A A A  very little per-page synchronization using the compare-and-swap (cmpxchg)
> A A A  primitives.A  This can only be done safely, though, as long as other
> A A A  operations do not access the lru list at the same time.
> A A A  To enable concurrent removals only when it is safe to do so, we replace
> the
> A A A  spin lock that is used to protect the lru list (aka lru_lock) with a
> A A A  read-write lock (rwlock_t), that can be acquired in either exclusive mode
> A A A  (write acquisition), or shared mode (read-acquisition). Using the rwlock
> A A A  allows us to run many page removal operations in parallel, as long as no
> A A A  other operations that requires exclusive operations are being run.
> 
> A A A  Below we discuss a few key aspects properties of the algorithm.
> 
> A A A  Safety and synchronization overview
> A A A  ===================================
> 
> A A A  1. Safe concurrent page removal: because page removals from the list do
> not
> A A A  need to traverse the list, but only manipulate the prev and next
> pointers of
> A A A  their neighboring pages, most removals can be done in parallel without
> A A A  synchronizing which each other; however, if two pages that are adjacent to
> A A A  each other in the list are being removed concurrently, some care should be
> A A A  taken to ensure that we correctly handle the data race over the pages'
> A A A  lru.next and lru.prev fields.
> 
> A A A  The high level idea of synchronizing page removal is simple: we allow
> A A A  individual pages to be locked, and in order to remove a page P1 with a
> A A A  predecessor P0 and successor P2 (i.e., P0 <-> P1 <-> P2), the thread
> A A A  removing P1 has to lock both P1 and P0 (i.e., the page to be removed, and
> A A A  its predecessor).A  Note that even though a thread T that removes P1 is not
> A A A  holding the lock of P2, P2 cannot be removed while T is removing P1, as P1
> A A A  is the predecessor of P2 in the list, and it is locked by T while it is
> A A A  being removed.A  Thus, once T is holding the locks on both P1 and P0, it
> can
> A A A  manipulate the next and prev pointers between all 3 nodes.A  The details of
> A A A  how the locking protocol and the pointer manipulation is handled are
> A A A  described in the code documentation above.
> 
> A A A  2. Synchronization between page removals and other operations on the list:
> A A A  as mentioned above, the use of a read-write lock guarantees that only
> A A A  removal operations are running concurrently together, and the list is not
> A A A  being accessed by any other operation during that time.A  We note, though,
> A A A  that a thread is allowed to acquire the read-write lock in exclusive mode
> A A A  (that is, acquire it for writing), which guarantees that it has exclusive
> A A A  access to the list. This can be used not only as a contention control
> A A A  mechanism (for extreme cases where most concurrent removal operations are
> A A A  for adjacent nodes), but also as a barrier to guarantee that all removal
> A A A  operations are completed).A  This can be useful, for example, if we want to
> A A A  reclaim the memory used by previously removed pages and store random
> data in
> A A A  it, that cannot be safely observed by a thread during a removal operation.
> A A A  A simple write acquisition of the new lru lock will guarantee that all
> A A A  threads that are in the midst of removing pages completes their operation
> A A A  before the lock is being acquired in exclusive mode.
> 
> A A A  Progress
> A A A  ========
> 
> A A A  1. Synchronization granularity: the synchronization mechanism described
> A A A  above is extremely fine grained --- a removal of a page only requires
> A A A  holding the lock on that page and its predecessor.A  Thus, in the
> example of
> A A A  a list with pages P0<->P1<->P2 in it, the removal of P1 can only delay the
> A A A  removal of P0 and P2, but not the removal of P2's successor or P0's
> A A A  predecessor; those can take place concurrently with the removal of P1.
> 
> A A A  Because we expect concurrent removal of adjacent pages to be rare, we
> expect
> A A A  to see very little contention under normal circumstances, and for most
> A A A  remove operations to be executed in parallel without needing to wait
> for one
> A A A  another.
> 
> A A A  2. Deadlock and live locks: the algorithm is not susceptible to either
> A A A  deadlocks or livelocks.A  The former cannot occur because when a thread can
> A A A  only block the removal of its successor node, and the first (head) page
> can
> A A A  always be removed without waiting as it does not have a real predecessor
> A A A  (see comments in the code above on handling this case).A  As for live
> locks,
> A A A  thread that acquired a lock never releases it before they finish their
> A A A  removal operation.A  Thus, threads never "step back" to yield for other
> A A A  threads, and can only make progress towards finishing the removal of their
> A A A  page, so we should never be in a live lock scenario.
> 
> A A A  3. Removal vs. other operations on the list: the lru read-write lock in
> write
> A A A  mode prevents any concurrency between operations on the list other than
> page
> A A A  removal.A  However, in theory, a stream of removal operations can starve
> A A A  other operation that require exclusive access to the list; this may happen
> A A A  if the removal operations are allowed to keep acquiring and releasing the
> A A A  lock in shared mode, keeping the system in a state where there is
> always at
> A A A  least one removal operation in progress.
> A A A  It is critical, then, that we use a read-write lock that supports an
> A A A  anti-starvation mechanism, and in particular protects the writers from
> being
> A A A  starved by readers.A  Almost all read write locks that are in use today
> have
> A A A  such a mechanism; a common idiom is that once a thread is waiting for the
> A A A  lock to be acquired in exclusive mode, threads that are trying to acquire
> A A A  the lock in shared mode are delayed until the thread that requires
> exclusive
> A A A  access acquires and releases the lock for writing.
> 
> A A A  4. Handling extreme contention cases: in extreme cases that incur high
> wait
> A A A  time for locking individual pages, threads that are waiting to remove a
> page
> A A A  can always release their shared ownership of the lru lock, and request an
> A A A  exclusive ownership of it instead (that is, acquire the lock in for
> A A A  writing).A  A successful write acquisition disallows any other operations
> A A A  (removals or others) to run in parallel with that thread, but it may be
> used
> A A A  as a fall back solution in extreme cases of high contention on a small
> A A A  fragment of the list, where a single acquisition of the global list
> lock may
> A A A  prove to be more beneficial than a series of individual pages locking.
> 
> A A A  While we do not expect to see it happening in practice, it is important to
> A A A  keep that option in mind, and if necessary implement a fall back mechanism
> A A A  that detects the case where most remove operations are waiting to acquire
> A A A  individual locks, and signal them to move to a serial execution mode (one
> A A A  removal operation at a time).
> 
> A A A  Integration and compatibility with existing code
> A A A  ================================================
> 
> A A A  One important property of the new algorithm is that it requires very few
> A A A  local changes to existing code.A  The new concurrent function for page
> A A A  removal is very short, and the only global change is replacing the lru
> spin
> A A A  lock with a read write lock, and changing the acquisition for the
> purpose of
> A A A  page removal to a read acquisition.
> 
> A A A  Furthermore, the implementation suggested above does not add any
> additional
> A A A  fields or change the structure of existing data structures, and hence the
> A A A  old, serial page removal function is still compatible with it. Thus, if a
> A A A  page removal operation needs to acquire the lock exclusively for some
> A A A  reason, it can simply call the regular, serial page removal function, and
> A A A  avoid the additional synchronization overhead of the new parallel variant.
> */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
