Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8F45D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:33:55 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so414549319pac.1
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 22:33:55 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id c10si273432pat.170.2016.01.17.22.33.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 22:33:54 -0800 (PST)
Date: Mon, 18 Jan 2016 15:36:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118063611.GC7453@bbox>
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
In-Reply-To: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junil Lee <junil0814.lee@lge.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz

Hello Junil,

On Mon, Jan 18, 2016 at 02:39:56PM +0900, Junil Lee wrote:
> record_obj() in migrate_zspage() does not preserve handle's
> HANDLE_PIN_BIT, set by find_aloced_obj()->trypin_tag(), and implicitly
> (accidentally) un-pins the handle, while migrate_zspage() still performs
> an explicit unpin_tag() on the that handle.
> This additional explicit unpin_tag() introduces a race condition with
> zs_free(), which can pin that handle by this time, so the handle becomes
> un-pinned.
> 
> Schematically, it goes like this:
> 
> CPU0					CPU1
> migrate_zspage
>   find_alloced_obj
>     trypin_tag
>       set HANDLE_PIN_BIT			zs_free()
> 						  pin_tag()
>   obj_malloc() -- new object, no tag
>   record_obj() -- remove HANDLE_PIN_BIT	    set HANDLE_PIN_BIT
>   unpin_tag()  -- remove zs_free's HANDLE_PIN_BIT
> 
> The race condition may result in a NULL pointer dereference:
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
> Fix the race by removing explicit unpin_tag() from migrate_zspage().
> 
> Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> ---
>  mm/zsmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e7414ce..0acfa20 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1635,8 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  		free_obj = obj_malloc(d_page, class, handle);
>  		zs_object_copy(free_obj, used_obj, class);
>  		index++;
> +		/* This also effectively unpins the handle */

As reply of Vlastimil, I relied that I guess it doesn't work.
We shouldn't omit unpin_tag and we should add WRITE_ONCE in
record_obj.

As well, it's worth to dobule check with locking guys.
I will send updated version.

Thanks.


>  		record_obj(handle, free_obj);
> -		unpin_tag(handle);
>  		obj_free(pool, class, used_obj);
>  	}
>  
> -- 
> 2.6.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
