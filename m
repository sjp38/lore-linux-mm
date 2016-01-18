Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A802E6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:07:41 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e65so156834670pfe.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:07:41 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id 63si39193212pft.41.2016.01.18.03.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 03:07:41 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id yy13so32478600pab.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 03:07:40 -0800 (PST)
Date: Mon, 18 Jan 2016 20:08:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118110852.GB30668@swordfish>
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox>
 <20160118065434.GB459@swordfish>
 <20160118071157.GD7453@bbox>
 <20160118073939.GA30668@swordfish>
 <569C9A1F.2020303@suse.cz>
 <20160118082000.GA20244@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160118082000.GA20244@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/18/16 17:20), Minchan Kim wrote:
[..]
> > > oh... good find! lost release semantic of unpin_tag()...
> > 
> > Ah, release semantic, good point indeed. OK then we need the v2 approach again,
> > with WRITE_ONCE() in record_obj(). Or some kind of record_obj_release() with
> > release semantic, which would be a bit more effective, but I guess migration is
> > not that critical path to be worth introducing it.
> 
> WRITE_ONCE in record_obj would add more memory operations in obj_malloc
> but I don't feel it's too heavy in this phase so,
> 
> How about this? Junil, Could you resend patch if others agree this?
> Thanks.
> 
> +/*
> + * record_obj updates handle's value to free_obj and it shouldn't
> + * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, otherwise
> + * it breaks synchronization using pin_tag(e,g, zs_free) so let's
> + * keep the lock bit.
> + */
>  static void record_obj(unsigned long handle, unsigned long obj)
>  {
> -	*(unsigned long *)handle = obj;
> +	int locked = (*(unsigned long *)handle) & (1<<HANDLE_PIN_BIT);
> +	unsigned long val = obj | locked;
> +
> +	/*
> +	 * WRITE_ONCE could prevent store tearing like below
> +	 * *(unsigned long *)handle = free_obj
> +	 * *(unsigned long *)handle |= locked;
> +	 */
> +	WRITE_ONCE(*(unsigned long *)handle, val);
>  }

given that memory barriers are also compiler barriers, wouldn't

	record_obj()
	{
		barrier
		*(unsigned long *)handle) = new
	}

suffice?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
