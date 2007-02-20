Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1K6wmFr291316
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 17:58:51 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1K6kPml178994
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 17:46:26 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1K6gA1b030211
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 17:42:10 +1100
Message-ID: <45DA97E2.9050707@linux.vnet.ibm.com>
Date: Tue, 20 Feb 2007 12:10:34 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH][2/4] Add RSS accounting and control
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219065034.3626.2658.sendpatchset@balbir-laptop> <20070219005828.3b774d8f.akpm@linux-foundation.org> <45D97DF8.5080000@in.ibm.com> <20070219030141.42c65bc0.akpm@linux-foundation.org> <45D9856D.1070902@in.ibm.com> <20070219032352.2856af36.akpm@linux-foundation.org> <45D9906F.2090605@in.ibm.com> <6599ad830702190409x4f64e56ex4044a12d949e44af@mail.gmail.com> <45D9AFBE.5020107@in.ibm.com> <45D9CB43.6000909@linux.vnet.ibm.com> <45D9CD97.6000804@in.ibm.com>
In-Reply-To: <45D9CD97.6000804@in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Paul Menage <menage@google.com>, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, xemul@sw.ru, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org
List-ID: <linux-mm.kvack.org>


Balbir Singh wrote:
> Vaidyanathan Srinivasan wrote:
>> Balbir Singh wrote:
>>> Paul Menage wrote:
>>>> On 2/19/07, Balbir Singh <balbir@in.ibm.com> wrote:
>>>>>> More worrisome is the potential for use-after-free.  What prevents the
>>>>>> pointer at mm->container from referring to freed memory after we're dropped
>>>>>> the lock?
>>>>>>
>>>>> The container cannot be freed unless all tasks holding references to it are
>>>>> gone,
>>>> ... or have been moved to other containers. If you're not holding
>>>> task->alloc_lock or one of the container mutexes, there's nothing to
>>>> stop the task being moved to another container, and the container
>>>> being deleted.
>>>>
>>>> If you're in an RCU section then you can guarantee that the container
>>>> (that you originally read from the task) and its subsystems at least
>>>> won't be deleted while you're accessing them, but for accounting like
>>>> this I suspect that's not enough, since you need to be adding to the
>>>> accounting stats on the correct container. I think you'll need to hold
>>>> mm->container_lock for the duration of memctl_update_rss()
>>>>
>>>> Paul
>>>>
>>> Yes, that sounds like the correct thing to do.
>>>
>> Accounting accuracy will anyway be affected when a process is migrated
>> while it is still allocating pages.  Having a lock here does not
>> necessarily improve the accounting accuracy.  Charges from the old
>> container would have to be moved to the new container before deletion
>> which implies all tasks have already left the container and no
>> mm_struct is holding a pointer to it.
>>
>> The only condition that will break our code will be if the container
>> pointer becomes invalid while we are updating stats.  This can be
>> prevented by RCU section as mentioned by Paul.  I believe explicit
>> lock and unlock may not provide additional benefit here.
>>
> 
> Yes, if the container pointer becomes invalid, then consider the following
> scenario
> 
> 1. Use RCU, get a reference to the container
> 2. All tasks/mm's move to newer container (and the accounting information
>     moves)
> 3. Container is RCU deleted
> 4. We still charge the older container that is going to be deleted soon
> 5. Release RCU
> 6. RCU garbage collects (callback runs)
> 
> We end up charging/uncharging a soon to be deleted container, that
> is not good.
> 
> What did I miss?

You are right.  We should go with your read/write lock method.  Later
we can evaluate if using an RCU and then fixing the wrong charge will
work better or worse.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
