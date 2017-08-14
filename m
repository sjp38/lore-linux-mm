Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4C2D6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:42:51 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id f72so195153751ywb.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:42:51 -0700 (PDT)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com. [209.85.216.169])
        by mx.google.com with ESMTPS id y19si1995097ywy.661.2017.08.14.11.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 11:42:51 -0700 (PDT)
Received: by mail-qt0-f169.google.com with SMTP id p3so56502510qtg.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:42:50 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
 <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
 <20170811211302.limmjv4rmq23b25b@smitten> <20170812111733.GA16374@remoulade>
 <20170814162219.h2lcmli677bx2lwh@smitten>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <86105819-3ec6-e220-5ba3-787bbeecb6ba@redhat.com>
Date: Mon, 14 Aug 2017 11:42:45 -0700
MIME-Version: 1.0
In-Reply-To: <20170814162219.h2lcmli677bx2lwh@smitten>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On 08/14/2017 09:22 AM, Tycho Andersen wrote:
> On Sat, Aug 12, 2017 at 12:17:34PM +0100, Mark Rutland wrote:
>> Hi,
>>
>> On Fri, Aug 11, 2017 at 03:13:02PM -0600, Tycho Andersen wrote:
>>> On Fri, Aug 11, 2017 at 10:25:14AM -0700, Laura Abbott wrote:
>>>> On 08/09/2017 01:07 PM, Tycho Andersen wrote:
>>>>> @@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
>>>>>  		next = pmd_addr_end(addr, end);
>>>>>  
>>>>>  		/* try section mapping first */
>>>>> -		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
>>>>> +		if (use_section_mapping(addr, next, phys) &&
>>>>>  		    (flags & NO_BLOCK_MAPPINGS) == 0) {
>>>>>  			pmd_set_huge(pmd, phys, prot);
>>>>>  
>>>>>
>>>>
>>>> There is already similar logic to disable section mappings for
>>>> debug_pagealloc at the start of map_mem, can you take advantage
>>>> of that?
>>>
>>> You're suggesting something like this instead? Seems to work fine.
>>>
>>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>>> index 38026b3ccb46..3b2c17bbbf12 100644
>>> --- a/arch/arm64/mm/mmu.c
>>> +++ b/arch/arm64/mm/mmu.c
>>> @@ -434,6 +434,8 @@ static void __init map_mem(pgd_t *pgd)
>>>  
>>>  	if (debug_pagealloc_enabled())
>>>  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>>> +	if (IS_ENABLED(CONFIG_XPFO))
>>> +		flags |= NO_BLOCK_MAPPINGS;
>>>  
>>
>> IIUC, XPFO carves out individual pages just like DEBUG_PAGEALLOC, so you'll
>> also need NO_CONT_MAPPINGS.
> 
> Yes, thanks!
> 
> Tycho
> 

Setting NO_CONT_MAPPINGS fixes the TLB conflict aborts I was seeing
on my machine.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
