Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC68D6B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 11:20:51 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 9 Nov 2011 16:19:10 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pA9GHRpZ2375684
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 03:17:30 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pA9GKS8l003251
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 03:20:28 +1100
Message-ID: <4EBAA847.1060907@linux.vnet.ibm.com>
Date: Wed, 09 Nov 2011 21:50:23 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
References: <4EB8E969.6010502@suse.cz> <1320766151-2619-1-git-send-email-aarcange@redhat.com> <1320766151-2619-2-git-send-email-aarcange@redhat.com> <4EB98A83.3040101@linux.vnet.ibm.com> <4EBA75F2.4080800@linux.vnet.ibm.com> <20111109155342.GA1260@google.com>
In-Reply-To: <20111109155342.GA1260@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 11/09/2011 09:23 PM, Tejun Heo wrote:
> Hello, Andrea, Srivatsa.
> 
> On Wed, Nov 09, 2011 at 06:15:38PM +0530, Srivatsa S. Bhat wrote:
>>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>>> index 4298aba..67311d1 100644
>>>> --- a/mm/huge_memory.c
>>>> +++ b/mm/huge_memory.c
>>>> @@ -2277,6 +2277,7 @@ static struct page *khugepaged_alloc_hugepage(void)
>>>>  		if (!hpage) {
>>>>  			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>>>>  			khugepaged_alloc_sleep();
>>>> +			try_to_freeze();
>>>>  		} else
>>>>  			count_vm_event(THP_COLLAPSE_ALLOC);
>>>>  	} while (unlikely(!hpage) &&
>>>> @@ -2331,7 +2332,7 @@ static int khugepaged(void *none)
>>>>  {
>>>>  	struct mm_slot *mm_slot;
>>>>
>>>> -	set_freezable();
>>>> +	set_freezable_with_signal();
>>>>  	set_user_nice(current, 19);
> 
> Oooh, please don't do that.  It's already gone in the pm tree.  It
> would be best if wait_event_freezable_timeout() can be used
> (ie. wakeup condition should be set somewhere) but, if not, something
> like the following sould work.
> 
> static void khugepaged_alloc_sleep(void)
> {
> 	DEFINE_WAIT(wait);
> 	add_wait_queue(&khugepaged_wait, &wait);
> 	try_to_freeze();
> 	schedule_timeout_interruptible(
> 			msecs_to_jiffies(
> 				khugepaged_alloc_sleep_millisecs));
> 	try_to_freeze();
> 	remove_wait_queue(&khugepaged_wait, &wait);
> }
> 												

Right, Andrea this is what I meant. First of all we don't need both
set_freezable_with_signal() _and_ an additional try_to_freeze().
And since we are anyway doing away with set_freezable_with_signal(),
we can just use try_to_freeze() as Tejun suggested above.  

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
