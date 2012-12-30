Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 934756B006C
	for <linux-mm@kvack.org>; Sun, 30 Dec 2012 06:08:18 -0500 (EST)
Date: Sun, 30 Dec 2012 12:08:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121230110815.GA12940@dhcp22.suse.cz>
References: <20121210155205.GB6777@dhcp22.suse.cz>
 <20121217023430.5A390FD7@pobox.sk>
 <20121217163203.GD25432@dhcp22.suse.cz>
 <20121217192301.829A7020@pobox.sk>
 <20121217195510.GA16375@dhcp22.suse.cz>
 <20121218152223.6912832C@pobox.sk>
 <20121218152004.GA25208@dhcp22.suse.cz>
 <20121224142526.020165D3@pobox.sk>
 <20121228162209.GA1455@dhcp22.suse.cz>
 <20121230020947.AA002F34@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121230020947.AA002F34@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 30-12-12 02:09:47, azurIt wrote:
> >which suggests that the patch is incomplete and that I am blind :/
> >mem_cgroup_cache_charge calls __mem_cgroup_try_charge for the page cache
> >and that one doesn't check GFP_MEMCG_NO_OOM. So you need the following
> >follow-up patch on top of the one you already have (which should catch
> >all the remaining cases).
> >Sorry about that...
> 
> 
> This was, again, killing my MySQL server (search for "(mysqld)"):
> http://www.watchdog.sk/lkml/oom_mysqld5

grep "Kill process" oom_mysqld5 
Dec 30 01:53:34 server01 kernel: [  367.061801] Memory cgroup out of memory: Kill process 5512 (apache2) score 716 or sacrifice child
Dec 30 01:53:35 server01 kernel: [  367.338024] Memory cgroup out of memory: Kill process 5517 (apache2) score 718 or sacrifice child
Dec 30 01:53:35 server01 kernel: [  367.747888] Memory cgroup out of memory: Kill process 5513 (apache2) score 721 or sacrifice child
Dec 30 01:53:36 server01 kernel: [  368.159860] Memory cgroup out of memory: Kill process 5516 (apache2) score 726 or sacrifice child
Dec 30 01:53:36 server01 kernel: [  368.665606] Memory cgroup out of memory: Kill process 5520 (apache2) score 733 or sacrifice child
Dec 30 01:53:36 server01 kernel: [  368.765652] Out of memory: Kill process 1778 (mysqld) score 39 or sacrifice child
Dec 30 01:53:36 server01 kernel: [  369.101753] Memory cgroup out of memory: Kill process 5519 (apache2) score 754 or sacrifice child
Dec 30 01:53:37 server01 kernel: [  369.464262] Memory cgroup out of memory: Kill process 5583 (apache2) score 762 or sacrifice child
Dec 30 01:53:37 server01 kernel: [  369.465017] Out of memory: Kill process 5506 (apache2) score 18 or sacrifice child
Dec 30 01:53:37 server01 kernel: [  369.574932] Memory cgroup out of memory: Kill process 5523 (apache2) score 759 or sacrifice child

So your mysqld has been killed by the global OOM not memcg. But why when
you seem to be perfectly fine regarding memory? I guess the following
backtrace is relevant:
Dec 30 01:53:36 server01 kernel: [  368.569720] DMA: 0*4kB 1*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15912kB
Dec 30 01:53:36 server01 kernel: [  368.570447] DMA32: 9*4kB 10*8kB 8*16kB 6*32kB 5*64kB 6*128kB 4*256kB 2*512kB 3*1024kB 3*2048kB 613*4096kB = 2523636kB
Dec 30 01:53:36 server01 kernel: [  368.571175] Normal: 5*4kB 2060*8kB 4122*16kB 2550*32kB 2667*64kB 722*128kB 197*256kB 68*512kB 15*1024kB 4*2048kB 1855*4096kB = 8134036kB
Dec 30 01:53:36 server01 kernel: [  368.571906] 308964 total pagecache pages
Dec 30 01:53:36 server01 kernel: [  368.572023] 0 pages in swap cache
Dec 30 01:53:36 server01 kernel: [  368.572140] Swap cache stats: add 0, delete 0, find 0/0
Dec 30 01:53:36 server01 kernel: [  368.572260] Free swap  = 0kB
Dec 30 01:53:36 server01 kernel: [  368.572375] Total swap = 0kB
Dec 30 01:53:36 server01 kernel: [  368.597836] apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
Dec 30 01:53:36 server01 kernel: [  368.598034] apache2 cpuset=uid mems_allowed=0
Dec 30 01:53:36 server01 kernel: [  368.598152] Pid: 5385, comm: apache2 Not tainted 3.2.35-grsec #1
Dec 30 01:53:36 server01 kernel: [  368.598273] Call Trace:
Dec 30 01:53:36 server01 kernel: [  368.598396]  [<ffffffff810cc89e>] dump_header+0x7e/0x1e0
Dec 30 01:53:36 server01 kernel: [  368.598516]  [<ffffffff810cc79f>] ? find_lock_task_mm+0x2f/0x70
Dec 30 01:53:36 server01 kernel: [  368.598638]  [<ffffffff810ccd65>] oom_kill_process+0x85/0x2a0
Dec 30 01:53:36 server01 kernel: [  368.598759]  [<ffffffff810cd415>] out_of_memory+0xe5/0x200
Dec 30 01:53:36 server01 kernel: [  368.598880]  [<ffffffff810cd5ed>] pagefault_out_of_memory+0xbd/0x110
Dec 30 01:53:36 server01 kernel: [  368.599006]  [<ffffffff81026e96>] mm_fault_error+0xb6/0x1a0
Dec 30 01:53:36 server01 kernel: [  368.599127]  [<ffffffff8102736e>] do_page_fault+0x3ee/0x460
Dec 30 01:53:36 server01 kernel: [  368.599250]  [<ffffffff81131ccf>] ? mntput+0x1f/0x30
Dec 30 01:53:36 server01 kernel: [  368.599371]  [<ffffffff811134e6>] ? fput+0x156/0x200
Dec 30 01:53:36 server01 kernel: [  368.599496]  [<ffffffff815b567f>] page_fault+0x1f/0x30

This would suggest that an unexpected ENOMEM leaked during page fault
path. I do not see which one could that be because you said THP
(CONFIG_TRANSPARENT_HUGEPAGE) are disabled (and the other patch I have
mentioned in the thread should fix that issue - btw. the patch is
already scheduled for stable tree).
 __do_fault, do_anonymous_page and do_wp_page call
mem_cgroup_newpage_charge with GFP_KERNEL which means that
we do memcg OOM and never return ENOMEM. do_swap_page calls
mem_cgroup_try_charge_swapin with GFP_KERNEL as well.

I might have missed something but I will not get to look closer before
2nd January.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
