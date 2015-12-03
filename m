Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 120C96B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 21:09:53 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so56950607pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 18:09:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id f2si8498344pfj.59.2015.12.02.18.09.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 18:09:52 -0800 (PST)
Date: Thu, 3 Dec 2015 11:10:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151203021006.GA31041@bbox>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
MIME-Version: 1.0
In-Reply-To: <20151203013404.GA30779@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 03, 2015 at 10:34:04AM +0900, Minchan Kim wrote:
> On Wed, Dec 02, 2015 at 11:16:43AM +0100, Michal Hocko wrote:
> > On Tue 01-12-15 22:34:55, Minchan Kim wrote:
> > > With new test on mmotm-2015-11-25-17-08, I saw below WARNING message
> > > several times. I couldn't see it with reverting new THP refcount
> > > redesign.
> > 
> > Just a wild guess. What prevents migration/compaction from calling
> > split_huge_page on thp zero page? There is VM_BUG_ON but it is not clear
> 
> I guess migration should work with LRU pages now but zero page couldn't
> stay there.
> 
> > whether you run with CONFIG_DEBUG_VM enabled.
> 
> I enabled VM_DEBUG_VM.
> 
> > 
> > Also, how big is the underflow?
> 
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index 7c6a63d..adc27c3 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -23,6 +23,8 @@ void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
>  
>         new = atomic_long_sub_return(nr_pages, &counter->count);
>         /* More uncharges than charges? */
> +       if (new < 0)
> +               printk("nr_pages %lu new %ld\n", nr_pages, new);
>         WARN_ON_ONCE(new < 0);
>  }
> 
> nr_pages 512 new -31
> ------------[ cut here ]------------
> WARNING: CPU: 3 PID: 1145 at mm/page_counter.c:28 page_counter_cancel+0x44/0x50()
> Modules linked in:
> CPU: 3 PID: 1145 Comm: madvise_test Not tainted 4.4.0-rc2-mm1-kirill+ #17
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffffffff81782f09 ffff8800598c3b90 ffffffff8126f476 0000000000000000
>  ffff8800598c3bc8 ffffffff8103e476 ffff88007f14f8b0 0000000000000200
>  0000000000000000 0000000000000200 ffff88007f14f800 ffff8800598c3bd8
> Call Trace:
>  [<ffffffff8126f476>] dump_stack+0x44/0x5e
>  [<ffffffff8103e476>] warn_slowpath_common+0x86/0xc0
>  [<ffffffff8103e56a>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff8114c744>] page_counter_cancel+0x44/0x50
>  [<ffffffff8114c842>] page_counter_uncharge+0x22/0x30
>  [<ffffffff8114fe07>] uncharge_batch+0x47/0x140
>  [<ffffffff81150023>] uncharge_list+0x123/0x190
>  [<ffffffff811521f9>] mem_cgroup_uncharge+0x29/0x30
>  [<ffffffff810fe3be>] __page_cache_release+0x15e/0x200
>  [<ffffffff810fe47e>] __put_compound_page+0x1e/0x50
>  [<ffffffff810fe960>] release_pages+0xd0/0x370
>  [<ffffffff8113042d>] free_pages_and_swap_cache+0x9d/0x120
>  [<ffffffff8111a516>] tlb_flush_mmu_free+0x36/0x60
>  [<ffffffff8111b60c>] tlb_finish_mmu+0x1c/0x50
>  [<ffffffff81125f1c>] exit_mmap+0xec/0x140
>  [<ffffffff8103bd56>] mmput+0x56/0xe0
>  [<ffffffff8103ff4d>] do_exit+0x1fd/0xaa0
>  [<ffffffff8104086f>] do_group_exit+0x3f/0xb0
>  [<ffffffff810408f4>] SyS_exit_group+0x14/0x20
>  [<ffffffff8142b617>] entry_SYSCALL_64_fastpath+0x12/0x6a
> ---[ end trace 872ed93351e964c0 ]---
> nr_pages 293 new -324
> nr_pages 16 new -340
> nr_pages 342 new -91
> nr_pages 246 new -337
> nr_pages 15 new -352
> nr_pages 15 new -367

My guess is that it's related to new feature of Kirill's THP 'PageDoubleMap'
so a THP page could be mapped a pte but !pmd_trans_huge(*pmd) so memcg
precharge in move_charge should handle it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
