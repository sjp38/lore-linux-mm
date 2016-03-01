Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7F52F6B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:38:50 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so33783147wml.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:38:50 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id wx10si37355757wjb.238.2016.03.01.05.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 05:38:49 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l68so4139889wml.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:38:49 -0800 (PST)
Date: Tue, 1 Mar 2016 14:38:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160301133846.GF9461@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

[Adding Vlastimil and Joonsoo for compaction related things - this was a
large thread but the more interesting part starts with
http://lkml.kernel.org/r/alpine.LSU.2.11.1602241832160.15564@eggly.anvils]

On Mon 29-02-16 23:29:06, Hugh Dickins wrote:
> On Mon, 29 Feb 2016, Michal Hocko wrote:
> > On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
> > [...]
> > > Boot with mem=1G (or boot your usual way, and do something to occupy
> > > most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> > > way to gobble up most of the memory, though it's not how I've done it).
> > > 
> > > Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> > > kernel source tree into a tmpfs: size=2G is more than enough.
> > > make defconfig there, then make -j20.
> > > 
> > > On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> > > 
> > > Except that you'll probably need to fiddle around with that j20,
> > > it's true for my laptop but not for my workstation.  j20 just happens
> > > to be what I've had there for years, that I now see breaking down
> > > (I can lower to j6 to proceed, perhaps could go a bit higher,
> > > but it still doesn't exercise swap very much).
> > 
> > I have tried to reproduce and failed in a virtual on my laptop. I
> > will try with another host with more CPUs (because my laptop has only
> > two). Just for the record I did: boot 1G machine in kvm, I have 2G swap
> > and reserve 800M for hugetlb pages (I got 445 of them). Then I extract
> > the kernel source to tmpfs (-o size=2G), make defconfig and make -j20
> > (16, 10 no difference really). I was also collecting vmstat in the
> > background. The compilation takes ages but the behavior seems consistent
> > and stable.
> 
> Thanks a lot for giving it a go.
> 
> I'm puzzled.  445 hugetlb pages in 800M surprises me: some of them
> are less than 2M big??  But probably that's just a misunderstanding
> or typo somewhere.

A typo. 445 was from 900M test which I was doing while writing the
email. Sorry about the confusion.

> Ignoring that, you're successfully doing a make -20 defconfig build
> in tmpfs, with only 224M of RAM available, plus 2G of swap?  I'm not
> at all surprised that it takes ages, but I am very surprised that it
> does not OOM.  I suppose by rights it ought not to OOM, the built
> tree occupies only a little more than 1G, so you do have enough swap;
> but I wouldn't get anywhere near that myself without OOMing - I give
> myself 1G of RAM (well, minus whatever the booted system takes up)
> to do that build in, four times your RAM, yet in my case it OOMs.
>
> That source tree alone occupies more than 700M, so just copying it
> into your tmpfs would take a long time. 

OK, I just found out that I was cheating a bit. I was building
linux-3.7-rc5.tar.bz2 which is smaller:
$ du -sh /mnt/tmpfs/linux-3.7-rc5/
537M    /mnt/tmpfs/linux-3.7-rc5/

and after the defconfig build:
$ free
             total       used       free     shared    buffers     cached
Mem:       1008460     941904      66556          0       5092     806760
-/+ buffers/cache:     130052     878408
Swap:      2097148      42648    2054500
$ du -sh linux-3.7-rc5/
799M    linux-3.7-rc5/

Sorry about that but this is what my other tests were using and I forgot
to check. Now let's try the same with the current linus tree:
host $ git archive v4.5-rc6 --prefix=linux-4.5-rc6/ | bzip2 > linux-4.5-rc6.tar.bz2
$ du -sh /mnt/tmpfs/linux-4.5-rc6/
707M    /mnt/tmpfs/linux-4.5-rc6/
$ free
             total       used       free     shared    buffers     cached
Mem:       1008460     962976      45484          0       7236     820064
-/+ buffers/cache:     135676     872784
Swap:      2097148         16    2097132
$ time make -j20 > /dev/null
drivers/acpi/property.c: In function a??acpi_data_prop_reada??:
drivers/acpi/property.c:745:8: warning: a??obja?? may be used uninitialized in this function [-Wmaybe-uninitialized]

real    8m36.621s
user    14m1.642s
sys     2m45.238s

so I wasn't cheating all that much...

> I'd expect a build in 224M
> RAM plus 2G of swap to take so long, that I'd be very grateful to be
> OOM killed, even if there is technically enough space.  Unless
> perhaps it's some superfast swap that you have?

the swap partition is a standard qcow image stored on my SSD disk. So
I guess the IO should be quite fast. This smells like a potential
contributor because my reclaim seems to be much faster and that should
lead to a more efficient reclaim (in the scanned/reclaimed sense).
I realize I might be boring already when blaming compaction but let me
try again ;)
$ grep compact /proc/vmstat 
compact_migrate_scanned 113983
compact_free_scanned 1433503
compact_isolated 134307
compact_stall 128
compact_fail 26
compact_success 102
compact_kcompatd_wake 0

So the whole load has done the direct compaction only 128 times during
that test. This doesn't sound much to me
$ grep allocstall /proc/vmstat
allocstall 1061

we entered the direct reclaim much more but most of the load will be
order-0 so this might be still ok. So I've tried the following:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894b4219..107d444afdb1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2910,6 +2910,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 						mode, contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
+	if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER)
+		trace_printk("order:%d gfp_mask:%pGg compact_result:%lu\n", order, &gfp_mask, compact_result);
+
 	switch (compact_result) {
 	case COMPACT_DEFERRED:
 		*deferred_compaction = true;

And the result was:
$ cat /debug/tracing/trace_pipe | tee ~/trace.log
             gcc-8707  [001] ....   137.946370: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1
             gcc-8726  [000] ....   138.528571: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1

this shows that order-2 memory pressure is not overly high in my
setup. Both attempts ended up COMPACT_SKIPPED which is interesting.

So I went back to 800M of hugetlb pages and tried again. It took ages
so I have interrupted that after one hour (there was still no OOM). The
trace log is quite interesting regardless:
$ wc -l ~/trace.log
371 /root/trace.log

$ grep compact_stall /proc/vmstat 
compact_stall 190

so the compaction was still ignored more than actually invoked for
!costly allocations:
sed 's@.*order:\([[:digit:]]\).* compact_result:\([[:digit:]]\)@\1 \2@' ~/trace.log | sort | uniq -c 
    190 2 1
    122 2 3
     59 2 4

#define COMPACT_SKIPPED         1               
#define COMPACT_PARTIAL         3
#define COMPACT_COMPLETE        4

that means that compaction is even not tried in half cases! This
doesn't sounds right to me, especially when we are talking about
<= PAGE_ALLOC_COSTLY_ORDER requests which are implicitly nofail, because
then we simply rely on the order-0 reclaim to automagically form higher
blocks. This might indeed work when we retry many times but I guess this
is not a good approach. It leads to a excessive reclaim and the stall
for allocation can be really large.

One of the suspicious places is __compaction_suitable which does order-0
watermark check (increased by 2<<order). I have put another trace_printk
there and it clearly pointed out this was the case.

So I have tried the following:
diff --git a/mm/compaction.c b/mm/compaction.c
index 4d99e1f5055c..7364e48cf69a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1276,6 +1276,9 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
 								alloc_flags))
 		return COMPACT_PARTIAL;
 
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		return COMPACT_CONTINUE;
+
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
 	 * This is because during migration, copies of pages need to be

and retried the same test (without huge pages):
$ time make -j20 > /dev/null

real    8m46.626s
user    14m15.823s
sys     2m45.471s

the time increased but I haven't checked how stable the result is. 

$ grep compact /proc/vmstat
compact_migrate_scanned 139822
compact_free_scanned 1661642
compact_isolated 139407
compact_stall 129
compact_fail 58
compact_success 71
compact_kcompatd_wake 1

$ grep allocstall /proc/vmstat
allocstall 1665

this is worse because we have scanned more pages for migration but the
overall success rate was much smaller and the direct reclaim was invoked
more. I do not have a good theory for that and will play with this some
more. Maybe other changes are needed deeper in the compaction code.

I will play with this some more but I would be really interested to hear
whether this helped Hugh with his setup. Vlastimi, Joonsoo does this
even make sense to you?

> I was only suggesting to allocate hugetlb pages, if you preferred
> not to reboot with artificially reduced RAM.  Not an issue if you're
> booting VMs.

Ohh, I see.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
