Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9FF828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 09:34:54 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id n128so118558256pfn.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 06:34:54 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id dg7si16832983pad.75.2016.01.15.06.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 06:34:53 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id e65so8631900pfe.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 06:34:53 -0800 (PST)
Date: Fri, 15 Jan 2016 23:34:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115143434.GA25332@blaptop.local>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junil Lee <junil0814.lee@lge.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 15, 2016 at 04:39:11PM +0900, Junil Lee wrote:
> To prevent unlock at the not correct situation, tagging the new obj to
> assure lock in migrate_zspage() before right unlock path.
> 
> Two functions are in race condition by tag which set 1 on last bit of
> obj, however unlock succrently when update new obj to handle before call
> unpin_tag() which is right unlock path.
> 
> summarize this problem by call flow as below:
> 
> 		CPU0								CPU1
> migrate_zspage
> find_alloced_obj()
> 	trypin_tag() -- obj |= HANDLE_PIN_BIT
> obj_malloc() -- new obj is not set			zs_free
> record_obj() -- unlock and break sync		pin_tag() -- get lock
> unpin_tag()
> 
> Before code make crash as below:
> 	Unable to handle kernel NULL pointer dereference at virtual address 00000000
> 	CPU: 0 PID: 19001 Comm: CookieMonsterCl Tainted:
> 	PC is at get_zspage_mapping+0x0/0x24
> 	LR is at obj_free.isra.22+0x64/0x128
> 	Call trace:
> 		[<ffffffc0001a3aa8>] get_zspage_mapping+0x0/0x24
> 		[<ffffffc0001a4918>] zs_free+0x88/0x114
> 		[<ffffffc00053ae54>] zram_free_page+0x64/0xcc
> 		[<ffffffc00053af4c>] zram_slot_free_notify+0x90/0x108
> 		[<ffffffc000196638>] swap_entry_free+0x278/0x294
> 		[<ffffffc000199008>] free_swap_and_cache+0x38/0x11c
> 		[<ffffffc0001837ac>] unmap_single_vma+0x480/0x5c8
> 		[<ffffffc000184350>] unmap_vmas+0x44/0x60
> 		[<ffffffc00018a53c>] exit_mmap+0x50/0x110
> 		[<ffffffc00009e408>] mmput+0x58/0xe0
> 		[<ffffffc0000a2854>] do_exit+0x320/0x8dc
> 		[<ffffffc0000a3cb4>] do_group_exit+0x44/0xa8
> 		[<ffffffc0000ae1bc>] get_signal+0x538/0x580
> 		[<ffffffc000087e44>] do_signal+0x98/0x4b8
> 		[<ffffffc00008843c>] do_notify_resume+0x14/0x5c
> 
> and for test, print obj value after pin_tag() in zs_free().
> Sometimes obj is even number means break synchronization.
> 
> After patched, crash is not occurred and obj is only odd number in same
> situation.

If you verified it solved your problem, we should mark this patch
as stable.

> 
> Signed-off-by: Junil Lee <junil0814.lee@lge.com>

Acked-by: Minchan Kim <minchan@kernel.org>

Below comment.

> ---
>  mm/zsmalloc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e7414ce..a24ccb1 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1635,6 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  		free_obj = obj_malloc(d_page, class, handle);
>  		zs_object_copy(free_obj, used_obj, class);
>  		index++;
> +		/* Must not unlock before unpin_tag() */

I want to make comment more clear.

/*
 * record_obj updates handle's value to free_obj and it will invalidate
 * lock bit(ie, HANDLE_PIN_BIT) of handle, which breaks synchronization
 * using pin_tag(e,g, zs_free) so let's keep the lock bit.
 */

Thanks.

> +		free_obj |= BIT(HANDLE_PIN_BIT);
>  		record_obj(handle, free_obj);
>  		unpin_tag(handle);
>  		obj_free(pool, class, used_obj);
> -- 
> 2.6.2
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
