Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E95E56B0005
	for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:16:24 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so150598398pfn.3
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 20:16:24 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id sj10si22032380pab.65.2016.01.17.20.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jan 2016 20:16:24 -0800 (PST)
Received: by mail-pa0-x244.google.com with SMTP id a20so26995065pag.3
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 20:16:24 -0800 (PST)
Date: Mon, 18 Jan 2016 13:17:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118041735.GB415@swordfish>
References: <1453079732-44198-1-git-send-email-junil0814.lee@lge.com>
 <20160118041440.GA415@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160118041440.GA415@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Junil Lee <junil0814.lee@lge.com>, minchan@kernel.org, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky@gmail.com, Vlastimil Babka <vbabka@suse.cz>

On (01/18/16 13:14), Sergey Senozhatsky wrote:
> Cc Vlastimil,
> 
> Hello,
> 
> On (01/18/16 10:15), Junil Lee wrote:
> > To prevent unlock at the not correct situation, tagging the new obj to
> > assure lock in migrate_zspage() before right unlock path.
> > 
> > Two functions are in race condition by tag which set 1 on last bit of
> > obj, however unlock succrently when update new obj to handle before call
> > unpin_tag() which is right unlock path.
> > 
> > summarize this problem by call flow as below:
> > 
> > 		CPU0								CPU1
> > migrate_zspage
> > find_alloced_obj()
> > 	trypin_tag() -- obj |= HANDLE_PIN_BIT
> > obj_malloc() -- new obj is not set			zs_free
> > record_obj() -- unlock and break sync		pin_tag() -- get lock
> > unpin_tag()
> 
> Junil, can something like this be a bit simpler problem description?
> 
> ---
> 
> record_obj() in migrate_zspage() does not preserve handle's
> HANDLE_PIN_BIT, set by find_alloced_obj()->trypin_tag(), and
> implicitly (accidentally) un-pins the handle, while migrate_zspage()
> still performs an explicit unpin_tag() on the that handle.
> This additional explicit unpin_tag() introduces a race condition
> with zs_free(), which can pin that handle by this time, so the handle
> becomes un-pinned. Schematically, it goes like this:
> 
> CPU0							CPU1
> migrate_zspage
>   find_alloced_obj
>     trypin_tag
>       set HANDLE_PIN_BIT				zs_free()
> 							  pin_tag()
>   obj_malloc() -- new object, no tag
>   record_obj() -- remove HANDLE_PIN_BIT			   set HANDLE_PIN_BIT
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
> ---
> 
> 
> > and for test, print obj value after pin_tag() in zs_free().
> > Sometimes obj is even number means break synchronization.
> > 
> > After patched, crash is not occurred and obj is only odd number in same
> > situation.
> > 
> > Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> 
> I believe Vlastimil deserves a credit here (at least Suggested-by)
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> 
> 
> now, can the compiler re-order
> 
> 	record_obj(handle, free_obj);
> 	obj_free(pool, class, used_obj);

oh, disregard the last "re-ordering" commentary, sorry.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
