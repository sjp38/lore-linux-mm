Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCD66B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:28:10 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so27379195wml.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:28:10 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id c5si3737090wjf.227.2016.03.04.04.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 04:28:08 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id n186so3942211wmn.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:28:08 -0800 (PST)
Date: Fri, 4 Mar 2016 13:28:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304122805.GC31257@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603030039430.23352@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 03-03-16 01:54:43, Hugh Dickins wrote:
> On Tue, 1 Mar 2016, Michal Hocko wrote:
> > [Adding Vlastimil and Joonsoo for compaction related things - this was a
> > large thread but the more interesting part starts with
> > http://lkml.kernel.org/r/alpine.LSU.2.11.1602241832160.15564@eggly.anvils]
> > 
> > On Mon 29-02-16 23:29:06, Hugh Dickins wrote:
> > > On Mon, 29 Feb 2016, Michal Hocko wrote:
> > > > On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
> > > > [...]
> > > > > Boot with mem=1G (or boot your usual way, and do something to occupy
> > > > > most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> > > > > way to gobble up most of the memory, though it's not how I've done it).
> > > > > 
> > > > > Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> > > > > kernel source tree into a tmpfs: size=2G is more than enough.
> > > > > make defconfig there, then make -j20.
> > > > > 
> > > > > On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> > > > > 
> > > > > Except that you'll probably need to fiddle around with that j20,
> > > > > it's true for my laptop but not for my workstation.  j20 just happens
> > > > > to be what I've had there for years, that I now see breaking down
> > > > > (I can lower to j6 to proceed, perhaps could go a bit higher,
> > > > > but it still doesn't exercise swap very much).
> > > > 
> > > > I have tried to reproduce and failed in a virtual on my laptop. I
> > > > will try with another host with more CPUs (because my laptop has only
> > > > two). Just for the record I did: boot 1G machine in kvm, I have 2G swap
> 
> I've found that the number of CPUs makes quite a difference - I have 4.
> 
> And another difference between us may be in our configs: on this laptop
> I had lots of debug options on (including DEBUG_VM, DEBUG_SPINLOCK and
> PROVE_LOCKING, though not DEBUG_PAGEALLOC), which approximately doubles
> the size of each shmem_inode (and those of course are not swappable).

I had everything but PROVE_LOCKING. Enabling this option doesn't change
anything (except for the overal runtime which is longer of course) in my
2 cpus setup, though.

All the following is with the clean mmotm (mmotm-2016-02-24-16-18)
without any additional change.  I have moved my kvm setup to a larger
machine. The storage is a standard spinning rust and I've made sure that
the swap is not cached on the host and the swap IO is done directly by
doing
-drive file=swap-2G.qcow,if=ide,index=2,cache=none

retested with 4CPUs and make -j20
real    8m42.263s
user    20m52.838s
sys     8m8.805s

with 16CPU and make -j20
real    3m34.806s
user    20m25.245s
sys     8m39.366s

and the same with -j60 which actually triggered the OOM
$ grep "invoked oom-killer:" oomrework.qcow_serial.log
[10064.286799] cc1 invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
[...]
[10064.394172] DMA32 free:3764kB min:3796kB low:4776kB high:5756kB active_anon:394184kB inactive_anon:394168kB active_file:1836kB inactive_file:2156kB unevictable:0kB isolated(anon):148kB isolated(file):0kB present:1032060kB managed:987556kB mlocked:0kB dirty:0kB writeback:96kB mapped:1308kB shmem:6704kB slab_reclaimable:51356kB slab_unreclaimable:100532kB kernel_stack:7328kB pagetables:15944kB unstable:0kB bounce:0kB free_pcp:1796kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:63244 all_unreclaimable? yes
[...]
[10560.926971] cc1 invoked oom-killer: gfp_mask=0x24200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
[...]
[10561.007362] DMA32 free:4800kB min:3796kB low:4776kB high:5756kB active_anon:393112kB inactive_anon:393508kB active_file:1560kB inactive_file:1428kB unevictable:0kB isolated(anon):2452kB isolated(file):212kB present:1032060kB managed:987556kB mlocked:0kB dirty:0kB writeback:564kB mapped:2552kB shmem:7664kB slab_reclaimable:51352kB slab_unreclaimable:100396kB kernel_stack:7392kB pagetables:16196kB unstable:0kB bounce:0kB free_pcp:812kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1172 all_unreclaimable? no

but those are simple order-0 OOMs. So this cannot be a compaction
related.  The second oom is probably racing with the exiting task
because we are over the low wmark. This would suggest we have exhausted
all the attempts with no progress.

This was all after fresh boot so then I stayed with 16CPUs and did
make -j20 > /dev/null
make clean

in the loop and left it run overnight. This should randomize the swap
IO and also should have a better chance of longterm fragmentation.
It survived 300 iterations.

I really have no idea what might be the difference with your setup. So
I've tried to test linux-next (next-20160226) just to make sure that
this is not something mmotm git tree (which I maintain) specific.

> I found that I could avoid the OOM if I ran the "make -j20" on a
> kernel without all those debug options, and booted with nr_cpus=2.
> And currently I'm booting the kernel with the debug options in,
> but with nr_cpus=2, which does still OOM (whereas not if nr_cpus=1).
> 
> Maybe in the OOM rework, threads are cancelling each other's progress
> more destructively, where before they co-operated to some extent?
> 
> (All that is on the laptop.  The G5 is still busy full-time bisecting
> a powerpc issue: I know it was OOMing with the rework, but I have not
> verified the effect of nr_cpus on it.  My x86 workstation has not been
> OOMing with the rework - I think that means that I've not been exerting
> as much memory pressure on it as I'd thought, that it copes with the load
> better, and would only show the difference if I loaded it more heavily.)

I am currently testing with the swap backed on sshfs (with -o direct_io)
which should emulate a really slow storage. But still not OOM, I only
managed to hit:
INFO: task khugepaged:246 blocked for more than 120 seconds.
int the IO path
[  480.422500]  [<ffffffff812b0c9b>] get_request+0x440/0x55e
[  480.423444]  [<ffffffff81081148>] ? wait_woken+0x72/0x72
[  480.424447]  [<ffffffff812b3071>] blk_queue_bio+0x16d/0x302
[  480.425566]  [<ffffffff812b1607>] generic_make_request+0xc0/0x15e
[  480.426642]  [<ffffffff812b17ae>] submit_bio+0x109/0x114
[  480.427704]  [<ffffffff81147101>] __swap_writepage+0x1ea/0x1f9
[  480.430364]  [<ffffffff81149346>] ? page_swapcount+0x45/0x4c
[  480.432718]  [<ffffffff815a8aed>] ? _raw_spin_unlock+0x31/0x44
[  480.433722]  [<ffffffff81149346>] ? page_swapcount+0x45/0x4c
[  480.434697]  [<ffffffff8114714a>] swap_writepage+0x3a/0x3e
[  480.435718]  [<ffffffff81122bbe>] shmem_writepage+0x37b/0x3d1
[  480.436757]  [<ffffffff8111dbe8>] shrink_page_list+0x49c/0xd88
 
[...]
> > I will play with this some more but I would be really interested to hear
> > whether this helped Hugh with his setup. Vlastimi, Joonsoo does this
> > even make sense to you?
> 
> It didn't help me; but I do suspect you're right to be worrying about
> the treatment of compaction of 0 < order <= PAGE_ALLOC_COSTLY_ORDER.
> 
> > 
> > > I was only suggesting to allocate hugetlb pages, if you preferred
> > > not to reboot with artificially reduced RAM.  Not an issue if you're
> > > booting VMs.
> > 
> > Ohh, I see.
> 
> I've attached vmstats.xz, output from your read_vmstat proggy;
> together with oom.xz, the dmesg for the OOM in question.

[  796.225322] sh invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
[  796.630465] Node 0 DMA32 free:13904kB min:3940kB low:4944kB high:5948kB active_anon:588776kB inactive_anon:188816kB active_file:20432kB inactive_file:6928kB unevictable:12268kB isolated(anon):128kB isolated(file):8kB present:1046128kB managed:1004892kB mlocked:12268kB dirty:16kB writeback:1400kB mapped:35556kB shmem:12684kB slab_reclaimable:55628kB slab_unreclaimable:92944kB kernel_stack:4448kB pagetables:8604kB unstable:0kB bounce:0kB free_pcp:296kB local_pcp:164kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  796.687390] Node 0 DMA32: 969*4kB (UE) 184*8kB (UME) 167*16kB (UM) 19*32kB (UM) 3*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8820kB
[...]

This is really interesting because there are some order-2+ pages
available. Even more striking is that free is way above high watermark.
This would suggest that declaring OOM must have raced with an exiting
task. This is not that unexpected because gcc are quite shortlived
and `make' spawns new as soon the last one terminated. This race is not
new and we cannot do much better without a moving the wmark check closer
to the actual do_send_sig_info. This is not the main problem though. The
thing that you are able to trigger this consistently is what bothers me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
