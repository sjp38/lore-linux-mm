Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFC8B6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 23:44:41 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 34so11634704uaq.11
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 20:44:41 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u26si6665782uae.165.2018.01.31.20.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 20:44:40 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [LSF/MM TOPIC] lru_lock scalability
Message-ID: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
Date: Wed, 31 Jan 2018 23:44:29 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de

I'd like to propose a discussion of lru_lock scalability on the mm track.  Since this is similar to Laurent Dufour's mmap_sem topic, it might make sense to discuss these around the same time.

On large systems, lru_lock is one of the hottest locks in the kernel, showing up on many memory-intensive benchmarks such as decision support.  It also inhibits scalability in many of the mm paths that could be parallelized, such as freeing pages during exit/munmap and inode eviction.

I'd like to discuss the following two ways of solving this problem, as well as any other approaches or ideas people have.


1) LRU batches
--------------

This method, developed with Steve Sistare, is described in this RFC series:

   https://lkml.org/lkml/2018/1/31/659

It introduces an array of locks, with each lock protecting certain batches of LRU pages.

        *ooooooooooo**ooooooooooo**ooooooooooo**oooo ...
        |           ||           ||           ||
         \ batch 1 /  \ batch 2 /  \ batch 3 /

In this ASCII depiction of an LRU, a page is represented with either '*' or 'o'.  An asterisk indicates a sentinel page, which is a page at the edge of a batch.  An 'o' indicates a non-sentinel page.

To remove a non-sentinel LRU page, only one lock from the array is required.  This allows multiple threads to remove pages from different batches simultaneously.  A sentinel page requires lru_lock in addition to a lock from the array.

Full performance numbers appear in the last patch in the linked series above, but this prototype allows a microbenchmark to do up to 28% more page faults per second with 16 or more concurrent processes.


2) Locking individual pages
---------------------------

This work, developed in collaboration with Yossi Lev and Dave Dice, locks individual pages on the LRU for removal.  It converts lru_lock from a spinlock to a rw_lock, using the read mode for concurrent removals and the write mode for other operations, i.e. those that need exclusive access to the LRU.

We hope to have a prototype and performance numbers closer to the time of the summit.

Here's a more detailed description of this approach from Yossi Lev, with code snippets to support the ideas.

/**
* The proposed algorithm for concurrent removal of pages from an LRU list
* relies on the ability to lock individual pages during removals.  In the
* implementation below, we support that by storing the NULL value in the next
* field of the page's lru field.  We can do that because the next field value
* is not needed once a page is locked. If for some reason we need to maintain
* the value of the next pointer during page removal, we could use its LSB for
* the locking purpose, or any other bit in the page that we designate for this
* purpose.
*/

#define PAGE_LOCKED_VAL    NULL

#define IS_LOCKED(lru)     (lru.next == PAGE_LOCKED_VAL)


/**
* We change the type of lru_lock from a regular spin lock (spinlock_t) to a read-write
* spin lock (rwlock_t).  Locking in read mode allows some operations to run
* concurrently with each other, as long as functions that requires exclusive
* access do not hold the lock in write mode.
*/
typedef struct pglist_data {
    // ...

    /* Write-intensive fields used by page reclaim */
    ZONE_PADDING(_pad1_)
    rwlock_t    lru_lock;

    // ...
} pg_data_t;

static inline rwlock_t *zone_lru_lock(struct zone *zone) {
	return &zone->zone_pgdat->lru_lock;
}


/**
* A concurrent variant of del_page_from_lru_list
*
* Unlike the regular del_page_from_lru_list function, which must be called while
* the lru_lock is held exclusively, here we are allowed to hold the lock in read
* mode, allowing concurrent runs of the del_page_from_lru_list_concurrent function.
*
* The implementation assumes that the lru_lock is held in either read or write
* mode on function entry.
*/
void del_page_from_lru_list_concurrent(struct page *page,
                                       struct lruvec *lruvec,
                                       enum lru_list lru) {
    /**
     * A removal of a page from the lru list only requires changing the prev and
     * next pointers in its neighboring pages.  Thus, the only case where we
     * need to synchronize concurrent removal of pages is when the pages are
     * adjacent on the LRU.
     *
     * The key idea of the algorithm is to deal with this case by locking
     * individual pages, and requiring a thread that removes a page to acquire
     * the locks on both the page that it removes, and the predecessor of that
     * page. Specifically, the removal of page P1 with a predecessor P0 in the
     * LRU list requires locking both P1 and P0, and keeps P1 locked until P1's
     * removal is completed.  Only then the lock on P0 is released, allowing it
     * to be removed as well.
     *
     * Note that while P1 is removed by thread T, T can manipulate the lru.prev
     * pointer of P1's successor page, even though T does not hold the lock on
     * that page.  This is safe because the only thread other than T that may be
     * accessing the lru.prev pointer of P1's successor page is a thread that
     * tries to remove that page, and that thread cannot proceed with the
     * removal (and update the lru.prev of the successor page) as long as P1 is
     * the predecessor, and is locked by T.
     *
     * Since we expect the case of concurrent removal of adjacent pages to be
     * rare, locking of adjacent pages is expected to succeed without waiting in
     * the common case; thus we expect very little or no contention during
     * parallel removal of pages from the list.
     *
     * Implementation note: having the information of whether a page is locked
     * be encoded in the list_head structure simplifies the function code a bit,
     * as it does not need to deal differently with the corner case where we
     * remove the page at the front of the list (i.e. the most recently used
     * page); this is because the pointers to the head and tail of a list also
     * reside in a field of type list_head (stored in lruvec), so the
     * implementation treats this field as if it is the lru field of a page, and
     * locks it as the predecessor of the head page when it is removed.
     */

    /**
     * Step 1: lock our page (i.e. the page we need to remove); we only fail to
     * do so if our successor is in the process of being removed, in which case
     * we wait for its removal to finish, which will unlock our page.
     */
    struct list_head *successor_p = READ_ONCE(page->lru.next);
    while (successor_p == PAGE_LOCKED_VAL ||
           cmpxchg(&page->lru.next,
                   successor_p, PAGE_LOCKED_VAL) != successor_p) {

        /* our successor is being removed, wait for it to finish */
        cpu_relax();
        successor_p = READ_ONCE(page->lru.next)
    }

    /**
     * Step 2: our page is locked, successor_p holds the pointer to our
     * successor, which cannot be removed while our page is locked (as we are
     * the predecessor of that page).
     * Try locking our predecessor. Locking will only fail if our predecessor is
     * being removed (or was already removed), in which case we wait for its
     * removal to complete, and continue by trying to lock our new predecessor.
     *
     * Notes:
     *
     * 1. We detect that the predecessor is locked by checking whether its next
     * pointer points to our page's node (i.e., our lru field).  If a thread is
     * in the process of removing our predecessor, the test will fail until we
     * have a new predecessor that is not in the process of being removed.
     * We therefore need to keep reading the value stored in our lru.prev field
     * every time an attempt to lock the predecessor fails.
     *
     * 2. The thread that removes our predecessor can update our lru.prev field
     * even though it doesn't hold the lock on our page.  The reason is that we
     * only need to reference the lru.prev pointer of a page when we remove it
     * from the list, our page, is only used by a thread that removes our page,
     * and that thread cannot proceed with the removal as long as the
     * predecessor is
     *
     * 3. This is the part of the code that is responsible to check for the
     * corner case of the head page removal if locking a page was not be a
     * simple operation on a list_head field, because the head page does not
     * have a predecessor page that we can lock. We can avoid dealing with this
     * corner case because a) we lock a page simply by manipulating the next
     * pointer in a field of type list_head, and b) the lru field of the head
     * page points to an instance of the list_head type (this instance is not
     * part of a page, but it still has a next pointer that points to the head
     * page, so we can lock and unlock it just as if it is the lru field of a
     * predecessor page).
     *
     */
    struct list_head *predecessor_p = READ_ONCE(page->lru.prev);
    while (predecessor_p->next != &page->lru ||
           cmpxchg(&predecessor_p->next,
                   &page->lru, PAGE_LOCKED_VAL) != &page->lru) {
        /**
         * Our predecessor is being removed; wait till we have a new unlocked
         * predecessor
         */
        cpu_relax();
        predecessor_p = READ_ONCE(page->lru.prev);
    }

    /**
     * Step 3: we now hold the lock on both our page (the one we need to remove)
     * and our predecessor page:  link together our successor and predecessor
     * pages by updating their prev and next pointers, respectively.  At that
     * point our node is removed, and we can safely release the lock on it by
     * updating its next pointer.
     *
     * Critically, we have to update the successor prev pointer _before_
     * updating the predecessor next pointer. The reason is that updating the
     * next pointer of a page unlocks that page, and unlocking our predecessor
     * page will allow it to be removed.  Thus, we have to make sure that both
     * pages are properly linked together before releasing the lock on our
     * predecessor.
     *
     * We guarantee that by setting the successor prev pointer first, which will
     * now point to our predecessor while it is still locked.  Thus, neither of
     * these pages can yet be removed. Only then we set the predecessor next
     * pointer, which also relinquishes our acquisition of its lock.
     *
     * For similar reasons, we only release the lock on our own node after the
     * successor points to its new predecessor.  (With the way the code is
     * written above, this is not as critical because the successor will still
     * fail to remove itself as long as our next pointer does not point to it,
     * so having any value other than the pointer to the successor in our next
     * field is safe.  That said, there is no reason to touch our next (or prev)
     * pointers before we're done with the page removal.
     */
    WRITE_ONCE(successor_p->prev, predecessor_p);
    WRITE_ONCE(predecessor_p->next, successor_p);

    /**
     * Cleanup (also releases the lock on our page).
     */
    page->lru.next = LIST_POISON1;
    page->lru.prev = LIST_POISON2;
}

/*
     ------------------
     Further Discussion
     ------------------

     As described above, the key observation behind the algorithm is that simple
     lru page removal operations can proceed in parallel with each other with
     very little per-page synchronization using the compare-and-swap (cmpxchg)
     primitives.  This can only be done safely, though, as long as other
     operations do not access the lru list at the same time.
     To enable concurrent removals only when it is safe to do so, we replace the
     spin lock that is used to protect the lru list (aka lru_lock) with a
     read-write lock (rwlock_t), that can be acquired in either exclusive mode
     (write acquisition), or shared mode (read-acquisition). Using the rwlock
     allows us to run many page removal operations in parallel, as long as no
     other operations that requires exclusive operations are being run.

     Below we discuss a few key aspects properties of the algorithm.

     Safety and synchronization overview
     ===================================

     1. Safe concurrent page removal: because page removals from the list do not
     need to traverse the list, but only manipulate the prev and next pointers of
     their neighboring pages, most removals can be done in parallel without
     synchronizing which each other; however, if two pages that are adjacent to
     each other in the list are being removed concurrently, some care should be
     taken to ensure that we correctly handle the data race over the pages'
     lru.next and lru.prev fields.

     The high level idea of synchronizing page removal is simple: we allow
     individual pages to be locked, and in order to remove a page P1 with a
     predecessor P0 and successor P2 (i.e., P0 <-> P1 <-> P2), the thread
     removing P1 has to lock both P1 and P0 (i.e., the page to be removed, and
     its predecessor).  Note that even though a thread T that removes P1 is not
     holding the lock of P2, P2 cannot be removed while T is removing P1, as P1
     is the predecessor of P2 in the list, and it is locked by T while it is
     being removed.  Thus, once T is holding the locks on both P1 and P0, it can
     manipulate the next and prev pointers between all 3 nodes.  The details of
     how the locking protocol and the pointer manipulation is handled are
     described in the code documentation above.

     2. Synchronization between page removals and other operations on the list:
     as mentioned above, the use of a read-write lock guarantees that only
     removal operations are running concurrently together, and the list is not
     being accessed by any other operation during that time.  We note, though,
     that a thread is allowed to acquire the read-write lock in exclusive mode
     (that is, acquire it for writing), which guarantees that it has exclusive
     access to the list. This can be used not only as a contention control
     mechanism (for extreme cases where most concurrent removal operations are
     for adjacent nodes), but also as a barrier to guarantee that all removal
     operations are completed).  This can be useful, for example, if we want to
     reclaim the memory used by previously removed pages and store random data in
     it, that cannot be safely observed by a thread during a removal operation.
     A simple write acquisition of the new lru lock will guarantee that all
     threads that are in the midst of removing pages completes their operation
     before the lock is being acquired in exclusive mode.

     Progress
     ========

     1. Synchronization granularity: the synchronization mechanism described
     above is extremely fine grained --- a removal of a page only requires
     holding the lock on that page and its predecessor.  Thus, in the example of
     a list with pages P0<->P1<->P2 in it, the removal of P1 can only delay the
     removal of P0 and P2, but not the removal of P2's successor or P0's
     predecessor; those can take place concurrently with the removal of P1.

     Because we expect concurrent removal of adjacent pages to be rare, we expect
     to see very little contention under normal circumstances, and for most
     remove operations to be executed in parallel without needing to wait for one
     another.

     2. Deadlock and live locks: the algorithm is not susceptible to either
     deadlocks or livelocks.  The former cannot occur because when a thread can
     only block the removal of its successor node, and the first (head) page can
     always be removed without waiting as it does not have a real predecessor
     (see comments in the code above on handling this case).  As for live locks,
     thread that acquired a lock never releases it before they finish their
     removal operation.  Thus, threads never "step back" to yield for other
     threads, and can only make progress towards finishing the removal of their
     page, so we should never be in a live lock scenario.

     3. Removal vs. other operations on the list: the lru read-write lock in write
     mode prevents any concurrency between operations on the list other than page
     removal.  However, in theory, a stream of removal operations can starve
     other operation that require exclusive access to the list; this may happen
     if the removal operations are allowed to keep acquiring and releasing the
     lock in shared mode, keeping the system in a state where there is always at
     least one removal operation in progress.
     It is critical, then, that we use a read-write lock that supports an
     anti-starvation mechanism, and in particular protects the writers from being
     starved by readers.  Almost all read write locks that are in use today have
     such a mechanism; a common idiom is that once a thread is waiting for the
     lock to be acquired in exclusive mode, threads that are trying to acquire
     the lock in shared mode are delayed until the thread that requires exclusive
     access acquires and releases the lock for writing.

     4. Handling extreme contention cases: in extreme cases that incur high wait
     time for locking individual pages, threads that are waiting to remove a page
     can always release their shared ownership of the lru lock, and request an
     exclusive ownership of it instead (that is, acquire the lock in for
     writing).  A successful write acquisition disallows any other operations
     (removals or others) to run in parallel with that thread, but it may be used
     as a fall back solution in extreme cases of high contention on a small
     fragment of the list, where a single acquisition of the global list lock may
     prove to be more beneficial than a series of individual pages locking.

     While we do not expect to see it happening in practice, it is important to
     keep that option in mind, and if necessary implement a fall back mechanism
     that detects the case where most remove operations are waiting to acquire
     individual locks, and signal them to move to a serial execution mode (one
     removal operation at a time).

     Integration and compatibility with existing code
     ================================================

     One important property of the new algorithm is that it requires very few
     local changes to existing code.  The new concurrent function for page
     removal is very short, and the only global change is replacing the lru spin
     lock with a read write lock, and changing the acquisition for the purpose of
     page removal to a read acquisition.

     Furthermore, the implementation suggested above does not add any additional
     fields or change the structure of existing data structures, and hence the
     old, serial page removal function is still compatible with it. Thus, if a
     page removal operation needs to acquire the lock exclusively for some
     reason, it can simply call the regular, serial page removal function, and
     avoid the additional synchronization overhead of the new parallel variant.
*/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
