Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C513E6B0435
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 01:37:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g2so97516858pge.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:37:27 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a5si5504945pgi.377.2017.03.08.22.37.26
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 22:37:26 -0800 (PST)
Date: Thu, 9 Mar 2017 15:37:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 08/11] mm: make ttu's return boolean
Message-ID: <20170309063721.GC854@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-9-git-send-email-minchan@kernel.org>
 <70f60783-e098-c1a9-11b4-544530bcd809@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70f60783-e098-c1a9-11b4-544530bcd809@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi John,

On Tue, Mar 07, 2017 at 11:13:26PM -0800, John Hubbard wrote:
> On 03/01/2017 10:39 PM, Minchan Kim wrote:
> >try_to_unmap returns SWAP_SUCCESS or SWAP_FAIL so it's suitable for
> >boolean return. This patch changes it.
> 
> Hi Minchan,
> 
> So, up until this patch, I definitely like the cleanup, because as you
> observed, the return values didn't need so many different values. However,
> at this point, I think you should stop, and keep the SWAP_SUCCESS and
> SWAP_FAIL (or maybe even rename them to UNMAP_* or TTU_RESULT_*, to match
> their functions' names better), because removing them makes the code
> considerably less readable.
> 
> And since this is billed as a cleanup, we care here, even though this is a
> minor point. :)
> 
> Bool return values are sometimes perfect, such as when asking a question:
> 
>    bool mode_changed = needs_modeset(crtc_state);
> 
> The above is very nice. However, for returning success or failure, bools are
> not as nice, because *usually* success == true, except when you use the
> errno-based system, in which success == 0 (which would translate to false,
> if you mistakenly treated it as a bool). That leads to the reader having to
> remember which system is in use, usually with no visual cues to help.

I think it's the matter of taste.

        if (try_to_unmap(xxx))
                something
        else
                something

It's perfectly understandable to me. IOW, if try_to_unmap returns true,
it means it did unmap successfully. Otherwise, failed.

IMHO, SWAP_SUCCESS or TTU_RESULT_* seems to be an over-engineering.
If the user want it, user can do it by introducing right variable name
in his context. See below.

> 
> >
> [...]
> > 	if (PageSwapCache(p)) {
> >@@ -971,7 +971,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> > 		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);
> >
> > 	ret = try_to_unmap(hpage, ttu);
> >-	if (ret != SWAP_SUCCESS)
> >+	if (!ret)
> > 		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
> > 		       pfn, page_mapcount(hpage));
> >
> >@@ -986,8 +986,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> > 	 * any accesses to the poisoned memory.
> > 	 */
> > 	forcekill = PageDirty(hpage) || (flags & MF_MUST_KILL);
> >-	kill_procs(&tokill, forcekill, trapno,
> >-		      ret != SWAP_SUCCESS, p, pfn, flags);
> >+	kill_procs(&tokill, forcekill, trapno, !ret , p, pfn, flags);
> 
> The kill_procs() invocation was a little more readable before.

Indeed but I think it's not a problem of try_to_unmap but ret variable name
isn't good any more. How about this?

        bool unmap_success;

        unmap_success = try_to_unmap(hpage, ttu);

        ..

        kill_procs(&tokill, forcekill, trapno, !unmap_success , p, pfn, flags);

        ..

        return unmap_success;

My point is user can introduce whatever variable name depends on his
context. No need to make return variable complicated, IMHO.

> 
> >
> [...]
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 170c61f..e4b74f1 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -966,7 +966,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > 		int may_enter_fs;
> > 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
> > 		bool dirty, writeback;
> >-		int ret = SWAP_SUCCESS;
> >
> > 		cond_resched();
> >
> >@@ -1139,13 +1138,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > 		 * processes. Try to unmap it here.
> > 		 */
> > 		if (page_mapped(page)) {
> >-			switch (ret = try_to_unmap(page,
> >-				ttu_flags | TTU_BATCH_FLUSH)) {
> >-			case SWAP_FAIL:
> 
> Again: the SWAP_FAIL makes it crystal clear which case we're in.

To me, I don't feel it.
To me, below is perfectly understandable.

        if (try_to_unmap())
                do something
 
That's why I think it's matter of taste. Okay, I admit I might be
biased, too so I will consider what you suggested if others votes
it.

Thanks.

> 
> I also wonder if UNMAP_FAIL or TTU_RESULT_FAIL is a better name?
> 
> thanks,
> John Hubbard
> NVIDIA
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
