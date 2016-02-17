Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 53FB86B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:33:12 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b67so3235977qgb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:33:12 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id o13si35480771qkl.55.2016.02.16.19.33.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 19:33:11 -0800 (PST)
Subject: Re: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
References: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
 <20160217022552.GB535@swordfish>
From: xuyiping <xuyiping@hisilicon.com>
Message-ID: <56C3E91B.1030101@hisilicon.com>
Date: Wed, 17 Feb 2016 11:29:31 +0800
MIME-Version: 1.0
In-Reply-To: <20160217022552.GB535@swordfish>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, YiPing Xu <xuyiping@huawei.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com

HI, Sergery

On 2016/2/17 10:26, Sergey Senozhatsky wrote:
> Hello,
>
> On (02/17/16 09:56), YiPing Xu wrote:
>>   static int create_handle_cache(struct zs_pool *pool)
>> @@ -1127,11 +1126,9 @@ static void __zs_unmap_object(struct mapping_area *area,
>>   		goto out;
>>
>>   	buf = area->vm_buf;
>> -	if (!area->huge) {
>> -		buf = buf + ZS_HANDLE_SIZE;
>> -		size -= ZS_HANDLE_SIZE;
>> -		off += ZS_HANDLE_SIZE;
>> -	}
>> +	buf = buf + ZS_HANDLE_SIZE;
>> +	size -= ZS_HANDLE_SIZE;
>> +	off += ZS_HANDLE_SIZE;
>>
>>   	sizes[0] = PAGE_SIZE - off;
>>   	sizes[1] = size - sizes[0];
>
>
> hm, indeed.
>
> shouldn't it depend on class->huge?
>
> void *zs_map_object()
> {

	if (off + class->size <= PAGE_SIZE) {

for huge object, the code will get into this branch, there is no more 
huge object process in __zs_map_object.

		/* this object is contained entirely within a page */
		area->vm_addr = kmap_atomic(page);
		ret = area->vm_addr + off;
		goto out;
	}


> 	void *ret = __zs_map_object(area, pages, off, class->size);
>
> 	if (!class->huge)
> 		ret += ZS_HANDLE_SIZE;  /* area->vm_buf + ZS_HANDLE_SIZE */
>
> 	return ret;
> }

void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
{
	..

	area = this_cpu_ptr(&zs_map_area);
	if (off + class->size <= PAGE_SIZE)

for huge object, the code will get into this branch, so, in 
__zs_unmap_object there is no depend on class->huge.

it is a little implicated here.

		kunmap_atomic(area->vm_addr);
	else {
		struct page *pages[2];

		pages[0] = page;
		pages[1] = get_next_page(page);
		BUG_ON(!pages[1]);

		__zs_unmap_object(area, pages, off, class->size);
	}

	..
}


> static void __zs_unmap_object(struct mapping_area *area...)
> {
> 	char *buf = area->vm_buf;
>
> 	/* handle is in page->private for class->huge */
>
> 	buf = buf + ZS_HANDLE_SIZE;
> 	size -= ZS_HANDLE_SIZE;
> 	off += ZS_HANDLE_SIZE;
>
> 	memcpy(..);
> }
>
> 	-ss
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
