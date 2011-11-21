Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 180D96B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:04:54 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 21 Nov 2011 22:34:48 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pALH4ght4800670
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 22:34:42 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pALH4f6t012220
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 04:04:41 +1100
Message-ID: <4ECA84A8.5030005@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2011 22:34:40 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com> <201111192257.19763.rjw@sisk.pl> <4EC8984E.30005@linux.vnet.ibm.com> <201111201124.17528.rjw@sisk.pl> <4EC9D557.9090008@linux.vnet.ibm.com> <20111121164006.GB15314@google.com>
In-Reply-To: <20111121164006.GB15314@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On 11/21/2011 10:10 PM, Tejun Heo wrote:
> Hello, Srivatsa.
> 
> On Mon, Nov 21, 2011 at 10:06:39AM +0530, Srivatsa S. Bhat wrote:
>> void lock_system_sleep(void)
>> {
>> 	/* simplified freezer_do_not_count() */
>> 	current->flags |= PF_FREEZER_SKIP;
>>
>> 	mutex_lock(&pm_mutex);
>>
>> }
>>
>> void unlock_system_sleep(void)
>> {
>> 	mutex_unlock(&pm_mutex);
>>
>> 	/* simplified freezer_count() */
>> 	current->flags &= ~PF_FREEZER_SKIP;
>>
>> }
>>
>> We probably don't want the restriction that freezer_do_not_count() and
>> freezer_count() work only for userspace tasks. So I have open coded
>> the relevant parts of those functions here.
>>
>> I haven't tested this solution yet. Let me know if this solution looks
>> good and I'll send it out as a patch after testing and analyzing some
>> corner cases, if any.

I tested this, and it works great! I'll send the patch in some time.

> 
> Ooh ooh, I definitely like this one much better. 

Thanks :-) Even I like it far better than all those ugly hacks I proposed
earlier ;-)

> Oleg did something
> similar w/ wait_event_freezekillable() too.  On related notes,
> 
> * I think it would be better to remove direct access to pm_mutex and
>   use [un]lock_system_sleep() universally.  I don't think hinging it
>   on CONFIG_HIBERNATE_CALLBACKS buys us anything.
> 

Which direct access to pm_mutex are you referring to?
Other than suspend/hibernation call paths, I think mem-hotplug is the only
subsystem trying to access pm_mutex. I haven't checked thoroughly though. 

But yes, using lock_system_sleep() for mutually excluding some code path
from suspend/hibernation is good, and that is one reason why I wanted
to fix this API ASAP. But as long as memory hotplug is the only direct user
of pm_mutex, is it justified to remove the CONFIG_HIBERNATE_CALLBACKS
restriction and make it generic? I don't know...

Or, are you saying that we should use these APIs even in suspend/hibernate
call paths? That's not such a bad idea either...

[ On a totally different note, I was wondering:- if mem-hotplug wants to
exclude itself from hibernation alone, CONFIG_HIBERNATE_CALLBACKS is not
the right way to do it, because, it would still unintentionally exclude
itself from suspend also! (if suspend and hibernation are both enabled).
I don't think we should worry about this too much, because we don't get
much benefit trying to make mem-hotplug co-exist with suspend.. In fact,
I would say, its even better to let it be this way and exclude suspend
as well, since running exotic stuff like memory hotplug during suspend
or hibernation is best avoided ;-) ]

> * In the longer term, we should be able to toggle PF_NOFREEZE instead
>   as SKIP doesn't mean anything different.  We'll probably need a
>   better API tho.  But for now SKIP should work fine.
> 

Yep, I agree.

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
