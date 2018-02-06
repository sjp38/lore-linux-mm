Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1266B000C
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 10:06:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b6so1548815pgu.16
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 07:06:43 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0131.outbound.protection.outlook.com. [104.47.1.131])
        by mx.google.com with ESMTPS id o190si1892005pga.553.2018.02.06.07.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 07:06:41 -0800 (PST)
Subject: Re: [PATCH 1/2] rcu: Transform kfree_rcu() into kvfree_rcu()
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <151791238553.5994.4933976056810745303.stgit@localhost.localdomain>
 <20180206093451.0de5ceeb@gandalf.local.home>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <52fe3917-cf72-d512-8422-d53bacf40113@virtuozzo.com>
Date: Tue, 6 Feb 2018 18:06:33 +0300
MIME-Version: 1.0
In-Reply-To: <20180206093451.0de5ceeb@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06.02.2018 17:34, Steven Rostedt wrote:
> On Tue, 06 Feb 2018 13:19:45 +0300
> Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> /**
>> - * kfree_rcu() - kfree an object after a grace period.
>> - * @ptr:	pointer to kfree
>> + * kvfree_rcu() - kvfree an object after a grace period.
>> + * @ptr:	pointer to kvfree
>>   * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
>>   *
> 
> You may want to add a big comment here that states this works for both
> free vmalloc and kmalloc data. Because if I saw this, I would think it
> only works for vmalloc, and start implementing a custom one for kmalloc
> data.

There are kfree_rcu() and vfree_rcu() defined below, and they will give
compilation error if someone tries to implement one more primitive with
the same name.

We may add a comment, but I'm not sure it will be good if people will use
unpaired brackets like:

	obj = kmalloc(..)
	kvfree_rcu(obj,..)

after they read such a commentary that it works for both vmalloc and kmalloc.
After this unpaired behavior distribute over the kernel, we won't be able
to implement some debug on top of this defines (I'm not sure it will be really
need in the future, but anyway).

Though, we may add a comment forcing use of paired bracket. Something like:

/**
  * kvfree_rcu() - kvfree an object after a grace period.
    This is a primitive for objects allocated via kvmalloc*() family primitives.
    Do not use it to free kmalloc() and vmalloc() allocated objects, use kfree_rcu()
    and vfree_rcu() wrappers instead.

How are you about this?

Kirill

>> - * Many rcu callbacks functions just call kfree() on the base structure.
>> + * Many rcu callbacks functions just call kvfree() on the base structure.
>>   * These functions are trivial, but their size adds up, and furthermore
>>   * when they are used in a kernel module, that module must invoke the
>>   * high-latency rcu_barrier() function at module-unload time.
>>   *
>> - * The kfree_rcu() function handles this issue.  Rather than encoding a
>> - * function address in the embedded rcu_head structure, kfree_rcu() instead
>> + * The kvfree_rcu() function handles this issue.  Rather than encoding a
>> + * function address in the embedded rcu_head structure, kvfree_rcu() instead
>>   * encodes the offset of the rcu_head structure within the base structure.
>>   * Because the functions are not allowed in the low-order 4096 bytes of
>>   * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
>>   * If the offset is larger than 4095 bytes, a compile-time error will
>> - * be generated in __kfree_rcu().  If this error is triggered, you can
>> + * be generated in __kvfree_rcu().  If this error is triggered, you can
>>   * either fall back to use of call_rcu() or rearrange the structure to
>>   * position the rcu_head structure into the first 4096 bytes.
>>   *
>> @@ -871,9 +871,12 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
>>   * The BUILD_BUG_ON check must not involve any function calls, hence the
>>   * checks are done in macros here.
>>   */
>> -#define kfree_rcu(ptr, rcu_head)					\
>> -	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>> +#define kvfree_rcu(ptr, rcu_head)					\
>> +	__kvfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
>>  
>> +#define kfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
>> +
>> +#define vfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
>>  
>>  /*
>>   * Place this after a lock-acquisition primitive to guarantee that
>> diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
>> index ce9beec35e34..2e484aaa534f 100644
>> --- a/include/linux/rcutiny.h
>> +++ b/include/linux/rcutiny.h
>> @@ -84,8 +84,8 @@ static inline void synchronize_sched_expedited(void)
>>  	synchronize_sched();
>>  }
>>  
>> -static inline void kfree_call_rcu(struct rcu_head *head,
>> -				  rcu_callback_t func)
>> +static inline void kvfree_call_rcu(struct rcu_head *head,
>> +				   rcu_callback_t func)
>>  {
>>  	call_rcu(head, func);
>>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
