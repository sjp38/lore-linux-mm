Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1AFA06B0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 07:17:44 -0500 (EST)
Date: Thu, 7 Mar 2013 13:17:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [jbd2 or mm BUG]:   crash while flush JBD2's the pages, that
 owned Slab flag.
Message-ID: <20130307121739.GC6723@quack.suse.cz>
References: <51384D84.8090803@allwinnertech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51384D84.8090803@allwinnertech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuge <shuge@allwinnertech.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org

  Hi,

  I've fixed linux-mm mailing list address...

On Thu 07-03-13 16:19:16, Shuge wrote:
> When I debug the file system, I get a problem as follows:
> 
> Arch: arm (4 processors)
> Kernel version: 3.3.0
> 
>   The "b_frozen_data" which is defined as a member of "struct
> journal_head" (linux/fs/jbd2/transaction.c Line 785),
> it's memory is allocated by "jbd2_alloc". When the memory size is
> larger than a PAGE SIZE, the memory is got by "
> __get_free_pages", otherwise, is got by "kmem_cache_alloc". The
> memory will be used by the "__blk_queue_bounce"(linux/mm/bounce.c).
> 
> In this function, the program flow is:
> __blk_queue_bounce() -> flush_dcache_page() -> page_mapping() ->
> VM_BUG_ON(PageSlab(page))
> If the memory is got by "kmem_cache_alloc", it will trigger on a bug.
> 
> Kernel panic:
> [   34.683049] ------------[ cut here ]------------
> [   34.687686] kernel BUG at include/linux/mm.h:791!
> [   34.692388] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [   34.697869] Modules linked in: screen_print(O) nand(O)
> [   34.703049] CPU: 1    Tainted: G           O  (3.3.0 #6)
> [   34.708370] PC is at flush_dcache_page+0x34/0xb0
> [   34.712992] LR is at blk_queue_bounce+0x16c/0x300
> [   34.717697] pc : [<c001677c>]    lr : [<c00bf0b0>]    psr: 20000013
> [   34.717703] sp : ee7a7d48  ip : ee7a7d60  fp : ee7a7d5c
> [   34.729176] r10: ee228804  r9 : ee228804  r8 : eea979c8
> [   34.734397] r7 : 00000000  r6 : ee228890  r5 : d5333840  r4 : 00000000
> [   34.740920] r3 : 00000001  r2 : fffffff5  r1 : 00000011  r0 : d5333840
> [   34.747446] Flags: nzCv  IRQs on  FIQs on  Mon  SVC_32  ISA ARM
> Segment kernel
> [   34.754749] Control: 10c53c7d  Table: 6e05806a  DAC: 00000015
> ......
> [   35.726529] Backtrace:
> [   35.729000] [<c0016748>] (flush_dcache_page+0x0/0xb0) from
> [<c00bf0b0>] (blk_queue_bounce+0x16c/0x300)
> [   35.738297]  r5:ee7a7dac r4:ee2287c0
> [   35.741905] [<c00bef44>] (blk_queue_bounce+0x0/0x300) from
> [<c01fcc58>] (blk_queue_bio+0x28/0x2c0)
> [   35.750862] [<c01fcc30>] (blk_queue_bio+0x0/0x2c0) from [<c01fb1b8>]
> (generic_make_request+0x94/0xcc)
> [   35.760078] [<c01fb124>] (generic_make_request+0x0/0xcc) from
> [<c01fb2f0>] (submit_bio+0x100/0x124)
> [   35.769114]  r6:00000002 r5:eecb8f08 r4:ee228840
> [   35.773774] [<c01fb1f0>] (submit_bio+0x0/0x124) from [<c00e8e68>]
> (submit_bh+0x130/0x150)
> [   35.781942]  r8:00000009 r7:d60f6c5c r6:00000211 r5:eecb8f08 r4:ee228840
> [   35.788713] [<c00e8d38>] (submit_bh+0x0/0x150) from [<c014b024>]
> (jbd2_journal_commit_transaction+0x7d0/0x11cc)
> [   35.798790]  r6:ef253380 r5:eecb8f08 r4:eeac5800 r3:00000001
> [   35.804505] [<c014a854>] (jbd2_journal_commit_transaction+0x0/0x11cc)
> from [<c014e2a8>] (kjournald2+0xb4/0x248)
> [   35.814591] [<c014e1f4>] (kjournald2+0x0/0x248) from [<c006aa90>]
> (kthread+0x94/0xa0)
> [   35.822422] [<c006a9fc>] (kthread+0x0/0xa0) from [<c005472c>]
> (do_exit+0x0/0x6a4)
> [   35.829897]  r6:c005472c r5:c006a9fc r4:eea9bce0
> [   35.834556] Code: e5904004 e7e033d3 e3530000 0a000000 (e7f001f2)
> [   35.840733] ---[ end trace c2a29bf063d3670f ]---
> 
> So, I modify the mm/bounce.c. Details are as follows:
> 
> diff --git a/mm/bounce.c b/mm/bounce.c
> index 4e9ae72..e3f6b53 100644
> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -214,7 +214,8 @@ static void __blk_queue_bounce(struct request_queue
> *q, struct bio **bio_orig,
>                  if (rw == WRITE) {
>                          char *vto, *vfrom;
> 
> -                       flush_dcache_page(from->bv_page);
> +                       if (!PageSlab(from->bv_page))
> + flush_dcache_page(from->bv_page);
>                          vto = page_address(to->bv_page) + to->bv_offset;
>                          vfrom = kmap(from->bv_page) + from->bv_offset;
>                          memcpy(vto, vfrom, to->bv_len);
> 
> Who can give some suggestions to me.
  This looks sensible to me since userspace won't ever see the contents of
b_frozen_data and generally slab allocation cannot be visible from
userspace. But I'll leave the final word to mm people.

  BTW, if you want to get your patch accepted, please read
Documentation/SubmittingPatches and follow the guidelines there.

Thanks for reporting this!

								Honza 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
