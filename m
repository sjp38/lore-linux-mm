Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E75086B0253
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:11:01 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so124896219wmb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:11:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si25573068wmh.52.2016.01.18.06.11.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 06:11:00 -0800 (PST)
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox> <20160118065434.GB459@swordfish>
 <20160118071157.GD7453@bbox> <20160118073939.GA30668@swordfish>
 <569C9A1F.2020303@suse.cz> <20160118082000.GA20244@bbox>
 <569CD817.7090309@suse.cz> <20160118140955.GB20244@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569CF272.3020001@suse.cz>
Date: Mon, 18 Jan 2016 15:10:58 +0100
MIME-Version: 1.0
In-Reply-To: <20160118140955.GB20244@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/18/2016 03:09 PM, Minchan Kim wrote:
>
> True.
> Let's go with this. I hope it's the last.
> Thanks, guys.
>
>  From 389bbcbad9aba7d86a575b8c6ea3b8985cc801ea Mon Sep 17 00:00:00 2001
> From: Junil Lee <junil0814.lee@lge.com>
> Date: Mon, 18 Jan 2016 23:01:29 +0900
> Subject: [PATCH v5] zsmalloc: fix migrate_zspage-zs_free race condition
>
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
>    find_alloced_obj
>      trypin_tag
>        set HANDLE_PIN_BIT			zs_free()
> 						  pin_tag()
>    obj_malloc() -- new object, no tag
>    record_obj() -- remove HANDLE_PIN_BIT	    set HANDLE_PIN_BIT
>    unpin_tag()  -- remove zs_free's HANDLE_PIN_BIT
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
> This patch keeps the lock bit in migration path and update
> value atomically.
>
> Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Cc: <stable@vger.kernel.org> [4.1+]
> ---
>   mm/zsmalloc.c | 14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e7414cec220b..2d7c4c11fc63 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -309,7 +309,12 @@ static void free_handle(struct zs_pool *pool, unsigned long handle)
>
>   static void record_obj(unsigned long handle, unsigned long obj)
>   {
> -	*(unsigned long *)handle = obj;
> +	/*
> +	 * lsb of @obj represents handle lock while other bits
> +	 * represent object value the handle is pointing so
> +	 * updating shouldn't do store tearing.
> +	 */
> +	WRITE_ONCE(*(unsigned long *)handle, obj);
>   }
>
>   /* zpool driver */
> @@ -1635,6 +1640,13 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>   		free_obj = obj_malloc(d_page, class, handle);
>   		zs_object_copy(free_obj, used_obj, class);
>   		index++;
> +		/*
> +		 * record_obj updates handle's value to free_obj and it will
> +		 * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, which
> +		 * breaks synchronization using pin_tag(e,g, zs_free) so
> +		 * let's keep the lock bit.
> +		 */
> +		free_obj |= BIT(HANDLE_PIN_BIT);
>   		record_obj(handle, free_obj);
>   		unpin_tag(handle);
>   		obj_free(pool, class, used_obj);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
