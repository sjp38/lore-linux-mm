Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 278CA6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:54:03 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n5so49868429wmn.0
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:54:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ld8si36658905wjc.77.2016.01.17.23.54.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 23:54:01 -0800 (PST)
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox> <20160118065434.GB459@swordfish>
 <20160118071157.GD7453@bbox> <20160118073939.GA30668@swordfish>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569C9A1F.2020303@suse.cz>
Date: Mon, 18 Jan 2016 08:54:07 +0100
MIME-Version: 1.0
In-Reply-To: <20160118073939.GA30668@swordfish>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 18.1.2016 8:39, Sergey Senozhatsky wrote:
> On (01/18/16 16:11), Minchan Kim wrote:
> [..]
>>> so, even if clear_bit_unlock/test_and_set_bit_lock do smp_mb or
>>> barrier(), there is no corresponding barrier from record_obj()->WRITE_ONCE().
>>> so I don't think WRITE_ONCE() will help the compiler, or am I missing
>>> something?
>>
>> We need two things
>> 2. memory barrier.
>>
>> As compiler barrier, WRITE_ONCE works to prevent store tearing here
>> by compiler.
>> However, if we omit unpin_tag here, we lose memory barrier(e,g, smp_mb)
>> so another CPU could see stale data caused CPU memory reordering.
> 
> oh... good find! lost release semantic of unpin_tag()...

Ah, release semantic, good point indeed. OK then we need the v2 approach again,
with WRITE_ONCE() in record_obj(). Or some kind of record_obj_release() with
release semantic, which would be a bit more effective, but I guess migration is
not that critical path to be worth introducing it.

Thanks,
Vlastimil

> 
> 	-ss
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
