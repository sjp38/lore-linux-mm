Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DADAA6B02C2
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:41:49 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so10453536wjb.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:41:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q80si30284wmg.80.2017.01.19.10.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 10:41:48 -0800 (PST)
Date: Thu, 19 Jan 2017 13:41:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20170119184133.GA18735@cmpxchg.org>
References: <20161220134904.21023-1-mhocko@kernel.org>
 <20161220134904.21023-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220134904.21023-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 20, 2016 at 02:49:03PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> the allocation request. This includes lowmem requests, costly high
> order requests and others. For a long time __GFP_NOFAIL acted as an
> override for all those rules. This is not documented and it can be quite
> surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> the existing open coded loops around allocator to nofail request (and we
> have done that in the past) then such a change would have a non trivial
> side effect which is far from obvious. Note that the primary motivation
> for skipping the OOM killer is to prevent from pre-mature invocation.
> 
> The exception has been added by 82553a937f12 ("oom: invoke oom killer
> for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> be invoked otherwise the request would be looping for ever. But this
> argument is rather weak because the OOM killer doesn't really guarantee
> a forward progress for those exceptional cases:
> 	- it will hardly help to form costly order which in turn can
> 	  result in the system panic because of no oom killable task in
> 	  the end - I believe we certainly do not want to put the system
> 	  down just because there is a nasty driver asking for order-9
> 	  page with GFP_NOFAIL not realizing all the consequences. It is
> 	  much better this request would loop for ever than the massive
> 	  system disruption
> 	- lowmem is also highly unlikely to be freed during OOM killer
> 	- GFP_NOFS request could trigger while there is still a lot of
> 	  memory pinned by filesystems.
> 
> The pre-mature OOM killer is a real issue as reported by Nils Holland
> 	kworker/u4:5 invoked oom-killer: gfp_mask=0x2400840(GFP_NOFS|__GFP_NOFAIL), nodemask=0, order=0, oom_score_adj=0
> 	kworker/u4:5 cpuset=/ mems_allowed=0
> 	CPU: 1 PID: 2603 Comm: kworker/u4:5 Not tainted 4.9.0-gentoo #2
> 	Hardware name: Hewlett-Packard Compaq 15 Notebook PC/21F7, BIOS F.22 08/06/2014
> 	Workqueue: writeback wb_workfn (flush-btrfs-1)
> 	 eff0b604 c142bcce eff0b734 00000000 eff0b634 c1163332 00000000 00000292
> 	 eff0b634 c1431876 eff0b638 e7fb0b00 e7fa2900 e7fa2900 c1b58785 eff0b734
> 	 eff0b678 c110795f c1043895 eff0b664 c11075c7 00000007 00000000 00000000
> 	Call Trace:
> 	 [<c142bcce>] dump_stack+0x47/0x69
> 	 [<c1163332>] dump_header+0x60/0x178
> 	 [<c1431876>] ? ___ratelimit+0x86/0xe0
> 	 [<c110795f>] oom_kill_process+0x20f/0x3d0
> 	 [<c1043895>] ? has_capability_noaudit+0x15/0x20
> 	 [<c11075c7>] ? oom_badness.part.13+0xb7/0x130
> 	 [<c1107df9>] out_of_memory+0xd9/0x260
> 	 [<c110ba0b>] __alloc_pages_nodemask+0xbfb/0xc80
> 	 [<c110414d>] pagecache_get_page+0xad/0x270
> 	 [<c13664a6>] alloc_extent_buffer+0x116/0x3e0
> 	 [<c1334a2e>] btrfs_find_create_tree_block+0xe/0x10
> 	[...]
> 	Normal free:41332kB min:41368kB low:51708kB high:62048kB active_anon:0kB inactive_anon:0kB active_file:532748kB inactive_file:44kB unevictable:0kB writepending:24kB present:897016kB managed:836248kB mlocked:0kB slab_reclaimable:159448kB slab_unreclaimable:69608kB kernel_stack:1112kB pagetables:1404kB bounce:0kB free_pcp:528kB local_pcp:340kB free_cma:0kB
> 	lowmem_reserve[]: 0 0 21292 21292
> 	HighMem free:781660kB min:512kB low:34356kB high:68200kB active_anon:234740kB inactive_anon:360kB active_file:557232kB inactive_file:1127804kB unevictable:0kB writepending:2592kB present:2725384kB managed:2725384kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:800kB local_pcp:608kB free_cma:0kB
> 
> this is a GFP_NOFS|__GFP_NOFAIL request which invokes the OOM killer
> because there is clearly nothing reclaimable in the zone Normal while
> there is a lot of page cache which is most probably pinned by the fs but
> GFP_NOFS cannot reclaim it.
> 
> This patch simply removes the __GFP_NOFAIL special case in order to have
> a more clear semantic without surprising side effects.
> 
> Reported-by: Nils Holland <nholland@tisys.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
