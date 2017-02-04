Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9E66B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 22:33:30 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id j49so34748770otb.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 19:33:30 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 21si11507961ote.167.2017.02.03.19.33.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 19:33:29 -0800 (PST)
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
 <20170203153350.GC2267@bombadil.infradead.org>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <2f856730-512e-7b0b-c0da-8c41305a3ce8@huawei.com>
Date: Sat, 4 Feb 2017 11:33:04 +0800
MIME-Version: 1.0
In-Reply-To: <20170203153350.GC2267@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

right, thanks.

On 2017/2/3 23:33, Matthew Wilcox wrote:
> On Fri, Feb 03, 2017 at 04:42:27PM +0800, zhouxianrong@huawei.com wrote:
>> +static inline void zram_fill_page_partial(char *ptr, unsigned int size,
>> +		unsigned long value)
>> +{
>> +	int i;
>> +	unsigned long *page;
>> +
>> +	if (likely(value == 0)) {
>> +		memset(ptr, 0, size);
>> +		return;
>> +	}
>> +
>> +	i = ((unsigned long)ptr) % sizeof(*page);
>> +	if (i) {
>> +		while (i < sizeof(*page)) {
>> +			*ptr++ = (value >> (i * 8)) & 0xff;
>> +			--size;
>> +			++i;
>> +		}
>> +	}
>> +
>> +	for (i = size / sizeof(*page); i > 0; --i) {
>> +		page = (unsigned long *)ptr;
>> +		*page = value;
>> +		ptr += sizeof(*page);
>> +		size -= sizeof(*page);
>> +	}
>> +
>> +	for (i = 0; i < size; ++i)
>> +		*ptr++ = (value >> (i * 8)) & 0xff;
>> +}
>
> You're assuming little-endian here.  I think you need to do a
> cpu_to_le() here, but I don't think we have a cpu_to_leul, only
> cpu_to_le64/cpu_to_le32.  So you may have some work to do ...
>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
