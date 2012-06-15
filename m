Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E4AE46B006C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 12:50:36 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 12:50:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3850838C805C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 12:49:38 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FGnaJn187048
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 12:49:37 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FGnYpp032326
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 10:49:35 -0600
Message-ID: <4FDB674C.9070304@linux.vnet.ibm.com>
Date: Fri, 15 Jun 2012 11:48:12 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins> <4FDB5107.3000308@linux.vnet.ibm.com> <7e925563-082b-468f-a7d8-829e819eeac0@default>
In-Reply-To: <7e925563-082b-468f-a7d8-829e819eeac0@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 06/15/2012 11:35 AM, Dan Magenheimer wrote:

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
> less.


To add to what Nitin just sent, without the page mapping, zsmalloc and
the late xvmalloc have the same issue.  Say you have a whole class of
objects that are 3/4 of a page.  Without the mapping, you can't cross
non-contiguous page boundaries and you'll have 25% fragmentation in the
memory pool.  This is the whole point of zsmalloc.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
