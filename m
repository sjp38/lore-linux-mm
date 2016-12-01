Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 510BD280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:50:42 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id r204so247893743ywb.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:50:42 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id d11si158440ywg.223.2016.12.01.06.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 06:50:41 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id a10so18638903ywa.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:50:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129201703.CE9D5054@viggo.jf.intel.com>
References: <20161129201703.CE9D5054@viggo.jf.intel.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 1 Dec 2016 16:50:39 +0200
Message-ID: <CAHp75Vee5EzoxOoXot0+0jRKtX+nhj+obJp-zR3Kp3osdKCVNA@mail.gmail.com>
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v3)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, khandual@linux.vnet.ibm.com, vbabka@suse.cz, linux-mm@kvack.org, Linux-Arch <linux-arch@vger.kernel.org>

On Tue, Nov 29, 2016 at 10:17 PM, Dave Hansen <dave@sr71.net> wrote:
>
> Andrew, you can drop proc-mm-export-pte-sizes-directly-in-smaps-v2.patch,
> and replace it with this.

You added a warning and it immediately appears:


[    0.402603] ------------[ cut here ]------------
[    0.402844] WARNING: CPU: 0 PID: 1 at
/home/andy/prj/linux-netboot/mm/hugetlb.c:2918
hugetlb_add_hstate+0x143/0
x14b
[    0.403042] Modules linked in:
[    0.403233] CPU: 0 PID: 1 Comm: swapper Not tainted
4.9.0-rc7-next-20161201+ #1
[    0.403499] Call Trace:
[    0.403677]  dump_stack+0x16/0x1d
[    0.404081]  __warn+0xd1/0xf0
[    0.404289]  ? hugetlb_add_hstate+0x143/0x14b
[    0.404491]  warn_slowpath_null+0x25/0x30
[    0.404695]  hugetlb_add_hstate+0x143/0x14b
[    0.404908]  hugetlb_init+0x79/0x3af
[    0.405249]  ? wake_up_process+0xf/0x20
[    0.405450]  ? kcompactd_run+0x50/0x90
[    0.405638]  ? compact_zone+0x7c0/0x7c0
[    0.405842]  ? hugetlb_add_hstate+0x14b/0x14b
[    0.406082]  do_one_initcall+0x2f/0x160
[    0.406286]  ? repair_env_string+0x12/0x54
[    0.406482]  ? parse_args+0x2a1/0x5a0
[    0.406684]  ? __dquot_free_space+0xa0/0x2d0
[    0.406892]  ? kernel_init_freeable+0xe4/0x18a
[    0.407088]  kernel_init_freeable+0x107/0x18a
[    0.407303]  ? rest_init+0x60/0x60
[    0.407496]  kernel_init+0xb/0x100
[    0.407703]  ? schedule_tail_wrapper+0x9/0x10
[    0.408099]  ret_from_fork+0x19/0x30
[    0.408302] ---[ end trace 601ba77b9b62b9d7 ]---
[    0.408481] HugeTLB registered 4 MB page size, pre-allocated 0 pages


Quark SoC here.

Besides that see below.

> +/*
> + * What units should we use for a given number?  We want
> + * 2048 to be 2k, so we return 'k'.  1048576 should be
> + * 1M, so we return 'M'.
> + */
> +static char size_unit(unsigned long long nr)
> +{
> +       /*
> +        * This ' ' might look a bit goofy in the output.  But, why
> +        * bother doing anything.  Do we even have a <1k page size?
> +        */
> +       if (nr < (1ULL<<10))
> +               return ' ';
> +       if (nr < (1ULL<<20))
> +               return 'k';
> +       if (nr < (1ULL<<30))
> +               return 'M';
> +       if (nr < (1ULL<<40))
> +               return 'G';
> +       if (nr < (1ULL<<50))
> +               return 'T';
> +       if (nr < (1ULL<<60))
> +               return 'P';
> +       return 'E';
> +}
> +
> +/*
> + * How should we shift down a a given number to scale it
> + * with the units we are printing it as? 2048 to be 2k,
> + * so we want it shifted down by 10.  1048576 should be
> + * 1M, so we want it shifted down by 20.
> + */
> +static int size_shift(unsigned long long nr)
> +{
> +       if (nr < (1ULL<<10))
> +               return 0;
> +       if (nr < (1ULL<<20))
> +               return 10;
> +       if (nr < (1ULL<<30))
> +               return 20;
> +       if (nr < (1ULL<<40))
> +               return 30;
> +       if (nr < (1ULL<<50))
> +               return 40;
> +       if (nr < (1ULL<<60))
> +               return 50;
> +       return 60;
> +}
> +

New copy of string_get_size() ?

Something similar was discussed for EFI stuff like half a year ago?

> +static void show_one_smap_pte(struct seq_file *m, unsigned long bytes_rss,
> +               unsigned long pte_size)
> +{
> +       seq_printf(m, "Ptes@%ld%cB:     %8lu kB\n",
> +                       pte_size >> size_shift(pte_size),
> +                       size_unit(pte_size),
> +                       bytes_rss >> 10);
> +}


> +       /*
> +        * PGD_SIZE isn't widely made available by architecures,
> +        * so use PUD_SIZE*PTRS_PER_PUD as a substitute.
> +        *
> +        * Check for sizes that might be mapped by a PGD.  There
> +        * are none of these known today, but be on the lookout.
> +        * If this trips, we will need to update the mss->rss_*
> +        * code in fs/proc/task_mmu.c.
> +        */
> +       WARN_ON_ONCE((PAGE_SIZE << order) >= PUD_SIZE * PTRS_PER_PUD);

This what I got.

-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
