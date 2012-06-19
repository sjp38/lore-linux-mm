Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id F1DCB6B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 13:32:17 -0400 (EDT)
Message-ID: <4FE0B79E.1060601@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 13:32:14 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com> <CAHGf_=pq_UJfr22kYC=vCyEDRKx75zt5eZ27+VcqFZFqc-KHTw@mail.gmail.com> <alpine.DEB.2.00.1206182321160.27620@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206182321160.27620@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

On 6/19/2012 2:26 AM, David Rientjes wrote:
> On Tue, 19 Jun 2012, KOSAKI Motohiro wrote:
> 
>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>> --- a/mm/oom_kill.c
>>> +++ b/mm/oom_kill.c
>>> @@ -746,10 +746,11 @@ out:
>>>        read_unlock(&tasklist_lock);
>>>
>>>        /*
>>> -        * Give "p" a good chance of killing itself before we
>>> +        * Give "p" a good chance of exiting before we
>>>         * retry to allocate memory unless "p" is current
>>>         */
>>> -       if (killed && !test_thread_flag(TIF_MEMDIE))
>>> +       if (killed && !fatal_signal_pending(current) &&
>>> +                     !(current->flags & PF_EXITING))
>>>                schedule_timeout_uninterruptible(1);
>>>  }
>>
>> Why don't check gfp_flags? I think the rule is,
>>
>> 1) a thread of newly marked as TIF_MEMDIE
>>     -> now it has a capability to access reseve memory. let's immediately retry.
>> 2) allocation for GFP_HIGHUSER_MOVABLE
>>     -> we can fail to allocate it safely. let's immediately fail.
>>         (I suspect we need to change page allocator too)
>> 3) GFP_KERNEL and PF_EXITING
>>     -> don't retry immediately. It shall fail again. let's wait until
>> killed process
>>         is exited.
>>
> 
> The killed process may exit but it does not guarantee that its memory will 
> be freed if it's shared with current.  This is the case that the patch is 
> addressing, where right now we unnecessarily schedule if current has been 
> killed or is already along the exit path.  We want to retry as soon as 
> possible so that either the allocation now succeeds or we can recall the 
> oom killer as soon as possible and get TIF_MEMDIE set because we have a 
> fatal signal so current may exit in a timely way as well.  The point is 
> that if current has either a SIGKILL or is already exiting as it returns 
> from the oom killer, it does no good to continue to stall and prevent that 
> memory freeing.

You missed live lock risk. immediate retry makes immediate fail if no one
freed any memory. Even if the task call out_of_memory() again, select_bad_process()
may return -1 and don't makes any forward progress.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
