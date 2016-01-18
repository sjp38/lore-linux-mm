Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A537B6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:38:28 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 65so153483066pff.2
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:38:28 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id k79si37916563pfj.46.2016.01.17.23.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jan 2016 23:38:27 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id gi1so39620215pac.2
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:38:27 -0800 (PST)
Date: Mon, 18 Jan 2016 16:39:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118073939.GA30668@swordfish>
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox>
 <20160118065434.GB459@swordfish>
 <20160118071157.GD7453@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160118071157.GD7453@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz

On (01/18/16 16:11), Minchan Kim wrote:
[..]
> > so, even if clear_bit_unlock/test_and_set_bit_lock do smp_mb or
> > barrier(), there is no corresponding barrier from record_obj()->WRITE_ONCE().
> > so I don't think WRITE_ONCE() will help the compiler, or am I missing
> > something?
> 
> We need two things

thanks.

> 1. compiler barrier

um... probably gcc can reorder that sequence to something like this

	*handle = obj_malloc()   /* unpin the object */
	zs_object_copy(*handle, used_obj, class) /* now use it*/

ok.


> 2. memory barrier.
> 
> As compiler barrier, WRITE_ONCE works to prevent store tearing here
> by compiler.
> However, if we omit unpin_tag here, we lose memory barrier(e,g, smp_mb)
> so another CPU could see stale data caused CPU memory reordering.

oh... good find! lost release semantic of unpin_tag()...

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
