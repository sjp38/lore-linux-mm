Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 01CBE6B000A
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 22:04:20 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 18 Jan 2013 08:32:39 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 01BDB394004C
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 08:34:14 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0I34CvO7537060
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 08:34:12 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0I34DZW000501
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 14:04:13 +1100
Message-ID: <50F8BBAA.1020904@linux.vnet.ibm.com>
Date: Fri, 18 Jan 2013 11:04:10 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
References: <20130115162956.GH3438@sgi.com> <20130116200018.GA3460@sgi.com> <20130116210124.GB3460@sgi.com> <50F765CC.9040608@linux.vnet.ibm.com> <20130117111213.GM3438@sgi.com> <50F7EC6B.6030401@linux.vnet.ibm.com> <20130117134523.GN3438@sgi.com> <50F8B67F.4090901@linux.vnet.ibm.com> <20130118024856.GC3460@sgi.com>
In-Reply-To: <20130118024856.GC3460@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On 01/18/2013 10:48 AM, Robin Holt wrote:
> On Fri, Jan 18, 2013 at 10:42:07AM +0800, Xiao Guangrong wrote:
>> On 01/17/2013 09:45 PM, Robin Holt wrote:
>>> On Thu, Jan 17, 2013 at 08:19:55PM +0800, Xiao Guangrong wrote:
>>>> On 01/17/2013 07:12 PM, Robin Holt wrote:
>>>>> On Thu, Jan 17, 2013 at 10:45:32AM +0800, Xiao Guangrong wrote:
>>>>>> On 01/17/2013 05:01 AM, Robin Holt wrote:
>>>>>>>
>>>>>>> There is a race condition between mmu_notifier_unregister() and
>>>>>>> __mmu_notifier_release().
>>>>>>>
>>>>>>> Assume two tasks, one calling mmu_notifier_unregister() as a result
>>>>>>> of a filp_close() ->flush() callout (task A), and the other calling
>>>>>>> mmu_notifier_release() from an mmput() (task B).
>>>>>>>
>>>>>>>                 A                               B
>>>>>>> t1                                              srcu_read_lock()
>>>>>>> t2              if (!hlist_unhashed())
>>>>>>> t3                                              srcu_read_unlock()
>>>>>>> t4              srcu_read_lock()
>>>>>>> t5                                              hlist_del_init_rcu()
>>>>>>> t6                                              synchronize_srcu()
>>>>>>> t7              srcu_read_unlock()
>>>>>>> t8              hlist_del_rcu()  <--- NULL pointer deref.
>>>>>>
>>>>>> The detailed code here is:
>>>>>> 	hlist_del_rcu(&mn->hlist);
>>>>>>
>>>>>> Can mn be NULL? I do not think so since mn is always the embedded struct
>>>>>> of the caller, it be freed after calling mmu_notifier_unregister.
>>>>>
>>>>> If you look at __mmu_notifier_release() it is using hlist_del_init_rcu()
>>>>> which will set the hlist->pprev to NULL.  When hlist_del_rcu() is called,
>>>>> it attempts to update *hlist->pprev = hlist->next and that is where it
>>>>> takes the NULL pointer deref.
>>>>
>>>> Yes, sorry for my careless. So, That can not be fixed by using
>>>> hlist_del_init_rcu instead?
>>>
>>> The problem is the race described above.  Thread 'A' has checked to see
>>> if n->pprev != NULL.  Based upon that, it did called the mn->release()
>>> method.  While it was trying to call the release method, thread 'B' ended
>>> up calling hlist_del_init_rcu() which set n->pprev = NULL.  Then thread
>>> 'A' got to run again and now it tries to do the hlist_del_rcu() which, as
>>> part of __hlist_del(), the pprev will be set to n->pprev (which is NULL)
>>> and then *pprev = n->next; hits the NULL pointer deref hits.
>>
>> I mean using hlist_del_init_rcu instead of hlist_del_rcu in
>> mmu_notifier_unregister(), hlist_del_init_rcu is aware of ->pprev.
> 
> How does that address the calling of the ->release() method twice?

Hmm, what is the problem of it? If it is just for "performance issue", i think
it is not worth introducing so complex lock rule just for the really rare case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
