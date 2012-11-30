Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 8F8B06B00A3
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:03:49 -0500 (EST)
Date: Fri, 30 Nov 2012 16:03:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121130150347.GJ29317@dhcp22.suse.cz>
References: <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130144431.GI29317@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 15:44:31, Michal Hocko wrote:
> On Fri 30-11-12 14:44:27, azurIt wrote:
> > >Anyway your system is under both global and local memory pressure. You
> > >didn't see apache going down previously because it was probably the one
> > >which was stuck and could be killed.
> > >Anyway you need to setup your system more carefully.
> > 
> > 
> > There is, also, an evidence that system has enough of memory! :) Just
> > take column 'rss' from process list in OOM message and sum it - you
> > will get 2489911. It's probably in KB so it's about 2.4 GB. System has
> > 14 GB of RAM so this also match data on my graph - 2.4 is about 17% of
> > 14.
> 
> Hmm, that corresponds to the ZONE_DMA32 size pretty nicely but that zone
> is hardly touched:
> Nov 30 02:53:56 server01 kernel: [  818.241291] DMA32 free:2523636kB min:2672kB low:3340kB high:4008kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2542248kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> 
> DMA32 zone is usually fills up first 4G unless your HW remaps the rest
> of the memory above 4G or you have a numa machine and the rest of the
> memory is at other node. Could you post your memory map printed during
> the boot? (e820: BIOS-provided physical RAM map: and following lines)
> 
> There is also ZONE_NORMAL which is also not used much
> Nov 30 02:53:56 server01 kernel: [  818.242163] Normal free:6924716kB min:12512kB low:15640kB high:18768kB active_anon:1463128kB inactive_anon:2072kB active_file:1803964kB inactive_file:1072628kB unevictable:3924kB isolated(anon):0kB isolated(file):0kB present:11893760kB mlocked:3924kB dirty:1000kB writeback:776kB mapped:35656kB shmem:3828kB slab_reclaimable:202560kB slab_unreclaimable:50696kB kernel_stack:2944kB pagetables:158616kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> 
> You have mentioned that you are comounting with cpuset. If this happens
> to be a NUMA machine have you made the access to all nodes available?

And now that I am looking at the oom message more closely I can see
Nov 30 02:53:56 server01 kernel: [  818.232812] apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
Nov 30 02:53:56 server01 kernel: [  818.233029] apache2 cpuset=uid mems_allowed=0
Nov 30 02:53:56 server01 kernel: [  818.233159] Pid: 9247, comm: apache2 Not tainted 3.2.34-grsec #1
Nov 30 02:53:56 server01 kernel: [  818.233289] Call Trace:
Nov 30 02:53:56 server01 kernel: [  818.233470]  [<ffffffff810cc90e>] dump_header+0x7e/0x1e0
Nov 30 02:53:56 server01 kernel: [  818.233600]  [<ffffffff810cc80f>] ? find_lock_task_mm+0x2f/0x70
Nov 30 02:53:56 server01 kernel: [  818.233721]  [<ffffffff810ccdd5>] oom_kill_process+0x85/0x2a0
Nov 30 02:53:56 server01 kernel: [  818.233842]  [<ffffffff810cd485>] out_of_memory+0xe5/0x200
Nov 30 02:53:56 server01 kernel: [  818.233963]  [<ffffffff8102aa8f>] ? pte_alloc_one+0x3f/0x50
Nov 30 02:53:56 server01 kernel: [  818.234082]  [<ffffffff810cd65d>] pagefault_out_of_memory+0xbd/0x110
Nov 30 02:53:56 server01 kernel: [  818.234204]  [<ffffffff81026ec6>] mm_fault_error+0xb6/0x1a0
Nov 30 02:53:56 server01 kernel: [  818.235886]  [<ffffffff8102739e>] do_page_fault+0x3ee/0x460
Nov 30 02:53:56 server01 kernel: [  818.236006]  [<ffffffff810f3057>] ? vma_merge+0x1f7/0x2c0
Nov 30 02:53:56 server01 kernel: [  818.236124]  [<ffffffff810f35d7>] ? do_brk+0x267/0x400
Nov 30 02:53:56 server01 kernel: [  818.236244]  [<ffffffff812c9a92>] ? gr_learn_resource+0x42/0x1e0
Nov 30 02:53:56 server01 kernel: [  818.236367]  [<ffffffff815b547f>] page_fault+0x1f/0x30

Which is interesting from 2 perspectives. Only the first node (Node-0)
is allowed which would suggest that the cpuset controller is not
configured to all nodes. It is still surprising Node 0 wouldn't have any
memory (I would expect ZONE_DMA32 would be sitting there).

Anyway, the more interesting thing is gfp_mask is GFP_NOWAIT allocation
from the page fault? Huh this shouldn't happen - ever.

> Also what does /proc/sys/vm/zone_reclaim_mode says?
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
