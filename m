Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 60D0F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:03:16 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so168505409pac.2
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:03:16 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id yt3si727139pab.60.2016.01.17.23.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jan 2016 23:03:15 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id pv5so33254341pac.0
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:03:15 -0800 (PST)
Date: Mon, 18 Jan 2016 16:04:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118070427.GC459@swordfish>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
 <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish>
 <5699F4C9.1070902@suse.cz>
 <20160116080650.GB566@swordfish>
 <5699FC69.4010000@suse.cz>
 <20160118063246.GB7453@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160118063246.GB7453@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

oh, you replied in this thread.

On (01/18/16 15:32), Minchan Kim wrote:
> >                 free_obj = obj_malloc(d_page, class, handle);
> >                 zs_object_copy(free_obj, used_obj, class);
> >                 index++;
> > +               /* This also effectively unpins the handle */
> >                 record_obj(handle, free_obj);
> > -               unpin_tag(handle);
> >                 obj_free(pool, class, used_obj);
> >         }
> > 
> > But I'd still recommend WRITE_ONCE in record_obj(). And I'm not even sure it's
> 
> Thanks for the reivew. Yeah, we need WRITE_ONCE in record_obj but
> your version will not work. IMHO, WRITE_ONCE can prevent store-tearing
> but it couldn't prevent reordering. IOW, we need some barrier as unlock
> and clear_bit_unlock includes it.
> So, we shouldn't omit unpin_tag there.

but there is only one store operation after this patch.

static void record_obj(unsigned long handle, unsigned long obj)
{
	*(unsigned long *)handle = obj;
}

does the re-ordering problem exist? zs_free() will see the
old pinned handle and spin, until record_obj() from migrate.

	-ss

> > safe on all architectures to do a simple overwrite of a word against somebody
> > else trying to lock a bit there?
> 
> Hmm, I think it shouldn't be a problem. It's word-alinged, word-sized
> store so it should be atomic.
> 
> As other example, we have been used lock_page for a bit of page->flags
> and used other bits in there with __set_bit(ie, __SetPageXXX).
> I guess it's same situation with us just except we are spinning there.
> But it is worth to dobule check so need to help lock guys.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
