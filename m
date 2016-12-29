Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37E96B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 19:32:04 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so572843376pfx.1
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 16:32:04 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u22si26876094plj.70.2016.12.28.16.32.03
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 16:32:03 -0800 (PST)
Date: Thu, 29 Dec 2016 09:31:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161229003154.GA15160@bbox>
References: <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
 <20161223222559.GA5568@teela.multi.box>
 <20161226124839.GB20715@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226124839.GB20715@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Mon, Dec 26, 2016 at 01:48:40PM +0100, Michal Hocko wrote:
> On Fri 23-12-16 23:26:00, Nils Holland wrote:
> > On Fri, Dec 23, 2016 at 03:47:39PM +0100, Michal Hocko wrote:
> > > 
> > > Nils, even though this is still highly experimental, could you give it a
> > > try please?
> > 
> > Yes, no problem! So I kept the very first patch you sent but had to
> > revert the latest version of the debugging patch (the one in
> > which you added the "mm_vmscan_inactive_list_is_low" event) because
> > otherwise the patch you just sent wouldn't apply. Then I rebooted with
> > memory cgroups enabled again, and the first thing that strikes the eye
> > is that I get this during boot:
> > 
> > [    1.568174] ------------[ cut here ]------------
> > [    1.568327] WARNING: CPU: 0 PID: 1 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0x118/0x130
> > [    1.568543] mem_cgroup_update_lru_size(f4406400, 2, 1): lru_size 0 but not empty
> 
> Ohh, I can see what is wrong! a) there is a bug in the accounting in
> my patch (I double account) and b) the detection for the empty list
> cannot work after my change because per node zone will not match per
> zone statistics. The updated patch is below. So I hope my brain already
> works after it's been mostly off last few days...
> ---
> From 397adf46917b2d9493180354a7b0182aee280a8b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 23 Dec 2016 15:11:54 +0100
> Subject: [PATCH] mm, memcg: fix the active list aging for lowmem requests when
>  memcg is enabled
> 
> Nils Holland has reported unexpected OOM killer invocations with 32b
> kernel starting with 4.8 kernels
> 
> 	kworker/u4:5 invoked oom-killer: gfp_mask=0x2400840(GFP_NOFS|__GFP_NOFAIL), nodemask=0, order=0, oom_score_adj=0
> 	kworker/u4:5 cpuset=/ mems_allowed=0
> 	CPU: 1 PID: 2603 Comm: kworker/u4:5 Not tainted 4.9.0-gentoo #2
> 	[...]
> 	Mem-Info:
> 	active_anon:58685 inactive_anon:90 isolated_anon:0
> 	 active_file:274324 inactive_file:281962 isolated_file:0
> 	 unevictable:0 dirty:649 writeback:0 unstable:0
> 	 slab_reclaimable:40662 slab_unreclaimable:17754
> 	 mapped:7382 shmem:202 pagetables:351 bounce:0
> 	 free:206736 free_pcp:332 free_cma:0
> 	Node 0 active_anon:234740kB inactive_anon:360kB active_file:1097296kB inactive_file:1127848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:29528kB dirty:2596kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 184320kB anon_thp: 808kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
> 	DMA free:3952kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:7316kB inactive_file:0kB unevictable:0kB writepending:96kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:3200kB slab_unreclaimable:1408kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> 	lowmem_reserve[]: 0 813 3474 3474
> 	Normal free:41332kB min:41368kB low:51708kB high:62048kB active_anon:0kB inactive_anon:0kB active_file:532748kB inactive_file:44kB unevictable:0kB writepending:24kB present:897016kB managed:836248kB mlocked:0kB slab_reclaimable:159448kB slab_unreclaimable:69608kB kernel_stack:1112kB pagetables:1404kB bounce:0kB free_pcp:528kB local_pcp:340kB free_cma:0kB
> 	lowmem_reserve[]: 0 0 21292 21292
> 	HighMem free:781660kB min:512kB low:34356kB high:68200kB active_anon:234740kB inactive_anon:360kB active_file:557232kB inactive_file:1127804kB unevictable:0kB writepending:2592kB present:2725384kB managed:2725384kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:800kB local_pcp:608kB free_cma:0kB
> 
> the oom killer is clearly pre-mature because there there is still a
> lot of page cache in the zone Normal which should satisfy this lowmem
> request. Further debugging has shown that the reclaim cannot make any
> forward progress because the page cache is hidden in the active list
> which doesn't get rotated because inactive_list_is_low is not memcg
> aware.
> It simply subtracts per-zone highmem counters from the respective
> memcg's lru sizes which doesn't make any sense. We can simply end up
> always seeing the resulting active and inactive counts 0 and return
> false. This issue is not limited to 32b kernels but in practice the
> effect on systems without CONFIG_HIGHMEM would be much harder to notice
> because we do not invoke the OOM killer for allocations requests
> targeting < ZONE_NORMAL.
> 
> Fix the issue by tracking per zone lru page counts in mem_cgroup_per_node
> and subtract per-memcg highmem counts when memcg is enabled. Introduce
> helper lruvec_zone_lru_size which redirects to either zone counters or
> mem_cgroup_get_zone_lru_size when appropriate.
> 
> We are loosing empty LRU but non-zero lru size detection introduced by
> ca707239e8a7 ("mm: update_lru_size warn and reset bad lru_size") because
> of the inherent zone vs. node discrepancy.
> 
> Fixes: f8d1a31163fc ("mm: consider whether to decivate based on eligible zones inactive ratio")
> Cc: stable # 4.8+
> Reported-by: Nils Holland <nholland@tisys.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
