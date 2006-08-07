Message-ID: <44D74B98.3030305@yahoo.com.au>
Date: Tue, 08 Aug 2006 00:18:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> (David, I've added you to CC because way down below
> there's an issue of interaction with page_mkwrite.)

Apparently not a problem yet (phew). But the sooner we make a decision
here, the more future page_mkwrite problems we might prevent ;)


>>Complexity and documentation issues aside, the locking protocol fails
>>in the case where we would like to invalidate pagecache inside i_size.
>>do_no_page can come in anytime and filemap_nopage is not aware of the
>>invalidation in progress (as it is when it is outside i_size). The
>>end result is that dangling (->mapping == NULL) pages that appear to
>>be from a particular file may be mapped into userspace with nonsense
>>data. Valid mappings to the same place will see a different page.
> 
> 
> I think it was some NFS or cluster FS case that showed the problem,
> Andrea would know.  But Badari's MADV_REMOVE, punching a hole within
> a file, has added another case which the i_size/truncate_count
> technique cannot properly guard against.

Yes. I guess I should mention some examples of these users. Direct
IO under mmapped pagecache AFAIKS would have the race too.

> 
> 
>>Andrea implemented two working fixes, one using a real seqlock,
>>another using a page->flags bit. He also proposed using the page lock
>>in do_no_page, but that was initially considered too heavyweight.
>>However, it is not a global or per-file lock, and the page cacheline
>>is modified in do_no_page to increment _count and _mapcount anyway, so
>>a further modification should not be a large performance hit.
>>Scalability is not an issue.
> 
> 
> Scalability is not an issue, that's nice - but I don't see how you
> arrive at that certainty.  Obviously the per-page lock means it's
> less of a scalability issue than global or per-file; and the fact
> that tmpfs' shmem_getpage has always taken page lock internally
> adds good evidence that it can't be too bad.

Well, scalability because there is no extra cacheline transfer
anywhere. The cacheline must already be local at both the site
where we take the page lock, and the site where we unlock it.

> But I worry a little about shared libraries, and suspect that there
> will be cases degraded by the additional locking - perhaps benchmarks
> (with processes falling into lockstep) rather than real-life loads.  I
> think it's fair to say "Scalability is unlikely to be much of an issue".

I don't expect them to be an issue. Even if tree_lock were removed
from the find_get/lock_page path, there is still the per-page count
and mapcount to contend with. Sure, lock_page may prevent a very
*slight* amount of parallelism...

Anyway, we do need a bugfix, and it is something we do have to give
up performance for, if nothing better can be found.

If there is a really bad problem (which I doubt), then I can trade
them a per-page lock for the per-inode tree_lock and truncate_count
bouncing around in do_no_page()...

No, seriously: maybe we could re-evaluate one of Andrea's
implementations, or look at holding lock_page for shorter times. I
don't know until I see ;)

> 
> 
>>This patch implements this latter approach. ->nopage implementations
>>return with the page locked if it is possible for their underlying
>>file to be invalidated (in that case, they must set a special vm_flags
>>bit to indicate so). do_no_page only unlocks the page after setting
>>up the mapping completely. invalidation is excluded because it holds
>>the page lock during invalidation of each page.
>>
>>This allows significant simplifications in do_no_page.
>>
>>kbuild performance is, surprisingly, maybe slightly improved:
> 
> 
> Emphasis on maybe.  It would be surprising, and your ext3 system
> times go the other way, and I find the reverse of what you find:
> slightly regressed, say ~0.5%, on kbuilds and some lmbenchs.

No the ext3 times are improved too. Elapsed time, that is.

I don't doubt you see some regressions. I still haven't got numbers
for a wide range of architectures yet. Implementation still in
flux...

> I didn't care for "INVLD", and gather now that it's being changed to
> "INVALIDATE" (I'd have suggested "INVAL").  But actually, I'd rather
> a name that says what's actually being assumed: VM_NOPAGE_LOCKED?
> 
> With "revoke" in the air, I suspect that we're going to want to be
> able to invalidate the pages of _any_ mapping, whether the driver
> locks them in its nopage or not.  (Or am I thereby just encouraging
> the idea of a racy revoke?)

I'd like to fix pagecache and let revoke sort that out. Good point
though.

> 
> 
>> 
>> #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
>> #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
>>@@ -205,6 +210,7 @@ struct vm_operations_struct {
>> 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
>> 					unsigned long addr);
>> #endif
>>+	unsigned long vm_flags; /* vm_flags to copy into any mapping vmas */
>> };
> 
> 
> I suppose this is quite efficient, but I find it confusing.
> We have lots and lots of drivers already setting vm_flags in their
> mmap methods, now you add an alternative way of doing the same thing.
> Can't you just set VM_NOPAGE_LOCKED in the relevant mmap methods?
> Or did you try it that way and it worked out messy?

Generic pagecache doesn't have an mmap method, which is where
I stopped looking. I guess you could add the |= to filemap_nopage,
but that's much uglier.

I don't find it at all confusing, just maybe a bit of a violation
because the structure is technically only for "ops".

> 
> 
>> struct mmu_gather;
>>Index: linux-2.6/mm/filemap.c
>>===================================================================
>>--- linux-2.6.orig/mm/filemap.c	2006-07-31 15:37:42.000000000 +1000
>>+++ linux-2.6/mm/filemap.c	2006-07-31 16:06:04.000000000 +1000
>>@@ -1279,6 +1279,8 @@ struct page *filemap_nopage(struct vm_ar

>>@@ -1462,7 +1426,6 @@ page_not_uptodate:
>> 	page_cache_release(page);
>> 	return NULL;
> 
> 
> But here I think you're missing something: the wait_on_page_locked
> after ->readpage needs to become a lock_page before going to success?
> with unlock_page if it doesn't.

Good catch, thanks.

>>Index: linux-2.6/mm/memory.c
>>===================================================================
>>--- linux-2.6.orig/mm/memory.c	2006-07-26 18:00:47.000000000 +1000
>>+++ linux-2.6/mm/memory.c	2006-07-31 16:06:40.000000000 +1000
>>@@ -1577,6 +1577,13 @@ static int unmap_mapping_range_vma(struc
>> 	unsigned long restart_addr;
>> 	int need_break;
>> 
>>+	/*
>>+	 * files that support invalidating or truncating portions of the
>>+	 * file from under mmaped areas must set the VM_CAN_INVLD flag, and
>>+	 * have their .nopage function return the page locked.
>>+	 */
>>+	BUG_ON(!(vma->vm_flags & VM_CAN_INVLD));
>>+
> 
> 
> I think we shall end up wanting to apply unmap_mapping_range even
> to "unlocked nopage" vmas (the revoke idea) - unless we decide we
> have to make every nopage vma do the locking.  

Yes, I think we should tackle that when we see it?

> 
> Would the BUG_ON be better as a WARN_ON, or nothing at all?  It'll
> give trouble until out-of-tree filesystems/drivers are updated; or
> do we want to give them active trouble there, I'm not sure?

I guess we do because now all the old truncate race handling is gone
they'll see corruption much sooner if they don't lock the page.

>>@@ -2040,36 +2039,23 @@ static int do_no_page(struct mm_struct *
>> 		int write_access)
>> {
>> 	spinlock_t *ptl;
>>-	struct page *new_page;
>>-	struct address_space *mapping = NULL;
>>+	struct page *new_page, *old_page;
> 
> 
> I think it's much clearer to call it "locked_page" than "old_page",
> particularly when you see it alonside Peter's "dirty_page".

OK.

>>+	BUG_ON(vma->vm_flags & VM_CAN_INVLD && !PageLocked(new_page));
> 
> 
> Maybe
> 	if (vma->vm_flags & VM_NOPAGE_LOCKED) {
> 		locked_page = new_page;
> 		BUG_ON(!PageLocked(locked_page));
> 	} else
> 		locked_page = NULL;
> 
> But what I hate about this do_no_page is that sometimes we're going
> through it with the page locked, and sometimes we're going through it
> with the page not locked.  Now I've not noticed any actual problem
> from that (aside from where page_mkwrite fails), and it is well-defined
> which case is which, but it is confusing and does make do_no_page harder
> to audit at any time.
> 
> (I did toy with a separate do_no_page_locked, and nopage_locked
> methods for the filesystems; but duplicating so much code doesn't
> really solve anything.)
> 
> And when you factor in Peter's dirty_page stuff, it's a nuisance:
> because he has had to get_page(dirty_page) then put_page(dirty_page),
> in case page already got freed by vmscan after ptl dropped: which is
> redundant if the page is locked throughout, but you can't rely on that
> because (for a while at least) some fs'es won't set VM_NOPAGE_LOCKED.
> 
> How about
> 	if (vma->vm_flags & VM_NOPAGE_LOCKED)
> 		BUG_ON(!PageLocked(new_page));
> 	else
> 		lock_page(new_page);
> 	locked_page = new_page;
> ?
> 
> And then proceed through the rest of do_no_page sure in the knowledge
> that we have the page locked, simplifying whatever might be simplified
> by that (removing Peter's get_page,put_page at least).  I can see this
> adds a little overhead to some less important cases, but it does make
> the rules much easier to grasp.

OK, I hadn't looked at either the dirty page or the page_mkwrite stuff
with a mind to this patch, to be honest (which is why the page_mkwrite
is broken).

Sorry, it was a diff against what I was working on (2.6.17), and I
hadn't brought it uptodate before posting for comments.


> 
> 
>> 
>> 	/*
>> 	 * Should we do an early C-O-W break?
> 
> 
> Somewhere below here you're missing a hunk to deal with a failed
> page_mkwrite, needing to unlock_page(locked_page).  We don't have
> an example of a page_mkwrite in tree at present, but it seems
> reasonable to suppose that we not it should unlock the page.
> 
> Hmm, David Howells has an afs_file_page_mkwrite which sits waiting
> for an FsMisc page flag to be cleared: might that deadlock with the
> page lock held?  If so, it may need to unlock and relock the page,
> rechecking for truncation.
> 
> Hmmm, page_mkwrite when called from do_wp_page would not expect to
> be holding page lock: we don't want it called with in one case and
> without in the other.  Maybe do_no_page needs to unlock_page before
> calling page_mkwrite, lock_page after, and check page->mapping when
> VM_NOPAGE_LOCKED??

That's pretty foul. I'll take a bit of a look. Is it really a problem
to call in either state, if it is well documented? (we could even
send a flag down if needed). I thought filesystem code loved this
kind of spaghetti locking?

>>Index: linux-2.6/mm/shmem.c
>>===================================================================
>>--- linux-2.6.orig/mm/shmem.c	2006-07-26 18:00:47.000000000 +1000
>>+++ linux-2.6/mm/shmem.c	2006-07-31 16:54:48.000000000 +1000
>>@@ -80,6 +80,7 @@ enum sgp_type {
>> 	SGP_READ,	/* don't exceed i_size, don't allocate page */
>> 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
>> 	SGP_WRITE,	/* may exceed i_size, may allocate page */
>>+	SGP_NOPAGE,	/* same as SGP_CACHE, return with page locked */
>> };
> 
> 
> I don't think you need to add another type for this, SGP_CACHE should do.
> 
> Perhaps you avoided that because it's also used by shmem_populate.
> But another point I want to make is that you do need to update
> filemap_populate, shmem_populate, install_page and whatever to
> make use the same locked page fix: they've been relying on the
> i_size and page->mapping checks, which are not quite enough,
> isn't that right? (now my grasp of the race has fallen out of my
> left ear, and I'd better finish this mail before regrasping it)

Yeah, it isn't enough. Too bad ->populate is implemented as it is,
so it can't take advantage of the generic race finding code in
memory.c (even though that isn't yet sufficient either ;)).

I don't think ->populate has ever particularly troubled itself with
these kinds of theoretical races. I was really hoping to fix linear
pagecache first before getting bogged down with nonlinear.

>> static int shmem_getpage(struct inode *inode, unsigned long idx,
>>@@ -1211,8 +1212,10 @@ repeat:
>> 	}
>> done:
>> 	if (*pagep != filepage) {
>>-		unlock_page(filepage);
>> 		*pagep = filepage;
>>+		if (sgp != SGP_NOPAGE)
>>+			unlock_page(filepage);
>>+
> 
> 
> You've inserted that blank line just to upset me.

I did. I was trying to sneak that one past you.

>>Index: linux-2.6/mm/mmap.c
>>===================================================================
>>--- linux-2.6.orig/mm/mmap.c	2006-07-26 18:00:47.000000000 +1000
>>+++ linux-2.6/mm/mmap.c	2006-07-31 16:03:58.000000000 +1000
>>@@ -1089,6 +1089,9 @@ munmap_back:
>> 			goto free_vma;
>> 	}
>> 
>>+	if (vma->vm_ops)
>>+		vma->vm_flags |= vma->vm_ops->vm_flags;
>>+
> 
> 
> Mmm, I'd prefer not to have this additional way of setting vm_flags.

OK fair enough. However, that's probably not the biggest issue I face.

After thinking about it a bit more, I think I've found my filemap_nopage
wanting. Suppose i_size is shrunk and the page truncated before the
first find_lock_page. OK, no we'll allocate a new page, add it to the
pagecache, and do a ->readpage().

readpage should notice we're reading outside i_size and zero fill it
(which seems like a silly thing to do, but it must be for a good reason,
Andrew? can we read holes past i_size? or is it for some awful ptrace
crud?)

Anyway, that is all expecting do_no_page to notice the truncation that
happened after we sampled i_size, and retry. But I removed the notice-
and-retry logic.

What should possibly be done is to recheck i_size under the page lock.

Regular invalidates (of the type we're trying to plug the hole in) are
fine, because they only ask that ->readpage be rerun after they complete.

Will think a bit more. Thanks for the input. I see Andrew's dropped it:
that's fine for now.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
