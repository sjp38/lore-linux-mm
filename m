Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id C5BA46B006C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 12:46:08 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6767048pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 09:46:08 -0700 (PDT)
Message-ID: <4FDB66B7.2010803@vflare.org>
Date: Fri, 15 Jun 2012 09:45:43 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins> <4FDB5107.3000308@linux.vnet.ibm.com> <7e925563-082b-468f-a7d8-829e819eeac0@default>
In-Reply-To: <7e925563-082b-468f-a7d8-829e819eeac0@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 06/15/2012 09:35 AM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Sent: Friday, June 15, 2012 9:13 AM
>> To: Peter Zijlstra
>> Cc: Minchan Kim; Greg Kroah-Hartman; Nitin Gupta; Dan Magenheimer; linux-kernel@vger.kernel.org;
>> linux-mm@kvack.org; Thomas Gleixner; Ingo Molnar; Tejun Heo; David Howells; x86@kernel.org; Nick
>> Piggin
>> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
>>
>> On 05/17/2012 09:51 AM, Peter Zijlstra wrote:
>>
>>> On Thu, 2012-05-17 at 17:11 +0900, Minchan Kim wrote:
>>>>> +++ b/arch/x86/include/asm/tlbflush.h
>>>>> @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsigned long start,
>>>>>       flush_tlb_all();
>>>>>  }
>>>>>
>>>>> +static inline void local_flush_tlb_kernel_range(unsigned long start,
>>>>> +             unsigned long end)
>>>>> +{
>>>>> +     if (cpu_has_invlpg) {
>>>>> +             while (start < end) {
>>>>> +                     __flush_tlb_single(start);
>>>>> +                     start += PAGE_SIZE;
>>>>> +             }
>>>>> +     } else
>>>>> +             local_flush_tlb();
>>>>> +}
>>>
>>> It would be much better if you wait for Alex Shi's patch to mature.
>>> doing the invlpg thing for ranges is not an unconditional win.
>>
>> From what I can tell Alex's patches have stalled.  The last post was v6
>> on 5/17 and there wasn't a single reply to them afaict.
>>
>> According to Alex's investigation of this "tipping point", it seems that
>> a good generic value is 8.  In other words, on most x86 hardware, it is
>> cheaper to flush up to 8 tlb entries one by one rather than doing a
>> complete flush.
>>
>> So we can do something like:
>>
>>      if (cpu_has_invlpg && (end - start)/PAGE_SIZE <= 8) {
>>              while (start < end) {
>>
>> Would this be acceptable?
> 
> Hey Seth, Nitin --
> 
> After more work digging around zsmalloc and zbud, I really think
> this TLB flushing, as well as the "page pair mapping" code can be
> completely eliminated IFF zsmalloc is limited to items PAGE_SIZE or
> less.  Since this is already true of zram (and in-tree zcache), and
> zsmalloc currently has no other users, I think you should seriously
> consider limiting zsmalloc in that way, or possibly splitting out
> one version of zsmalloc which handles items PAGE_SIZE or less,
> and a second version that can handle larger items but has (AFAIK)
> no users.
> 
> If you consider it an option to have (a version of) zsmalloc
> limited to items PAGE_SIZE or less, let me know and we can
> get into the details.
> 


zsmalloc is already limited to objects of size PAGE_SIZE or less. This
two-page splitting is for efficiently storing objects in range
(PAGE_SIZE/2, PAGE_SIZE) which is very common in both zram and zcache.

SLUB achieves this efficiency by allocating higher order pages but that
is not an option for zsmalloc.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
