Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF2396B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 04:05:54 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id pA995luu025761
	for <linux-mm@kvack.org>; Wed, 9 Nov 2011 14:35:47 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pA993DRr4112392
	for <linux-mm@kvack.org>; Wed, 9 Nov 2011 14:33:17 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pA993D3m001188
	for <linux-mm@kvack.org>; Wed, 9 Nov 2011 14:33:13 +0530
Message-ID: <4EBA41D1.3020008@linux.vnet.ibm.com>
Date: Wed, 09 Nov 2011 14:33:13 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
References: <4EB8E969.6010502@suse.cz> <1320766151-2619-1-git-send-email-aarcange@redhat.com> <1320766151-2619-2-git-send-email-aarcange@redhat.com> <4EB98A83.3040101@linux.vnet.ibm.com> <20111109000146.GA5075@redhat.com>
In-Reply-To: <20111109000146.GA5075@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 11/09/2011 05:31 AM, Andrea Arcangeli wrote:
> On Wed, Nov 09, 2011 at 01:31:07AM +0530, Srivatsa S. Bhat wrote:
>> On 11/08/2011 08:59 PM, Andrea Arcangeli wrote:
>>> Lack of set_freezable_with_signal() prevented khugepaged to be waken
>>> up (and prevented to sleep again) across the
>>> schedule_timeout_interruptible() calls after freezing() becomes
>>> true. The tight loop in khugepaged_alloc_hugepage() also missed one
>>> try_to_freeze() call in case alloc_hugepage() would repeatedly fail in
>>> turn preventing the loop to break and to reach the try_to_freeze() in
>>> the khugepaged main loop.
>>>
>>> khugepaged would still freeze just fine by trying again the next
>>> minute but it's better if it freezes immediately.
>>>
>>> Reported-by: Jiri Slaby <jslaby@suse.cz>
>>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>>> ---
>>>  mm/huge_memory.c |    3 ++-
>>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 4298aba..67311d1 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -2277,6 +2277,7 @@ static struct page *khugepaged_alloc_hugepage(void)
>>>  		if (!hpage) {
>>>  			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>>>  			khugepaged_alloc_sleep();
>>> +			try_to_freeze();
>>>  		} else
>>>  			count_vm_event(THP_COLLAPSE_ALLOC);
>>>  	} while (unlikely(!hpage) &&
>>> @@ -2331,7 +2332,7 @@ static int khugepaged(void *none)
>>>  {
>>>  	struct mm_slot *mm_slot;
>>>
>>> -	set_freezable();
>>> +	set_freezable_with_signal();
>>>  	set_user_nice(current, 19);
>>>
>>>  	/* serialize with start_khugepaged() */
>>>
>>
>> Why do we need to use both set_freezable_with_signal() and an additional
>> try_to_freeze()? Won't just using either one of them be good enough?
>> Or am I missing something here?
> 
> set_freezable_with_signal() makes khugepaged quit and not re-enter the
> sleep, try_to_freeze is needed to get the task from freezing to
> frozen, otherwise it'll loop without getting frozen.
> 

Sorry, I still don't get it. Correct me if I am wrong, but my understanding
is this:

There are 2 ways to freeze a freezable kernel thread (one which has unset
the PF_NOFREEZE flag by calling set_freezable()):

 set TIF_FREEZE flag and,

a) send a signal if PF_FREEZER_NOSIG is unset for that kernel thread (due
   to the call to set_freezable_with_signal()). Then, try_to_freeze() will
   get called in the signal handler.

b) otherwise, just wake up the kernel thread and hope that the kernel thread
   itself will call try_to_freeze() sometime soon.

Now coming to your patch,
Case 1: You use set_freezable_with_signal() instead of set_freezable():

        In this case, since the kernel thread doesn't block signals for
        freezing, it will get a signal (with TIF_FREEZE set) and the signal
        handler will call try_to_freeze(). So, no need for additional
        try_to_freeze() here. 

Case 2: You add the extra try_to_freeze():

        In this case, the freezer will wake up the kernel thread, which in
        turn will now execute the newly added try_to_freeze() and will get
        frozen successfully. So, no need for set_freezable_with_signal() here.

Rafael, am I right?

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
