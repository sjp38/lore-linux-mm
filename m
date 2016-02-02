Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 057756B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 10:28:29 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id x4so97814017lbm.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 07:28:28 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id m16si1134920lfb.93.2016.02.02.07.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 07:28:27 -0800 (PST)
Received: by mail-lb0-x234.google.com with SMTP id bc4so96477271lbc.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 07:28:27 -0800 (PST)
Subject: Re: [PATCH v1 1/8] kasan: Change the behavior of
 kmalloc_large_oob_right test
References: <cover.1453918525.git.glider@google.com>
 <35b553cafcd5b77838aeaf5548b457dfa09e30cf.1453918525.git.glider@google.com>
 <20160201213427.f428b08d.akpm@linux-foundation.org>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56B0CB60.1080506@gmail.com>
Date: Tue, 2 Feb 2016 18:29:36 +0300
MIME-Version: 1.0
In-Reply-To: <20160201213427.f428b08d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, rostedt@goodmis.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 02/02/2016 08:34 AM, Andrew Morton wrote:
> On Wed, 27 Jan 2016 19:25:06 +0100 Alexander Potapenko <glider@google.com> wrote:
> 
>> depending on which allocator (SLAB or SLUB) is being used
>>
>> ...
>>
>> --- a/lib/test_kasan.c
>> +++ b/lib/test_kasan.c
>> @@ -68,7 +68,22 @@ static noinline void __init kmalloc_node_oob_right(void)
>>  static noinline void __init kmalloc_large_oob_right(void)
>>  {
>>  	char *ptr;
>> -	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
>> +	size_t size;
>> +
>> +	if (KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE) {
>> +		/*
>> +		 * We're using the SLAB allocator. Allocate a chunk that fits
>> +		 * into a slab.
>> +		 */
>> +		size = KMALLOC_MAX_CACHE_SIZE - 256;
>> +	} else {
>> +		/*
>> +		 * KMALLOC_MAX_SIZE > KMALLOC_MAX_CACHE_SIZE.
>> +		 * We're using the SLUB allocator. Allocate a chunk that does
>> +		 * not fit into a slab to trigger the page allocator.
>> +		 */
>> +		size = KMALLOC_MAX_CACHE_SIZE + 10;
>> +	}
> 
> This seems a weird way of working out whether we're using SLAB or SLUB.
> 
> Can't we use, umm, #ifdef CONFIG_SLAB?  If not that then let's cook up
> something standardized rather than a weird just-happens-to-work like
> this.
> 

Actually it would be simpler to not use KMALLOC_MAX_CACHE_SIZE at all.
Simply replace it with 2 or 3 PAGE_SIZEs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
