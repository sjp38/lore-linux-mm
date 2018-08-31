Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C10896B54B0
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 22:57:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n4-v6so4231171plk.7
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 19:57:16 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id r64-v6si8739576pfd.37.2018.08.30.19.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 19:57:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm: zero remaining unavailable struct pages
Date: Fri, 31 Aug 2018 02:55:36 +0000
Message-ID: <20180831025536.GA29753@hori1.linux.bs1.fc.nec.co.jp>
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
 <20180823182513.8801-2-msys.mizuma@gmail.com>
 <7c773dec-ded0-7a1e-b3ad-6c6826851015@microsoft.com>
 <484388a7-1e75-0782-fdfb-20345e1bda0d@gmail.com>
In-Reply-To: <484388a7-1e75-0782-fdfb-20345e1bda0d@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <28F8C1C11C8CAF4DBC43C8E161F8BB11@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, Aug 29, 2018 at 11:16:30AM -0400, Masayoshi Mizuma wrote:
> Hi Horiguchi-san and Pavel
>=20
> Thank you for your comments!
> The Pavel's additional patch looks good to me, so I will add it to this s=
eries.
>=20
> However, unfortunately, the movable_node option has something wrong yet..=
.
> When I offline the memory which belongs to movable zone, I got the follow=
ing
> warning. I'm trying to debug it.
>=20
> I try to describe the issue as following.=20
> If you have any comments, please let me know.
>=20
> WARNING: CPU: 156 PID: 25611 at mm/page_alloc.c:7730 has_unmovable_pages+=
0x1bf/0x200
> RIP: 0010:has_unmovable_pages+0x1bf/0x200
> ...
> Call Trace:
>  is_mem_section_removable+0xd3/0x160
>  show_mem_removable+0x8e/0xb0
>  dev_attr_show+0x1c/0x50
>  sysfs_kf_seq_show+0xb3/0x110
>  seq_read+0xee/0x480
>  __vfs_read+0x36/0x190
>  vfs_read+0x89/0x130
>  ksys_read+0x52/0xc0
>  do_syscall_64+0x5b/0x180
>  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> RIP: 0033:0x7fe7b7823f70
> ...
>=20
> I added a printk to catch the unmovable page.
> ---
> @@ -7713,8 +7719,12 @@ bool has_unmovable_pages(struct zone *zone, struct=
 page *page, int count,
>                  * is set to both of a memory hole page and a _used_ kern=
el
>                  * page at boot.
>                  */
> -               if (found > count)
> +               if (found > count) {
> +                       pr_info("DEBUG: %s zone: %lx page: %lx pfn: %lx f=
lags: %lx found: %ld count: %ld \n",
> +                               __func__, zone, page, page_to_pfn(page), =
page->flags, found, count);
>                         goto unmovable;
> +               }
> ---
>=20
> Then I got the following. The page (PFN: 0x1c0ff130d) flag is=20
> 0xdfffffc0040048 (uptodate|active|swapbacked)
>=20
> ---
> DEBUG: has_unmovable_pages zone: 0xffff8c0ffff80380 page: 0xffffea703fc4c=
340 pfn: 0x1c0ff130d flags: 0xdfffffc0040048 found: 1 count: 0=20
> ---
>=20
> And I got the owner from /sys/kernel/debug/page_owner.
>=20
> Page allocated via order 0, mask 0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO=
)
> PFN 7532909325 type Movable Block 14712713 type Movable Flags 0xdfffffc00=
40048(uptodate|active|swapbacked)
>  __alloc_pages_nodemask+0xfc/0x270
>  alloc_pages_vma+0x7c/0x1e0
>  handle_pte_fault+0x399/0xe50
>  __handle_mm_fault+0x38e/0x520
>  handle_mm_fault+0xdc/0x210
>  __do_page_fault+0x243/0x4c0
>  do_page_fault+0x31/0x130
>  page_fault+0x1e/0x30
>=20
> The page is allocated as anonymous page via page fault.
> I'm not sure, but lru flag should be added to the page...?

There is a small window of no PageLRU flag just after page allocation
until the page is linked to some LRU list.
This kind of unmovability is transient, so retrying can work.

I guess that this warning seems to be visible since commit 15c30bc09085
("mm, memory_hotplug: make has_unmovable_pages more robust")
which turned off the optimization based on the assumption that pages
under ZONE_MOVABLE are always movable.
I think that it helps developers find the issue that permanently
unmovable pages are accidentally located in ZONE_MOVABLE zone.
But even ZONE_MOVABLE zone could have transiently unmovable pages,
so the reported warning seems to me a false charge and should be avoided.
Doing lru_add_drain_all()/drain_all_pages() before has_unmovable_pages()
might be helpful?

Thanks,
Naoya Horiguchi=
