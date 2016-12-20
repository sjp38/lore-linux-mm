Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14C3C6B0335
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:35:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so302699338pgi.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:35:44 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e11si22801660pgp.204.2016.12.20.08.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 08:35:42 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id i5so3029803pgh.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:35:42 -0800 (PST)
Date: Tue, 20 Dec 2016 16:35:40 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH V2 1/2] mm/memblock.c: trivial code refine in
 memblock_is_region_memory()
Message-ID: <20161220163540.GA13224@vultr.guest>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
 <20161219151514.GB5175@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219151514.GB5175@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2016 at 04:15:14PM +0100, Michal Hocko wrote:
>On Sun 18-12-16 14:47:49, Wei Yang wrote:
>> The base address is already guaranteed to be in the region by
>> memblock_search().
>

Hi, Michal

Nice to receive your comment.

>First of all the way how the check is removed is the worst possible...
>Apart from that it is really not clear to me why checking the base
>is not needed. You are mentioning memblock_search but what about other
>callers? adjust_range_page_size_mask e.g...
>

Hmm... the memblock_search() is called by memblock_is_region_memory(). Maybe I
paste the whole function here would clarify the change.

int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
{
	int idx = memblock_search(&memblock.memory, base);
	phys_addr_t end = base + memblock_cap_size(base, &size);

	if (idx == -1)
		return 0;
	return memblock.memory.regions[idx].base <= base &&
		(memblock.memory.regions[idx].base +
		 memblock.memory.regions[idx].size) >= end;
}

So memblock_search() will search "base" in memblock.memory. If "base" is not
in memblock.memory, idx would be -1. Then following code will not be executed.

And if the following code is executed, it means idx is not -1 and
memblock_search() has found the "base" in memblock.memory.regions[idx], which
is ture for statement (memblock.memory.regions[idx].base <= base).

>You also didn't mention what is the motivation of this change? What will
>work better or why it makes sense in general?
>

The purpose is to improve the code by reduce an extra check.

>Also this seems to be a general purpose function so it should better
>be robust.
>

I think it is as robust as it was.

>> This patch removes the check on base.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Without a proper justification and with the horrible way how it is done
>Nacked-by: Michal Hocko <mhocko@suse.com>
>

Not sure I make it clear or I may miss something?

>> ---
>>  mm/memblock.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 7608bc3..cd85303 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1615,7 +1615,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
>>  
>>  	if (idx == -1)
>>  		return 0;
>> -	return memblock.memory.regions[idx].base <= base &&
>> +	return /* memblock.memory.regions[idx].base <= base && */
>>  		(memblock.memory.regions[idx].base +
>>  		 memblock.memory.regions[idx].size) >= end;
>>  }
>> -- 
>> 2.5.0
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
