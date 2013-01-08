Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8D54F6B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 20:45:47 -0500 (EST)
Message-ID: <50EB7A13.7080104@cn.fujitsu.com>
Date: Tue, 08 Jan 2013 09:44:51 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: memblock: fix wrong memmove size in memblock_merge_regions()
References: <1357530096-28548-1-git-send-email-linfeng@cn.fujitsu.com> <20130107132341.c8ca0060.akpm@linux-foundation.org>
In-Reply-To: <20130107132341.c8ca0060.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tj@kernel.org, mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 01/08/2013 05:23 AM, Andrew Morton wrote:
> On Mon, 7 Jan 2013 11:41:36 +0800
> Lin Feng <linfeng@cn.fujitsu.com> wrote:
> 
>> The memmove span covers from (next+1) to the end of the array, and the index
>> of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
>> array elements is (type->cnt - (i + 2)).
> 
> What are the user-visible effects of this bug?
Hi Andrew,

Since the remaining elements of the memblock array are move forward by one
element and there is only one additional element caused by this bug. 
So there won't be any write overflow here but read overflow. 
It may read one more element out of the array address if the array happens
to be full. Commonly it doesn't matter at all but if the array happens to
be located at the end a memblock, it may cause a invalid read operation
for the physical address doesn't exist. 

There are 2 *happens to be* here, so I think the probability is quite low,
I don't know if any guy is haunted by this bug before. 

Mostly I think it's user-invisible.

thanks,
linfeng
> 
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -314,7 +314,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
>>  		}
>>  
>>  		this->size += next->size;
>> -		memmove(next, next + 1, (type->cnt - (i + 1)) * sizeof(*next));
>> +		/* move forward from next + 1, index of which is i + 2 */
>> +		memmove(next, next + 1, (type->cnt - (i + 2)) * sizeof(*next));
>>  		type->cnt--;
>>  	}
>>  }
>> -- 
>> 1.7.11.7
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
