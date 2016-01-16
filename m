Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 109986B025B
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 03:16:40 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l65so45505359wmf.1
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 00:16:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si23348309wjx.165.2016.01.16.00.16.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Jan 2016 00:16:38 -0800 (PST)
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local> <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish> <5699F4C9.1070902@suse.cz>
 <20160116080650.GB566@swordfish>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5699FC69.4010000@suse.cz>
Date: Sat, 16 Jan 2016 09:16:41 +0100
MIME-Version: 1.0
In-Reply-To: <20160116080650.GB566@swordfish>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 16.1.2016 9:06, Sergey Senozhatsky wrote:
> On (01/16/16 08:44), Vlastimil Babka wrote:
>> On 16.1.2016 5:09, Sergey Senozhatsky wrote:
>>> On (01/15/16 16:49), Vlastimil Babka wrote:
>>
>> Hmm but that's an unpin, not a pin? A mistake or I'm missing something?
> 
> I'm sure it's just a compose-in-mail-app typo.

BTW, couldn't the correct fix also just look like this?

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9f15bdd9163c..43f743175ede 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1635,8 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct
size_class *class,
                free_obj = obj_malloc(d_page, class, handle);
                zs_object_copy(free_obj, used_obj, class);
                index++;
+               /* This also effectively unpins the handle */
                record_obj(handle, free_obj);
-               unpin_tag(handle);
                obj_free(pool, class, used_obj);
        }

But I'd still recommend WRITE_ONCE in record_obj(). And I'm not even sure it's
safe on all architectures to do a simple overwrite of a word against somebody
else trying to lock a bit there?

> 	-ss
> 
>> Anyway the compiler can do the same thing here without a WRITE_ONCE().
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
