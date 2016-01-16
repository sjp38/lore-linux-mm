Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0D7828DF
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 02:44:11 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so47768319wmf.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 23:44:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v188si10180865wmg.123.2016.01.15.23.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 23:44:09 -0800 (PST)
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local> <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5699F4C9.1070902@suse.cz>
Date: Sat, 16 Jan 2016 08:44:09 +0100
MIME-Version: 1.0
In-Reply-To: <20160116040913.GA566@swordfish>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 16.1.2016 5:09, Sergey Senozhatsky wrote:
> On (01/15/16 16:49), Vlastimil Babka wrote:
> [..]
>>
>> Could you please also help making the changelog more clear?
>>
>>>
>>>> +		free_obj |= BIT(HANDLE_PIN_BIT);
>>>>  		record_obj(handle, free_obj);
>>
>> I think record_obj() should use WRITE_ONCE() or something like that.
>> Otherwise the compiler is IMHO allowed to reorder this, i.e. first to assign
>> free_obj to handle, and then add the PIN bit there.
> 
> good note.
> 
> ... or do both things in record_obj() (per Minchan)
> 
> 	record_obj(handle, obj)
> 	{
> 	        *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);

Hmm but that's an unpin, not a pin? A mistake or I'm missing something?
Anyway the compiler can do the same thing here without a WRITE_ONCE().

> 	}
> 
> 	-ss
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
