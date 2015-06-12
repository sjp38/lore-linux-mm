Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA876B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 04:48:09 -0400 (EDT)
Received: by payr10 with SMTP id r10so19170141pay.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 01:48:09 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id rc6si4455130pab.83.2015.06.12.01.48.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 01:48:08 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
Date: Fri, 12 Jun 2015 08:42:33 +0000
Message-ID: <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E97BB67761E3F247B677894AB42604BD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 04, 2015 at 08:54:22PM +0800, Xishi Qiu wrote:
> Intel Xeon processor E7 v3 product family-based platforms introduces supp=
ort
> for partial memory mirroring called as 'Address Range Mirroring'. This fe=
ature
> allows BIOS to specify a subset of total available memory to be mirrored =
(and
> optionally also specify whether to mirror the range 0-4 GB). This capabil=
ity
> allows user to make an appropriate tradeoff between non-mirrored memory r=
ange
> and mirrored memory range thus optimizing total available memory and stil=
l
> achieving highly reliable memory range for mission critical workloads and=
/or
> kernel space.
>=20
> Tony has already send a patchset to supprot this feature at boot time.
> https://lkml.org/lkml/2015/5/8/521
>=20
> This patchset can support the feature after boot time. It introduces mirr=
or_info
> to save the mirrored memory range. Then use __GFP_MIRROR to allocate mirr=
ored=20
> pages.=20
>=20
> I think add a new migratetype is btter and easier than a new zone, so I u=
se
> MIGRATE_MIRROR to manage the mirrored pages. However it changed some code=
 in the
> core file, please review and comment, thanks.
>=20
> TBD:=20
> 1) call add_mirror_info() to fill mirrored memory info.
> 2) add compatibility with memory online/offline.

Maybe simply disabling memory offlining of memory block including MIGRATE_M=
IRROR?

> 3) add more interface? others?

4?) I don't have the whole picture of how address ranging mirroring works,
but I'm curious about what happens when an uncorrected memory error happens
on the a mirror page. If HW/FW do some useful work invisible from kernel,
please document it somewhere. And my questions are:
 - can the kernel with this patchset really continue its operation without
   breaking consistency? More specifically, the corrupted page is replaced =
with
   its mirror page, but can any other pages which have references (like str=
uct
   page or pfn) for the corrupted page properly switch these references to =
the
   mirror page? Or no worry about that?  (This is difficult for kernel page=
s
   like slab, and that's why currently hwpoison doesn't handle any kernel p=
ages.)
 - How can we test/confirm that the whole scheme works fine?  Is current me=
mory
   error injection framework enough?

It's really nice if any roadmap including testing is shared.

# And please CC me as n-horiguchi@ah.nec.com (my primary email address :)

Thanks,
Naoya Horiguchi

> Xishi Qiu (12):
>   mm: add a new config to manage the code
>   mm: introduce mirror_info
>   mm: introduce MIGRATE_MIRROR to manage the mirrored pages
>   mm: add mirrored pages to buddy system
>   mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
>   mm: add free mirrored pages info
>   mm: introduce __GFP_MIRROR to allocate mirrored pages
>   mm: use mirrorable to switch allocate mirrored memory
>   mm: enable allocate mirrored memory at boot time
>   mm: add the buddy system interface
>   mm: add the PCP interface
>   mm: let slab/slub/slob use mirrored memory
>=20
>  arch/x86/mm/numa.c     |   3 ++
>  drivers/base/node.c    |  17 ++++---
>  fs/proc/meminfo.c      |   6 +++
>  include/linux/gfp.h    |   5 +-
>  include/linux/mmzone.h |  23 +++++++++
>  include/linux/vmstat.h |   2 +
>  kernel/sysctl.c        |   9 ++++
>  mm/Kconfig             |   8 +++
>  mm/page_alloc.c        | 134 +++++++++++++++++++++++++++++++++++++++++++=
+++---
>  mm/slab.c              |   3 +-
>  mm/slob.c              |   2 +-
>  mm/slub.c              |   2 +-
>  mm/vmstat.c            |   4 ++
>  13 files changed, 202 insertions(+), 16 deletions(-)
>=20
> --=20
> 2.0.0
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
