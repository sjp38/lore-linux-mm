Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 45FB96008C6
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:02:30 -0400 (EDT)
Message-ID: <4C738A8E.7050502@redhat.com>
Date: Tue, 24 Aug 2010 12:02:06 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 04/12] Provide special async page fault handler when
 async PF capability is detected
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-5-git-send-email-gleb@redhat.com> <4C729865.3050409@redhat.com> <20100824073121.GW10499@redhat.com>
In-Reply-To: <20100824073121.GW10499@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 08/24/2010 10:31 AM, Gleb Natapov wrote:
> +
>>> +static void apf_task_wait(struct task_struct *tsk, u32 token)
>>> +{
>>> +	u32 key = hash_32(token, KVM_TASK_SLEEP_HASHBITS);
>>> +	struct kvm_task_sleep_head *b =&async_pf_sleepers[key];
>>> +	struct kvm_task_sleep_node n, *e;
>>> +	DEFINE_WAIT(wait);
>>> +
>>> +	spin_lock(&b->lock);
>>> +	e = _find_apf_task(b, token);
>>> +	if (e) {
>>> +		/* dummy entry exist ->   wake up was delivered ahead of PF */
>>> +		hlist_del(&e->link);
>>> +		kfree(e);
>>> +		spin_unlock(&b->lock);
>>> +		return;
>>> +	}
>>> +
>>> +	n.token = token;
>>> +	n.cpu = smp_processor_id();
>> What's the meaning of cpu?  Won't the waiter migrate to other cpus?
> Waiter cannot migrate to other cpu since it is sleeping. It may be
> scheduled to run on any cpu when it will be waked.

What if you have a spurious wakeup?  Also, nothing prevents the 
scheduler from migrating the thread even if it is sleeping.  It may not 
do so now, but it might do it in the future.

Oh, it probably does now on cpu hotunplug.

Why do you need n.cpu?


>>> +			spin_unlock(&b->lock);
>>> +			cpu_relax();
>>> +			goto again;
>>> +		}
>> The other cpu might be waiting for us to yield.  We can fix it later
>> with the the pv spinlock infrastructure.
>>
> This busy wait happens only if (very small) allocation fails, so if
> a guest ever hits this code path I expect it to be on his way to die
> anyway.

Hm.  I don't have a good feel on how rare atomic allocation failures are 
on common workloads.

Note a kmem_cache for apfs will make failures even more rare.

>> Or, we can avoid the allocation.  If at most one apf can be pending
>> (is this true?), we can use a per-cpu variable for this dummy entry.
>>
> We can have may outstanding apfs.

But, while we're processing an apf, we can't take any more.

So we can have a buffer of one pre-allocated entry per cpu, and do 
something like:

apf:
   disable apf for this cpu
   handle apf using buffered entry
   enable interrupts
   allocate new entry
   buffer it
   enable apf for that cpu

this trades off a bigger apf disabled window for not busy looping.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
