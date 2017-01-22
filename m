Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B418A6B0033
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 22:02:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so155723565pfw.5
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 19:02:42 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f17si11384780pge.120.2017.01.21.19.02.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Jan 2017 19:02:41 -0800 (PST)
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
Date: Sun, 22 Jan 2017 10:58:38 +0800
MIME-Version: 1.0
In-Reply-To: <20170121084338.GA405@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

1. memset is just set a int value but i want to set a long value.
2. using clear_page rather than memset MAYBE due to in arm64 arch
    it is a 64-bytes operations.

6.6.4. Data Cache Zero

The ARMv8-A architecture introduces a Data Cache Zero by Virtual Address (DC ZVA) instruction. This enables a block of 64
bytes in memory, aligned to 64 bytes in size, to be set to zero. If the DC ZVA instruction misses in the cache, it clears main
memory, without causing an L1 or L2 cache allocation.

but i only consider the arm64 arch, other archs need to be reviewed.

On 2017/1/21 16:43, Sergey Senozhatsky wrote:
> Hello,
>
> On (01/13/17 16:29), zhouxianrong@huawei.com wrote:
> [..]
>> --- a/Documentation/ABI/testing/sysfs-block-zram
>> +++ b/Documentation/ABI/testing/sysfs-block-zram
>> @@ -86,21 +86,21 @@ Description:
>>  		ones are sent by filesystem mounted with discard option,
>>  		whenever some data blocks are getting discarded.
>>
>> -What:		/sys/block/zram<id>/zero_pages
>> +What:		/sys/block/zram<id>/same_pages
> [..]
>> -zero_pages        RO    the number of zero filled pages written to this disk
>> +same_pages        RO    the number of same element filled pages written to this disk
> [..]
>> -	zero_pages
>> +	same_pages
>>  	num_migrated
>> +}
>
> we removed deprecated sysfs attrs. zero_pages does not exist anymore.
>
>>  static size_t zram_get_obj_size(struct zram_meta *meta, u32 index)
>>  {
>>  	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
>> @@ -158,31 +169,76 @@ static inline void update_used_max(struct zram *zram,
>>  	} while (old_max != cur_max);
>>  }
>>
>> -static bool page_zero_filled(void *ptr)
>> +static inline void zram_fill_page(char *ptr, unsigned long value)
>> +{
>> +	int i;
>> +	unsigned long *page = (unsigned long *)ptr;
>> +
>> +	if (likely(value == 0)) {
>> +		clear_page(ptr);
>> +	} else {
>> +		for (i = PAGE_SIZE / sizeof(unsigned long) - 1; i >= 0; i--)
>> +			page[i] = value;
>> +	}
>
> any particular reason not to use memset() here?
> memset() can be faster that that, right?
>
>
> [..]
>>  /* Flags for zram pages (table[page_no].value) */
>>  enum zram_pageflags {
>> -	/* Page consists entirely of zeros */
>> -	ZRAM_ZERO = ZRAM_FLAG_SHIFT,
>> +	/* Page consists entirely of same elements */
>> +	ZRAM_SAME = ZRAM_FLAG_SHIFT,
>>  	ZRAM_ACCESS,	/* page is now accessed */
> [..]
>> @@ -83,7 +86,7 @@ struct zram_stats {
>>  	atomic64_t failed_writes;	/* can happen when memory is too low */
>>  	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
>>  	atomic64_t notify_free;	/* no. of swap slot free notifications */
>> -	atomic64_t zero_pages;		/* no. of zero filled pages */
>> +	atomic64_t same_pages;		/* no. of same element filled pages */
>
> not like this rename is particularity important, but ok. works for me.
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
