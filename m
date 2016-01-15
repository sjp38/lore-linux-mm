Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 43FE4828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 10:49:47 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l65so25489354wmf.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 07:49:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ha10si18152355wjc.117.2016.01.15.07.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 07:49:46 -0800 (PST)
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56991514.9000609@suse.cz>
Date: Fri, 15 Jan 2016 16:49:40 +0100
MIME-Version: 1.0
In-Reply-To: <20160115143434.GA25332@blaptop.local>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/15/2016 03:34 PM, Minchan Kim wrote:
> On Fri, Jan 15, 2016 at 04:39:11PM +0900, Junil Lee wrote:
>>
>> Signed-off-by: Junil Lee <junil0814.lee@lge.com>
>
> Acked-by: Minchan Kim <minchan@kernel.org>
>
> Below comment.
>
>> ---
>>   mm/zsmalloc.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index e7414ce..a24ccb1 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -1635,6 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>>   		free_obj = obj_malloc(d_page, class, handle);
>>   		zs_object_copy(free_obj, used_obj, class);
>>   		index++;
>> +		/* Must not unlock before unpin_tag() */
>
> I want to make comment more clear.
>
> /*
>   * record_obj updates handle's value to free_obj and it will invalidate
>   * lock bit(ie, HANDLE_PIN_BIT) of handle, which breaks synchronization
>   * using pin_tag(e,g, zs_free) so let's keep the lock bit.
>   */
>
> Thanks.

Could you please also help making the changelog more clear?

>
>> +		free_obj |= BIT(HANDLE_PIN_BIT);
>>   		record_obj(handle, free_obj);

I think record_obj() should use WRITE_ONCE() or something like that.
Otherwise the compiler is IMHO allowed to reorder this, i.e. first to 
assign free_obj to handle, and then add the PIN bit there.

>>   		unpin_tag(handle);
>>   		obj_free(pool, class, used_obj);
>> --
>> 2.6.2
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
