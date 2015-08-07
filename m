Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A6CF26B0255
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:52:25 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so50297477wic.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:52:25 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id op3si18263827wjc.25.2015.08.07.00.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 00:52:23 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so54714479wib.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:52:22 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz>
 <20150701061731.GB6286@dhcp22.suse.cz> <20150701133715.GA6287@dhcp22.suse.cz>
 <20150702142551.GB9456@thunk.org> <20150702151321.GE12547@dhcp22.suse.cz>
 <alpine.LSU.2.11.1508032227050.5070@eggly.anvils>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <55C463B4.2050904@kyup.com>
Date: Fri, 7 Aug 2015 10:52:20 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1508032227050.5070@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Marian Marinov <mm@1h.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

Hello Hugh,

On 08/04/2015 09:32 AM, Hugh Dickins wrote:
> Hi Michal,
> 
> On Thu, 2 Jul 2015, Michal Hocko wrote:
>> On Thu 02-07-15 10:25:51, Theodore Ts'o wrote:
>>> On Wed, Jul 01, 2015 at 03:37:15PM +0200, Michal Hocko wrote:
>> From: Michal Hocko <mhocko@suse.cz>
>> Date: Thu, 2 Jul 2015 17:05:05 +0200
>> Subject: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
>>  allocations
>>
>> Nikolay has reported a hang when a memcg reclaim got stuck with the
>> following backtrace...
> 
> Sorry, I couldn't manage more than to ignore you when you Cc'ed me on
> this a month ago.  Dave's perfectly correct, we had ourselves come to
> notice that recently: although in an ideal world a filesystem would
> only mark PageWriteback once the IO is all ready to go, in the real
> world that's not quite so, and a memory allocation may stand between.
> Which leaves my v3.6 c3b94f44fcb0 in danger of deadlocking.
> 
> And suddenly now, in v4.2-rc or perhaps in v4.1 also, that has started
> hitting me too (I don't know which release Nicolay noticed this on).
> And it has become urgent to fix: I've added Linus to the Cc because
> I believe his comment in the rc5 announcement, "There's also a pending
> question about some of the VM changes", reflects this.  Twice when I
> was trying to verify fixes to the dcache issue which came up at the
> end of last week, I was frustrated by unrelated hangs in my load.
> The first time I didn't recognize it, but the second time I did,
> and then came to realize that your patch is just what is needed.
> 
> But I have modified it a little, I don't think you'll mind.  As you
> suggested yourself, I actually prefer to test may_enter_fs there, rather
> than __GFP_FS: not a big deal, I certainly wouldn't want to delay the
> fix if someone thinks differently; but I tend to feel that may_enter_fs
> is what we already use for such decisions there, so better to use it.
> (And the SwapCache case immune to ext4 or xfs IO submission pattern.)
> 
> I've fixed up the patch and updated the comments, since Tejun has
> meanwhile introduced sane_reclaim(sc) - I'm staying on in the insane
> asylum for now (and sane_reclaim is clearly unaffected by the change).
> 
> I've omitted your hunk unindenting Case 3 wait_on_page_writeback(page):
> I prefer your style too, but thought it better to minimize the patch,
> especially if this is heading to the stables.  (I was tempted to add in
> my unlock_page there, that we discussed once before: but again thought
> it better to minimize the fix - it is "selfish" not to unlock_page,
> but I think that anything heading for deadlock on the locked page would
> in other circumstances be heading for deadlock on the writeback page -
> I've never found that change critical.)
> 
> And I've done quite a bit of testing.  The loads that hung at the
> weekend have been running nicely for 24 hours now, no problem with the
> writeback hang and no problem with the dcache ENOTDIR issue.  Though
> I've no idea of what recent VM change turned this into a hot issue.
> 

Are these production loads you are referring to that have been able to
reproduce the issue or are they some synthetic ones which? So far I
haven't been able to reproduce the issue using artifical loads so I'm
interested in incorporating this into my test set setup if it's available?

> And more testing on the history of it, considering your stable 3.6+
> designation that I wasn't satisfied with.  Getting out that USB stick
> again, I find that 3.6, 3.7 and 3.8 all OOM if their __GFP_IO test
> is updated to a may_enter_fs test; but something happened in 3.9
> to make it and subsequent releases safe with the may_enter_fs test.
> You can certainly argue that the remote chance of a deadlock is
> worse than the fair chance of a spurious OOM; but if you insist
> on 3.6+, then I think it would have to go back even further,
> because we marked that commit for stable itself.  I suggest 3.9+.
> 
> 
> [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS allocations
> 
> From: Michal Hocko <mhocko@suse.cz>
> 
> Nikolay has reported a hang when a memcg reclaim got stuck with the
> following backtrace:
> PID: 18308  TASK: ffff883d7c9b0a30  CPU: 1   COMMAND: "rsync"
>  #0 [ffff88177374ac60] __schedule at ffffffff815ab152
>  #1 [ffff88177374acb0] schedule at ffffffff815ab76e
>  #2 [ffff88177374acd0] schedule_timeout at ffffffff815ae5e5
>  #3 [ffff88177374ad70] io_schedule_timeout at ffffffff815aad6a
>  #4 [ffff88177374ada0] bit_wait_io at ffffffff815abfc6
>  #5 [ffff88177374adb0] __wait_on_bit at ffffffff815abda5
>  #6 [ffff88177374ae00] wait_on_page_bit at ffffffff8111fd4f
>  #7 [ffff88177374ae50] shrink_page_list at ffffffff81135445
>  #8 [ffff88177374af50] shrink_inactive_list at ffffffff81135845
>  #9 [ffff88177374b060] shrink_lruvec at ffffffff81135ead
>  #10 [ffff88177374b150] shrink_zone at ffffffff811360c3
>  #11 [ffff88177374b220] shrink_zones at ffffffff81136eff
>  #12 [ffff88177374b2a0] do_try_to_free_pages at ffffffff8113712f
>  #13 [ffff88177374b300] try_to_free_mem_cgroup_pages at ffffffff811372be
>  #14 [ffff88177374b380] try_charge at ffffffff81189423
>  #15 [ffff88177374b430] mem_cgroup_try_charge at ffffffff8118c6f5
>  #16 [ffff88177374b470] __add_to_page_cache_locked at ffffffff8112137d
>  #17 [ffff88177374b4e0] add_to_page_cache_lru at ffffffff81121618
>  #18 [ffff88177374b510] pagecache_get_page at ffffffff8112170b
>  #19 [ffff88177374b560] grow_dev_page at ffffffff811c8297
>  #20 [ffff88177374b5c0] __getblk_slow at ffffffff811c91d6
>  #21 [ffff88177374b600] __getblk_gfp at ffffffff811c92c1
>  #22 [ffff88177374b630] ext4_ext_grow_indepth at ffffffff8124565c
>  #23 [ffff88177374b690] ext4_ext_create_new_leaf at ffffffff81246ca8
>  #24 [ffff88177374b6e0] ext4_ext_insert_extent at ffffffff81246f09
>  #25 [ffff88177374b750] ext4_ext_map_blocks at ffffffff8124a848
>  #26 [ffff88177374b870] ext4_map_blocks at ffffffff8121a5b7
>  #27 [ffff88177374b910] mpage_map_one_extent at ffffffff8121b1fa
>  #28 [ffff88177374b950] mpage_map_and_submit_extent at ffffffff8121f07b
>  #29 [ffff88177374b9b0] ext4_writepages at ffffffff8121f6d5
>  #30 [ffff88177374bb20] do_writepages at ffffffff8112c490
>  #31 [ffff88177374bb30] __filemap_fdatawrite_range at ffffffff81120199
>  #32 [ffff88177374bb80] filemap_flush at ffffffff8112041c
>  #33 [ffff88177374bb90] ext4_alloc_da_blocks at ffffffff81219da1
>  #34 [ffff88177374bbb0] ext4_rename at ffffffff81229b91
>  #35 [ffff88177374bcd0] ext4_rename2 at ffffffff81229e32
>  #36 [ffff88177374bce0] vfs_rename at ffffffff811a08a5
>  #37 [ffff88177374bd60] SYSC_renameat2 at ffffffff811a3ffc
>  #38 [ffff88177374bf60] sys_renameat2 at ffffffff811a408e
>  #39 [ffff88177374bf70] sys_rename at ffffffff8119e51e
>  #40 [ffff88177374bf80] system_call_fastpath at ffffffff815afa89
> 
> Dave Chinner has properly pointed out that this is a deadlock in the
> reclaim code because ext4 doesn't submit pages which are marked by
> PG_writeback right away. The heuristic was introduced by e62e384e9da8
> ("memcg: prevent OOM with too many dirty pages") and it was applied
> only when may_enter_fs was specified. The code has been changed by
> c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
> which has removed the __GFP_FS restriction with a reasoning that we
> do not get into the fs code. But this is not sufficient apparently
> because the fs doesn't necessarily submit pages marked PG_writeback
> for IO right away.
> 
> ext4_bio_write_page calls io_submit_add_bh but that doesn't necessarily
> submit the bio. Instead it tries to map more pages into the bio and
> mpage_map_one_extent might trigger memcg charge which might end up
> waiting on a page which is marked PG_writeback but hasn't been submitted
> yet so we would end up waiting for something that never finishes.
> 
> Fix this issue by replacing __GFP_IO by may_enter_fs check (for case 2)
> before we go to wait on the writeback. The page fault path, which is the
> only path that triggers memcg oom killer since 3.12, shouldn't require
> GFP_NOFS and so we shouldn't reintroduce the premature OOM killer issue
> which was originally addressed by the heuristic.
> 
> As per David Chinner the xfs is doing similar thing since 2.6.15 already
> so ext4 is not the only affected filesystem. Moreover he notes:
> : For example: IO completion might require unwritten extent conversion
> : which executes filesystem transactions and GFP_NOFS allocations. The
> : writeback flag on the pages can not be cleared until unwritten
> : extent conversion completes. Hence memory reclaim cannot wait on
> : page writeback to complete in GFP_NOFS context because it is not
> : safe to do so, memcg reclaim or otherwise.
> 
> Cc: stable@vger.kernel.org # 3.9+
> [tytso@mit.edu: corrected the control flow]
> Fixes: c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
> Reported-by: Nikolay Borisov <kernel@kyup.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/vmscan.c |   16 ++++++----------
>  1 file changed, 6 insertions(+), 10 deletions(-)
> 
> --- 4.2-rc5/mm/vmscan.c	2015-07-05 19:25:02.856131170 -0700
> +++ linux/mm/vmscan.c	2015-08-02 21:24:03.000614050 -0700
> @@ -973,22 +973,18 @@ static unsigned long shrink_page_list(st
>  		 *    caller can stall after page list has been processed.
>  		 *
>  		 * 2) Global or new memcg reclaim encounters a page that is
> -		 *    not marked for immediate reclaim or the caller does not
> -		 *    have __GFP_IO. In this case mark the page for immediate
> +		 *    not marked for immediate reclaim, or the caller does not
> +		 *    have __GFP_FS (or __GFP_IO if it's simply going to swap,
> +		 *    not to fs). In this case mark the page for immediate
>  		 *    reclaim and continue scanning.
>  		 *
> -		 *    __GFP_IO is checked  because a loop driver thread might
> +		 *    Require may_enter_fs because we would wait on fs, which
> +		 *    may not have submitted IO yet. And the loop driver might
>  		 *    enter reclaim, and deadlock if it waits on a page for
>  		 *    which it is needed to do the write (loop masks off
>  		 *    __GFP_IO|__GFP_FS for this reason); but more thought
>  		 *    would probably show more reasons.
>  		 *
> -		 *    Don't require __GFP_FS, since we're not going into the
> -		 *    FS, just waiting on its writeback completion. Worryingly,
> -		 *    ext4 gfs2 and xfs allocate pages with
> -		 *    grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so testing
> -		 *    may_enter_fs here is liable to OOM on them.
> -		 *
>  		 * 3) Legacy memcg encounters a page that is not already marked
>  		 *    PageReclaim. memcg does not have any dirty pages
>  		 *    throttling so we could easily OOM just because too many
> @@ -1005,7 +1001,7 @@ static unsigned long shrink_page_list(st
>  
>  			/* Case 2 above */
>  			} else if (sane_reclaim(sc) ||
> -			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
> +			    !PageReclaim(page) || !may_enter_fs) {
>  				/*
>  				 * This is slightly racy - end_page_writeback()
>  				 * might have just cleared PageReclaim, then
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
