Message-ID: <46393BA7.6030106@yahoo.com.au>
Date: Thu, 03 May 2007 11:32:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
Content-Type: multipart/mixed;
 boundary="------------060404090201060607020705"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060404090201060607020705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:
> On Wed, 2 May 2007, Nick Piggin wrote:

[snip]

> More on-topic, since you suggest doing more within vmtruncate_range
> than the filesystem: no, I'm afraid that's misdesigned, and I want
> to move almost all of it into the filesystem ->truncate_range.
> Because, if what vmtruncate_range is doing before it gets to the
> filesystem isn't to be just a waste of time, the filesystem needs
> to know what's going on in advance - just as notify_change warns
> the filesystem about a coming truncation.  But easier than inventing
> some new notification is to move it all into the filesystem, with
> unmap_mapping_range+truncate_inode_pages_range its library helpers.

Well I would prefer it to follow the same pattern as regular
truncate. I don't think it is misdesigned to call the filesystem
_first_, but I think if you do that then the filesystem should
call the vm to prepare / finish truncate, rather than open code
calls to unmap itself.


>>>But I'm pretty sure (to use your words!) regular truncate was not racy
>>>before: I believe Andrea's sequence count was handling that case fine,
>>>without a second unmap_mapping_range.
>>
>>OK, I think you're right. I _think_ it should also be OK with the
>>lock_page version as well: we should not be able to have any pages
>>after the first unmap_mapping_range call, because of the i_size
>>write. So if we have no pages, there is nothing to 'cow' from.
> 
> 
> I'd be delighted if you can remove those later unmap_mapping_ranges.
> As I recall, the important thing for the copy pages is to be holding
> the page lock (or whatever other serialization) on the copied page
> still while the copy page is inserted into pagetable: that looks
> to be so in your __do_fault.

Yeah, I think my thought process went wrong on those... I'll
revisit.


>>>But it is a shame, and leaves me wondering what you gained with the
>>>page lock there.
>>>
>>>One thing gained is ease of understanding, and if your later patches
>>>build an edifice upon the knowledge of holding that page lock while
>>>faulting, I've no wish to undermine that foundation.
>>
>>It also fixes a bug, doesn't it? ;)
> 
> 
> Well, I'd come to think that perhaps the bugs would be solved by
> that second unmap_mapping_range alone, so the pagelock changes
> just a misleading diversion.
> 
> I'm not sure how I feel about that: calling unmap_mapping_range a
> second time feels such a cheat, but if (big if) it does solve the
> races, and the pagelock method is as expensive as your numbers
> now suggest...

Well aside from being terribly ugly, it means we can still drop
the dirty bit where we'd otherwise rather not, so I don't think
we can do that.

I think there may be some way we can do this without taking the
page lock, and I was going to look at it, but I think it is
quite neat to just lock the page...

I don't think performance is _that_ bad. On the P4 it is a couple
of % on the microbenchmarks. The G5 is worse, but even then I
don't think it is I'll try to improve that and get back to you.

The problem is that lock/unlock_page is expensive on powerpc, and
if we improve that, we improve more than just the fault handler...

The attached patch gets performance up a bit by avoiding some
barriers and some cachelines:

G5
          pagefault   fork          exec
2.6.21   1.49-1.51   164.6-170.8   741.8-760.3
+patch   1.71-1.73   175.2-180.8   780.5-794.2
+patch2  1.61-1.63   169.8-175.0   748.6-757.0

So that brings the fork/exec hits down to much less than 5%, and
would likely speed up other things that lock the page, like write
or page reclaim.

I think we could get further performance improvement by
implementing arch specific bitops for lock/unlock operations,
so we don't need to use things like smb_mb__before_clear_bit()
if they aren't needed or full barriers in the test_and_set_bit().

-- 
SUSE Labs, Novell Inc.


--------------060404090201060607020705
Content-Type: text/plain;
 name="mm-unlock-speedup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-unlock-speedup.patch"

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-04-24 10:39:56.000000000 +1000
+++ linux-2.6/include/linux/page-flags.h	2007-05-03 08:38:53.000000000 +1000
@@ -91,6 +91,8 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_waiters		20	/* Page has PG_locked waiters */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-04-24 10:39:56.000000000 +1000
+++ linux-2.6/include/linux/pagemap.h	2007-05-03 08:35:08.000000000 +1000
@@ -141,7 +141,7 @@
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (unlikely(TestSetPageLocked(page)))
 		__lock_page(page);
 }
 
@@ -152,7 +152,7 @@
 static inline void lock_page_nosync(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (unlikely(TestSetPageLocked(page)))
 		__lock_page_nosync(page);
 }
 	
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-05-02 15:00:26.000000000 +1000
+++ linux-2.6/mm/filemap.c	2007-05-03 08:34:32.000000000 +1000
@@ -532,11 +532,13 @@
  */
 void fastcall unlock_page(struct page *page)
 {
+	VM_BUG_ON(!PageLocked(page));
 	smp_mb__before_clear_bit();
-	if (!TestClearPageLocked(page))
-		BUG();
-	smp_mb__after_clear_bit(); 
-	wake_up_page(page, PG_locked);
+	ClearPageLocked(page);
+	if (unlikely(test_bit(PG_waiters, &page->flags))) {
+		clear_bit(PG_waiters, &page->flags);
+		wake_up_page(page, PG_locked);
+	}
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -568,6 +570,11 @@
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
+	set_bit(PG_waiters, &page->flags);
+	if (unlikely(!TestSetPageLocked(page))) {
+		clear_bit(PG_waiters, &page->flags);
+		return;
+	}
 	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
 }

--------------060404090201060607020705--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
