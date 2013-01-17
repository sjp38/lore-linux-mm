Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3B41E6B005D
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 07:20:07 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 22:15:18 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 56A062CE804A
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 23:20:00 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HC8KAL64684056
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 23:08:20 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HCJx9g021378
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 23:19:59 +1100
Message-ID: <50F7EC6B.6030401@linux.vnet.ibm.com>
Date: Thu, 17 Jan 2013 20:19:55 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
References: <20130115162956.GH3438@sgi.com> <20130116200018.GA3460@sgi.com> <20130116210124.GB3460@sgi.com> <50F765CC.9040608@linux.vnet.ibm.com> <20130117111213.GM3438@sgi.com>
In-Reply-To: <20130117111213.GM3438@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On 01/17/2013 07:12 PM, Robin Holt wrote:
> On Thu, Jan 17, 2013 at 10:45:32AM +0800, Xiao Guangrong wrote:
>> On 01/17/2013 05:01 AM, Robin Holt wrote:
>>>
>>> There is a race condition between mmu_notifier_unregister() and
>>> __mmu_notifier_release().
>>>
>>> Assume two tasks, one calling mmu_notifier_unregister() as a result
>>> of a filp_close() ->flush() callout (task A), and the other calling
>>> mmu_notifier_release() from an mmput() (task B).
>>>
>>>                 A                               B
>>> t1                                              srcu_read_lock()
>>> t2              if (!hlist_unhashed())
>>> t3                                              srcu_read_unlock()
>>> t4              srcu_read_lock()
>>> t5                                              hlist_del_init_rcu()
>>> t6                                              synchronize_srcu()
>>> t7              srcu_read_unlock()
>>> t8              hlist_del_rcu()  <--- NULL pointer deref.
>>
>> The detailed code here is:
>> 	hlist_del_rcu(&mn->hlist);
>>
>> Can mn be NULL? I do not think so since mn is always the embedded struct
>> of the caller, it be freed after calling mmu_notifier_unregister.
> 
> If you look at __mmu_notifier_release() it is using hlist_del_init_rcu()
> which will set the hlist->pprev to NULL.  When hlist_del_rcu() is called,
> it attempts to update *hlist->pprev = hlist->next and that is where it
> takes the NULL pointer deref.

Yes, sorry for my careless. So, That can not be fixed by using
hlist_del_init_rcu instead?

> 
>>
>>>
>>> Tested with this patch applied.  My test case which was failing
>>> approximately every 300th iteration passed 25,000 tests.
>>
>> Could you please share your test case?
> 
> I could but it would be very useless.  It depends upon having a SGI
> UV system with GRUs and and xpmem kernel module loaded.  If you would
> really like all the bits, I could provide them, but you will not be able
> to reproduce the failure.

Oh, i see. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
