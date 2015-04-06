Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5256B00C5
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 17:30:33 -0400 (EDT)
Received: by pdea3 with SMTP id a3so56534093pde.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 14:30:32 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id tc7si8227162pbc.137.2015.04.06.14.30.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 06 Apr 2015 14:30:32 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NME00A3WMLIP700@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Apr 2015 22:34:30 +0100 (BST)
Message-id: <5522FAEA.4040707@partner.samsung.com>
Date: Tue, 07 Apr 2015 00:30:18 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: add functions to get region pages counters
References: <1428064960-8279-1-git-send-email-stefan.strogin@gmail.com>
 <20150403145828.90a597f5dc1c308d7c31a37d@linux-foundation.org>
In-reply-to: <20150403145828.90a597f5dc1c308d7c31a37d@linux-foundation.org>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Strogin <stefan.strogin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Pintu Kumar <pintu.k@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Michal Hocko <mhocko@suse.cz>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, s.strogin@partner.samsung.com

Hello Andrew,

On 04/04/15 00:58, Andrew Morton wrote:
> On Fri, 03 Apr 2015 15:42:40 +0300 Stefan Strogin <stefan.strogin@gmail.com> wrote:
> 
>> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>>
>> Here are two functions that provide interface to compute/get used size
>> and size of biggest free chunk in cma region. Add that information to debugfs.
>>
>> ...
>>
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -53,6 +53,36 @@ unsigned long cma_get_size(const struct cma *cma)
>>  	return cma->count << PAGE_SHIFT;
>>  }
>>  
>> +unsigned long cma_get_used(struct cma *cma)
>> +{
>> +	unsigned long ret = 0;
>> +
>> +	mutex_lock(&cma->lock);
>> +	/* pages counter is smaller than sizeof(int) */
>> +	ret = bitmap_weight(cma->bitmap, (int)cma->count);
>> +	mutex_unlock(&cma->lock);
>> +
>> +	return ret << cma->order_per_bit;
>> +}
>> +
>> +unsigned long cma_get_maxchunk(struct cma *cma)
>> +{
>> +	unsigned long maxchunk = 0;
>> +	unsigned long start, end = 0;
>> +
>> +	mutex_lock(&cma->lock);
>> +	for (;;) {
>> +		start = find_next_zero_bit(cma->bitmap, cma->count, end);
>> +		if (start >= cma->count)
>> +			break;
>> +		end = find_next_bit(cma->bitmap, cma->count, start);
>> +		maxchunk = max(end - start, maxchunk);
>> +	}
>> +	mutex_unlock(&cma->lock);
>> +
>> +	return maxchunk << cma->order_per_bit;
>> +}
> 
> This will cause unused code to be included in cma.o when
> CONFIG_CMA_DEBUGFS=n.  Please review the below patch which moves it all
> into cma_debug.c
> 

Thank you very much for the reply and for the patches.

>> --- a/mm/cma_debug.c
>> +++ b/mm/cma_debug.c
>> @@ -33,6 +33,28 @@ static int cma_debugfs_get(void *data, u64 *val)
>>  
>>  DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
>>  
>> +static int cma_used_get(void *data, u64 *val)
>> +{
>> +	struct cma *cma = data;
>> +
>> +	*val = cma_get_used(cma);
>> +
>> +	return 0;
>> +}
> 
> We have cma_used_get() and cma_get_used().  Confusing!  Can we think of
> better names for one or both of them?
> 

Oh. Excuse me for the bad code.
Wouldn't it be better to merge cma_get_used() and cma_get_maxchunk()
into cma_*_get() as they aren't used anywhere else?
Please see the following patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
