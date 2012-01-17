Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 880996B005C
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 16:55:12 -0500 (EST)
Received: by bkbzx1 with SMTP id zx1so1415612bkb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 13:55:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com> <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
From: sandeep patil <psandeep.s@gmail.com>
Date: Tue, 17 Jan 2012 13:54:28 -0800
Message-ID: <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 04/11] mm: page_alloc: introduce alloc_contig_range()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Marek,

I am running a CMA test where I keep allocating from a CMA region as long
as the allocation fails due to lack of space.

However, I am seeing failures much before I expect them to happen.
When the allocation fails, I see a warning coming from __alloc_contig_range=
(),
because test_pages_isolated() returned "true".

The new retry code does try a new range and eventually succeeds.


> +
> +static int __alloc_contig_migrate_range(unsigned long start, unsigned lo=
ng end)
> +{
> +
> +done:
> + =A0 =A0 =A0 /* Make sure all pages are isolated. */
> + =A0 =A0 =A0 if (!ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_add_drain_all();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_pages();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(test_pages_isolated(start, end)=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EBUSY;
> + =A0 =A0 =A0 }

I tried to find out why this happened and added in a debug print inside
__test_page_isolated_in_pageblock(). Here's the resulting log ..

---
[  133.563140] !!! Found unexpected page(pfn=3D9aaab), (count=3D0),
(isBuddy=3Dno), (private=3D0x00000004), (flags=3D0x00000000), (_mapcount=3D=
0)
!!!
[  133.576690] ------------[ cut here ]------------
[  133.582489] WARNING: at mm/page_alloc.c:5804 alloc_contig_range+0x1a4/0x=
2c4()
[  133.594757] [<c003e814>] (unwind_backtrace+0x0/0xf0) from
[<c0079c7c>] (warn_slowpath_common+0x4c/0x64)
[  133.605468] [<c0079c7c>] (warn_slowpath_common+0x4c/0x64) from
[<c0079cac>] (warn_slowpath_null+0x18/0x1c)
[  133.616424] [<c0079cac>] (warn_slowpath_null+0x18/0x1c) from
[<c00e0e84>] (alloc_contig_range+0x1a4/0x2c4)
[  133.627471] EXT4-fs (mmcblk0p25): re-mounted. Opts: (null)
[  133.633728] [<c00e0e84>] (alloc_contig_range+0x1a4/0x2c4) from
[<c0266690>] (dma_alloc_from_contiguous+0x114/0x1c8)
[  133.697113] !!! Found unexpected page(pfn=3D9aaac), (count=3D0),
(isBuddy=3Dno), (private=3D0x00000004), (flags=3D0x00000000), (_mapcount=3D=
0)
!!!
[  133.710510] EXT4-fs (mmcblk0p26): re-mounted. Opts: (null)
[  133.716766] ------------[ cut here ]------------
[  133.721954] WARNING: at mm/page_alloc.c:5804 alloc_contig_range+0x1a4/0x=
2c4()
[  133.734100] Emergency Remount complete
[  133.742584] [<c003e814>] (unwind_backtrace+0x0/0xf0) from
[<c0079c7c>] (warn_slowpath_common+0x4c/0x64)
[  133.753448] [<c0079c7c>] (warn_slowpath_common+0x4c/0x64) from
[<c0079cac>] (warn_slowpath_null+0x18/0x1c)
[  133.764373] [<c0079cac>] (warn_slowpath_null+0x18/0x1c) from
[<c00e0e84>] (alloc_contig_range+0x1a4/0x2c4)
[  133.775299] [<c00e0e84>] (alloc_contig_range+0x1a4/0x2c4) from
[<c0266690>] (dma_alloc_from_contiguous+0x114/0x1c8)
---

>From the log it looks like the warning showed up because page->private
is set to MIGRATE_CMA instead of MIGRATE_ISOLATED.
I've also had a test case where it failed because (page_count() !=3D 0)

Have you or anyone else seen this during the CMA testing?

Also, could this be because we are finding a page within (start, end)
that actually belongs
to a higher order Buddy block ?


Thanks,
Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
