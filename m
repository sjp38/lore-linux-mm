Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id AEA8E6B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 16:32:37 -0400 (EDT)
Message-ID: <51C8ACDA.4080400@hurleysoftware.com>
Date: Mon, 24 Jun 2013 16:32:26 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock acquisition
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>  <1371858700.22432.5.camel@schen9-DESK>  <51C558E2.1040108@hurleysoftware.com>  <1372017836.1797.14.camel@buesod1.americas.hpqcorp.net>  <1372093876.22432.34.camel@schen9-DESK>  <51C894C3.4040407@hurleysoftware.com> <1372101180.22432.58.camel@schen9-DESK>
In-Reply-To: <1372101180.22432.58.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 06/24/2013 03:13 PM, Tim Chen wrote:
> On Mon, 2013-06-24 at 14:49 -0400, Peter Hurley wrote:
>> On 06/24/2013 01:11 PM, Tim Chen wrote:
>>> On Sun, 2013-06-23 at 13:03 -0700, Davidlohr Bueso wrote:
>>>> On Sat, 2013-06-22 at 03:57 -0400, Peter Hurley wrote:
>>>>> On 06/21/2013 07:51 PM, Tim Chen wrote:
>>>>>>
>>>>>> +static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
>>>>>> +{
>>>>>> +	int retval = true;
>>>>>> +
>>>>>> +	/* Spin only if active writer running */
>>>>>> +	if (!sem->owner)
>>>>>> +		return false;
>>>>>> +
>>>>>> +	rcu_read_lock();
>>>>>> +	if (sem->owner)
>>>>>> +		retval = sem->owner->on_cpu;
>>>>>                             ^^^^^^^^^^^^^^^^^^
>>>>>
>>>>> Why is this a safe dereference? Could not another cpu have just
>>>>> dropped the sem (and thus set sem->owner to NULL and oops)?
>>>>>
>>>
>>> The rcu read lock should protect against sem->owner being NULL.
>>
>> It doesn't.
>>
>> Here's the comment from mutex_spin_on_owner():
>>
>>     /*
>>      * Look out! "owner" is an entirely speculative pointer
>>      * access and not reliable.
>>      */
>>
>
> In mutex_spin_on_owner, after rcu_read_lock, the owner_running()
> function de-references the owner pointer.

Only after establishing the following preconditions:
1. snapshot of owner is non-NULL
2. mutex->owner == snapshot owner
3. memory holding mutex has not been freed (that's what the
    rcu_read_lock() is for)

Only then is the owner dereferenced and only through the snapshot
(not the now-possibly-rewritten sem->owner).

> I'm using similar logic in rw-sem.

With crucial details absent.

Regards,
Peter Hurley


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
