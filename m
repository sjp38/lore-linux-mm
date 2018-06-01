Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B442E6B0006
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 02:14:15 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j26-v6so20016546ioa.3
        for <linux-mm@kvack.org>; Thu, 31 May 2018 23:14:15 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id l63-v6si1178798ita.47.2018.05.31.23.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 23:14:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm -V3 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Date: Fri, 1 Jun 2018 06:11:16 +0000
Message-ID: <20180601061116.GA4813@hori1.linux.bs1.fc.nec.co.jp>
References: <20180523082625.6897-1-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1D0CB96370BFC843A021E2C684759B6B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, May 23, 2018 at 04:26:04PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
>=20
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [02/21], [03/21], [04/21],
> [05/21], [06/21], [07/21], [08/21], [09/21], [10/21], [11/21],
> [12/21], [20/21].
>=20
> Hi, Andrea and Kirill, could you help me to review the THP part of the
> patchset?  Especially [01/21], [07/21], [09/21], [11/21], [13/21],
> [15/21], [16/21], [17/21], [18/21], [19/21], [20/21], [21/21].
>=20
> Hi, Johannes and Michal, could you help me to review the cgroup part
> of the patchset?  Especially [14/21].
>=20
> And for all, Any comment is welcome!

Hi Ying Huang,
I've read through this series and find no issue.

It seems that thp swapout never happens if swap devices are backed by
rotation storages.  I guess that's because this feature depends on swap
cluster searching algorithm which only supports non-rotational storages.

I think that this limitation is OK because non-rotational storage is
better for swap device (most future users will use it). But I think
it's better to document the limitation somewhere because swap cluster
is in-kernel thing and we can't assume that end users know about it.

Thanks,
Naoya Horiguchi

>=20
> This patchset is based on the 2018-05-18 head of mmotm/master.
>=20
> This is the final step of THP (Transparent Huge Page) swap
> optimization.  After the first and second step, the splitting huge
> page is delayed from almost the first step of swapout to after swapout
> has been finished.  In this step, we avoid splitting THP for swapout
> and swapout/swapin the THP in one piece.
>=20
> We tested the patchset with vm-scalability benchmark swap-w-seq test
> case, with 16 processes.  The test case forks 16 processes.  Each
> process allocates large anonymous memory range, and writes it from
> begin to end for 8 rounds.  The first round will swapout, while the
> remaining rounds will swapin and swapout.  The test is done on a Xeon
> E5 v3 system, the swap device used is a RAM simulated PMEM (persistent
> memory) device.  The test result is as follow,
>=20
>             base                  optimized
> ---------------- --------------------------=20
>          %stddev     %change         %stddev
>              \          |                \ =20
>    1417897 =1B$B!^=1B(B  2%    +992.8%   15494673        vm-scalability.t=
hroughput
>    1020489 =1B$B!^=1B(B  4%   +1091.2%   12156349        vmstat.swap.si
>    1255093 =1B$B!^=1B(B  3%    +940.3%   13056114        vmstat.swap.so
>    1259769 =1B$B!^=1B(B  7%   +1818.3%   24166779        meminfo.AnonHuge=
Pages
>   28021761           -10.7%   25018848 =1B$B!^=1B(B  2%  meminfo.AnonPage=
s
>   64080064 =1B$B!^=1B(B  4%     -95.6%    2787565 =1B$B!^=1B(B 33%  inter=
rupts.CAL:Function_call_interrupts
>      13.91 =1B$B!^=1B(B  5%     -13.8        0.10 =1B$B!^=1B(B 27%  perf-=
profile.children.cycles-pp.native_queued_spin_lock_slowpath
>=20
> Where, the score of benchmark (bytes written per second) improved
> 992.8%.  The swapout/swapin throughput improved 1008% (from about
> 2.17GB/s to 24.04GB/s).  The performance difference is huge.  In base
> kernel, for the first round of writing, the THP is swapout and split,
> so in the remaining rounds, there is only normal page swapin and
> swapout.  While in optimized kernel, the THP is kept after first
> swapout, so THP swapin and swapout is used in the remaining rounds.
> This shows the key benefit to swapout/swapin THP in one piece, the THP
> will be kept instead of being split.  meminfo information verified
> this, in base kernel only 4.5% of anonymous page are THP during the
> test, while in optimized kernel, that is 96.6%.  The TLB flushing IPI
> (represented as interrupts.CAL:Function_call_interrupts) reduced
> 95.6%, while cycles for spinlock reduced from 13.9% to 0.1%.  These
> are performance benefit of THP swapout/swapin too.
>=20
> Below is the description for all steps of THP swap optimization.
>=20
> Recently, the performance of the storage devices improved so fast that
> we cannot saturate the disk bandwidth with single logical CPU when do
> page swapping even on a high-end server machine.  Because the
> performance of the storage device improved faster than that of single
> logical CPU.  And it seems that the trend will not change in the near
> future.  On the other hand, the THP becomes more and more popular
> because of increased memory size.  So it becomes necessary to optimize
> THP swap performance.
>=20
> The advantages to swapout/swapin a THP in one piece include:
>=20
> - Batch various swap operations for the THP.  Many operations need to
>   be done once per THP instead of per normal page, for example,
>   allocating/freeing the swap space, writing/reading the swap space,
>   flushing TLB, page fault, etc.  This will improve the performance of
>   the THP swap greatly.
>=20
> - The THP swap space read/write will be large sequential IO (2M on
>   x86_64).  It is particularly helpful for the swapin, which are
>   usually 4k random IO.  This will improve the performance of the THP
>   swap too.
>=20
> - It will help the memory fragmentation, especially when the THP is
>   heavily used by the applications.  The THP order pages will be free
>   up after THP swapout.
>=20
> - It will improve the THP utilization on the system with the swap
>   turned on.  Because the speed for khugepaged to collapse the normal
>   pages into the THP is quite slow.  After the THP is split during the
>   swapout, it will take quite long time for the normal pages to
>   collapse back into the THP after being swapin.  The high THP
>   utilization helps the efficiency of the page based memory management
>   too.
>=20
> There are some concerns regarding THP swapin, mainly because possible
> enlarged read/write IO size (for swapout/swapin) may put more overhead
> on the storage device.  To deal with that, the THP swapin is turned on
> only when necessary.  A new sysfs interface:
> /sys/kernel/mm/transparent_hugepage/swapin_enabled is added to
> configure it.  It uses "always/never/madvise" logic, to be turned on
> globally, turned off globally, or turned on only for VMA with
> MADV_HUGEPAGE, etc.
> GE, etc.
>=20
> Changelog
> ---------
>=20
> v3:
>=20
> - Rebased on 5/18 HEAD of mmotm/master
>=20
> - Fixed a build bug, Thanks 0-Day!
>=20
> v2:
>=20
> - Fixed several build bugs, Thanks 0-Day!
>=20
> - Improved documentation as suggested by Randy Dunlap.
>=20
> - Fixed several bugs in reading huge swap cluster
> =
