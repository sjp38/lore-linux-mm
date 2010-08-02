Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 33DD2600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:52:58 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5239430iwn.14
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 16:56:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100802124734.GI2486@arachsys.com>
References: <20100802124734.GI2486@arachsys.com>
Date: Tue, 3 Aug 2010 08:55:59 +0900
Message-ID: <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
Subject: Re: Over-eager swapping
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 2, 2010 at 9:47 PM, Chris Webb <chris@arachsys.com> wrote:
> We run a number of relatively large x86-64 hosts with twenty or so qemu-k=
vm
> virtual machines on each of them, and I'm have some trouble with over-eag=
er
> swapping on some (but not all) of the machines. This is resulting in
> customer reports of very poor response latency from the virtual machines
> which have been swapped out, despite the hosts apparently having large
> amounts of free memory, and running fine if swap is turned off.
>
> All of the hosts are running a 2.6.32.7 kernel and have ksm enabled with
> 32GB of RAM and 2x quad-core processors. There is a cluster of Xeon E5420
> machines which apparently doesn't exhibit the problem, and a cluster of
> 2352/2378 Opteron (NUMA) machines, some of which do. The kernel config of
> the affected machines is at
>
> =A0http://cdw.me.uk/tmp/config-2.6.32.7
>
> This differs very little from the config on the unaffected Xeon machines,
> essentially just
>
> =A0-CONFIG_MCORE2=3Dy
> =A0+CONFIG_MK8=3Dy
> =A0-CONFIG_X86_P6_NOP=3Dy
>
> On a typical affected machine, the virtual machines and other processes
> would apparently leave around 5.5GB of RAM available for buffers, but the
> system seems to want to swap out 3GB of anonymous pages to give itself mo=
re
> like 9GB of buffers:
>
> =A0# cat /proc/meminfo
> =A0MemTotal: =A0 =A0 =A0 33083420 kB
> =A0MemFree: =A0 =A0 =A0 =A0 =A0693164 kB
> =A0Buffers: =A0 =A0 =A0 =A0 8834380 kB
> =A0Cached: =A0 =A0 =A0 =A0 =A0 =A011212 kB
> =A0SwapCached: =A0 =A0 =A01443524 kB
> =A0Active: =A0 =A0 =A0 =A0 21656844 kB
> =A0Inactive: =A0 =A0 =A0 =A08119352 kB
> =A0Active(anon): =A0 17203092 kB
> =A0Inactive(anon): =A03729032 kB
> =A0Active(file): =A0 =A04453752 kB
> =A0Inactive(file): =A04390320 kB
> =A0Unevictable: =A0 =A0 =A0 =A05472 kB
> =A0Mlocked: =A0 =A0 =A0 =A0 =A0 =A05472 kB
> =A0SwapTotal: =A0 =A0 =A025165816 kB
> =A0SwapFree: =A0 =A0 =A0 21854572 kB
> =A0Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A04300 kB
> =A0Writeback: =A0 =A0 =A0 =A0 =A0 =A0 4 kB
> =A0AnonPages: =A0 =A0 =A020780368 kB
> =A0Mapped: =A0 =A0 =A0 =A0 =A0 =A0 6056 kB
> =A0Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A056 kB
> =A0Slab: =A0 =A0 =A0 =A0 =A0 =A0 961512 kB
> =A0SReclaimable: =A0 =A0 438276 kB
> =A0SUnreclaim: =A0 =A0 =A0 523236 kB
> =A0KernelStack: =A0 =A0 =A0 10152 kB
> =A0PageTables: =A0 =A0 =A0 =A067176 kB
> =A0NFS_Unstable: =A0 =A0 =A0 =A0 =A00 kB
> =A0Bounce: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 kB
> =A0WritebackTmp: =A0 =A0 =A0 =A0 =A00 kB
> =A0CommitLimit: =A0 =A041707524 kB
> =A0Committed_AS: =A0 39870868 kB
> =A0VmallocTotal: =A0 34359738367 kB
> =A0VmallocUsed: =A0 =A0 =A0150880 kB
> =A0VmallocChunk: =A0 34342404996 kB
> =A0HardwareCorrupted: =A0 =A0 0 kB
> =A0HugePages_Total: =A0 =A0 =A0 0
> =A0HugePages_Free: =A0 =A0 =A0 =A00
> =A0HugePages_Rsvd: =A0 =A0 =A0 =A00
> =A0HugePages_Surp: =A0 =A0 =A0 =A00
> =A0Hugepagesize: =A0 =A0 =A0 2048 kB
> =A0DirectMap4k: =A0 =A0 =A0 =A05824 kB
> =A0DirectMap2M: =A0 =A0 3205120 kB
> =A0DirectMap1G: =A0 =A030408704 kB
>
> We see this despite the machine having vm.swappiness set to 0 in an attem=
pt
> to skew the reclaim as far as possible in favour of releasing page cache
> instead of swapping anonymous pages.
>

Hmm, Strange.
We reclaim only anon pages when the system has few page cache.
(ie, file + free <=3D high_water_mark)
But in your meminfo, your system has lots of page cache page.
So It isn't likely.

Another possibility is _zone_reclaim_ in NUMA.
Your working set has many anonymous page.

The zone_reclaim set priority to ZONE_RECLAIM_PRIORITY.
It can make reclaim mode to lumpy so it can page out anon pages.

Could you show me /proc/sys/vm/[zone_reclaim_mode/min_unmapped_ratio] ?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
