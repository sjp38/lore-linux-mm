Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 2F19F6B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 07:31:50 -0500 (EST)
Date: Thu, 7 Feb 2013 13:31:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130207123140.GA15820@dhcp22.suse.cz>
References: <20121230020947.AA002F34@pobox.sk>
 <20121230110815.GA12940@dhcp22.suse.cz>
 <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <20130206021721.1AE9E3C7@pobox.sk>
 <20130206140119.GD10254@dhcp22.suse.cz>
 <51138999.3090006@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51138999.3090006@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 07-02-13 20:01:45, KAMEZAWA Hiroyuki wrote:
> (2013/02/06 23:01), Michal Hocko wrote:
> >On Wed 06-02-13 02:17:21, azurIt wrote:
> >>>5-memcg-fix-1.patch is not complete. It doesn't contain the folloup I
> >>>mentioned in a follow up email. Here is the full patch:
> >>
> >>
> >>Here is the log where OOM, again, killed MySQL server [search for "(mysqld)"]:
> >>http://www.watchdog.sk/lkml/oom_mysqld6
> >
> >[...]
> >WARNING: at mm/memcontrol.c:2409 T.1149+0x2d9/0x610()
> >Hardware name: S5000VSA
> >gfp_mask:4304 nr_pages:1 oom:0 ret:2
> >Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
> >Call Trace:
> >  [<ffffffff8105502a>] warn_slowpath_common+0x7a/0xb0
> >  [<ffffffff81055116>] warn_slowpath_fmt+0x46/0x50
> >  [<ffffffff81108163>] ? mem_cgroup_margin+0x73/0xa0
> >  [<ffffffff8110b6f9>] T.1149+0x2d9/0x610
> >  [<ffffffff812af298>] ? blk_finish_plug+0x18/0x50
> >  [<ffffffff8110c6b4>] mem_cgroup_cache_charge+0xc4/0xf0
> >  [<ffffffff810ca6bf>] add_to_page_cache_locked+0x4f/0x140
> >  [<ffffffff810ca7d2>] add_to_page_cache_lru+0x22/0x50
> >  [<ffffffff810cad32>] filemap_fault+0x252/0x4f0
> >  [<ffffffff810eab18>] __do_fault+0x78/0x5a0
> >  [<ffffffff810edcb4>] handle_pte_fault+0x84/0x940
> >  [<ffffffff810e2460>] ? vma_prio_tree_insert+0x30/0x50
> >  [<ffffffff810f2508>] ? vma_link+0x88/0xe0
> >  [<ffffffff810ee6a8>] handle_mm_fault+0x138/0x260
> >  [<ffffffff8102709d>] do_page_fault+0x13d/0x460
> >  [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
> >  [<ffffffff815b61ff>] page_fault+0x1f/0x30
> >---[ end trace 8817670349022007 ]---
> >apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
> >apache2 cpuset=uid mems_allowed=0
> >Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
> >Call Trace:
> >  [<ffffffff810ccd2e>] dump_header+0x7e/0x1e0
> >  [<ffffffff810ccc2f>] ? find_lock_task_mm+0x2f/0x70
> >  [<ffffffff810cd1f5>] oom_kill_process+0x85/0x2a0
> >  [<ffffffff810cd8a5>] out_of_memory+0xe5/0x200
> >  [<ffffffff810cda7d>] pagefault_out_of_memory+0xbd/0x110
> >  [<ffffffff81026e76>] mm_fault_error+0xb6/0x1a0
> >  [<ffffffff8102734e>] do_page_fault+0x3ee/0x460
> >  [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
> >  [<ffffffff815b61ff>] page_fault+0x1f/0x30
> >
> >The first trace comes from the debugging WARN and it clearly points to
> >a file fault path. __do_fault pre-charges a page in case we need to
> >do CoW (copy-on-write) for the returned page. This one falls back to
> >memcg OOM and never returns ENOMEM as I have mentioned earlier.
> >However, the fs fault handler (filemap_fault here) can fallback to
> >page_cache_read if the readahead (do_sync_mmap_readahead) fails
> >to get page to the page cache. And we can see this happening in
> >the first trace. page_cache_read then calls add_to_page_cache_lru
> >and eventually gets to add_to_page_cache_locked which calls
> >mem_cgroup_cache_charge_no_oom so we will get ENOMEM if oom should
> >happen. This ENOMEM gets to the fault handler and kaboom.
> >
> 
> Hmm. do we need to increase the "limit" virtually at memcg oom until
> the oom-killed process dies ? It may be doable by increasing stock->cache
> of each cpu....I think kernel can offer extra virtual charge up to
> oom-killed process's memory usage.....

If we can guarantee that the overflow charges do not exceed the memory
usage of the killed process then this would work. The question is, how
do we find out how much we can overflow. immigrate_on_move will play
some role as well as the amount of the shared memory. I am afraid this
would get too complex. Nevertheless the idea is nice.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
