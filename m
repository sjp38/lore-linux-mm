Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DB9086B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:34:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 13:04:39 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7N7YHuq7668070
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:04:17 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7N7YHVD022533
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:34:17 +1000
Message-ID: <5035DCF7.1030006@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2012 15:34:15 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between secondary
 MMU and host
References: <503358FF.3030009@linux.vnet.ibm.com> <20120821150618.GJ27696@redhat.com> <5034763D.60508@linux.vnet.ibm.com> <20120822162955.GT29978@redhat.com> <20120822121535.8be38858.akpm@linux-foundation.org> <20120822195043.GA8107@redhat.com>
In-Reply-To: <20120822195043.GA8107@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 08/23/2012 03:50 AM, Andrea Arcangeli wrote:
> Hi Andrew,
> 
> On Wed, Aug 22, 2012 at 12:15:35PM -0700, Andrew Morton wrote:
>> On Wed, 22 Aug 2012 18:29:55 +0200
>> Andrea Arcangeli <aarcange@redhat.com> wrote:
>>
>>> On Wed, Aug 22, 2012 at 02:03:41PM +0800, Xiao Guangrong wrote:
>>>> On 08/21/2012 11:06 PM, Andrea Arcangeli wrote:
>>>>> CPU0  		    	    	CPU1
>>>>> 				oldpage[1] == 0 (both guest & host)
>>>>> oldpage[0] = 1
>>>>> trigger do_wp_page
>>>>
>>>> We always do ptep_clear_flush before set_pte_at_notify(),
>>>> at this point, we have done:
>>>>   pte = 0 and flush all tlbs
>>>>> mmu_notifier_change_pte
>>>>> spte = newpage + writable
>>>>> 				guest does newpage[1] = 1
>>>>> 				vmexit
>>>>> 				host read oldpage[1] == 0
>>>>
>>>>                   It can not happen, at this point pte = 0, host can not
>>>> 		  access oldpage anymore, host read can generate #PF, it
>>>>                   will be blocked on page table lock until CPU 0 release the lock.
>>>
>>> Agreed, this is why your fix is safe.
>>>
>>> ...
>>>
>>> Thanks a lot for fixing this subtle race!
>>
>> I'll take that as an ack.
> 
> Yes thanks!
> 

Andrew, Andrea,

Thanks for your time to review the patch.

> I'd also like a comment that explains why in that case the order is
> reversed. The reverse order immediately rings an alarm bell otherwise
> ;). But the comment can be added with an incremental patch.
> 
>> Unfortunately we weren't told the user-visible effects of the bug,
>> which often makes it hard to determine which kernel versions should be
>> patched.  Please do always provide this information when fixing a bug.

Okay, i will pay more attention to this.

> 
> This is best answered by Xiao who said it's a testcase triggering
> this.
> 
> It requires the guest reading memory on CPU0 while the host writes to
> the same memory on CPU1, while CPU2 triggers the copy on write fault
> on another part of the same page (slightly before CPU1 writes). The
> host writes of CPU1 would need to happen in a microsecond window, and
> they wouldn't be immediately propagated to the guest in CPU0. They
> would still appear in the guest but with a microsecond delay (the
> guest has the spte mapped readonly when this happens so it's only a
> guest "microsecond delayed reading" problem as far as I can tell). I
> guess most of the time it would fall into the undefined by timing
> scenario so it's hard to tell how the side effect could escalate.

Yes, i agree. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
