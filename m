Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D10676B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:16:54 -0400 (EDT)
Message-ID: <4DD5345B.8010305@atmel.com>
Date: Thu, 19 May 2011 17:16:43 +0200
From: Ludovic Desroches <ludovic.desroches@atmel.com>
MIME-Version: 1.0
Subject: Re: atmel-mci causes kernel panic when CONFIG_DEBUG_VM is set
References: <4DD4CC68.80408@atmel.com>	<BANLkTinaPW5xcdrNewJC6OW9nqWHC_-TVw@mail.gmail.com> <4DD4E1DF.7030005@atmel.com> <4DD50A72.2050501@atmel.com>
In-Reply-To: <4DD50A72.2050501@atmel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ludovic Desroches <ludovic.desroches@atmel.com>, linux-mm@kvack.org, christoph@lameter.com
Cc: linux-arm-kernel@lists.infradead.org

As suggested I forward the question to Christoph Lameter and linux-mm.

Thanks for your help.

Regards

Ludovic Desroches

On 5/19/2011 2:17 PM, Ludovic Desroches wrote:
> On 5/19/2011 11:24 AM, Ludovic Desroches wrote:
>> On 5/19/2011 10:04 AM, Barry Song wrote:
>>> 2011/5/19 Ludovic Desroches<ludovic.desroches@atmel.com>:
>>>> Hello,
>>>>
>>>> There is a bug with the atmel-mci driver when the debug feature
>>>> CONFIG_DEBUG_VM is set.
>>>>
>>>> Into the atmci_read_data_pio function we use flush_dcache_page (do 
>>>> we really
>>>> need it?) which call the page_mapping function where we can find
>>>> VM_BUG_ON(PageSlab(Page)). Then a kernel panic happens.
>>>>
>>>> I don't understand the purpose of the VM_BUG_ON(PageSlab(Page)) 
>>>> (the page
>>>> comes from a scatter list). How could I correct this problem?
>>> linux/include/linux/mmdebug.h:
>>>
>>> #ifdef CONFIG_DEBUG_VM
>>> #define VM_BUG_ON(cond) BUG_ON(cond)
>>> #else
>>> #define VM_BUG_ON(cond) do { (void)(cond); } while (0)
>>> #endif
>>>
>>> it is something like "assert" in kernel.
>>
>> Thanks for your answer but I know that. My question is more focused 
>> on why there is this check.
> This the reason:
>
> commit b5fab14e5d87df4d94161ae5f5e0c8625f9ffda2
> Author: Christoph Lameter <clameter@sgi.com>
> Date:   Tue Jul 17 04:03:33 2007 -0700
>
>     Add VM_BUG_ON in case someone uses page_mapping on a slab page
>
>     Detect slab objects being passed to the page oriented functions of 
> the VM.
>
>     It is not sufficient to simply return NULL because the functions 
> calling
>     page_mapping may depend on other items of the page_struct also to 
> be setup
>     properly.  Moreover slab object may not be properly aligned.  The 
> page
>     oriented functions of the VM expect to operate on page aligned, 
> page sized
>     objects.  Operations on object straddling page boundaries may only 
> affect the
>     objects partially which may lead to surprising results.
>
>     It is better to detect eventually remaining uses and eliminate them.
>
>
>> Is flushing a page taken from a slab forbidden ? Is it risky ? Is it 
>> no sense ?
>>
> Other drivers do a flush_dcache_page on a page coming from a scatter 
> list. So I think they will also have an assert when CONFIG_DEBUG_VM is 
> set.
>
> What is the proper way to do this flush (if needed) ?
>
>
> Regards,
>
> Ludovic
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
