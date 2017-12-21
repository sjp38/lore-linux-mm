Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFBD16B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:31:46 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r6so8395940itr.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:31:46 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 5si14458049ioo.155.2017.12.21.09.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 09:31:45 -0800 (PST)
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
 <20171221123630.GB22405@bombadil.infradead.org>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <44044955-1ef9-1d1e-5311-d8edc006b812@oracle.com>
Date: Thu, 21 Dec 2017 09:31:23 -0800
MIME-Version: 1.0
In-Reply-To: <20171221123630.GB22405@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org



On 12/21/2017 04:36 AM, Matthew Wilcox wrote:
> On Thu, Dec 21, 2017 at 12:19:47AM -0800, rao.shoaib@oracle.com wrote:
>> This patch moves kfree_call_rcu() and related macros out of rcu code. A new
>> function __call_rcu_lazy() is created for calling __call_rcu() with the lazy
>> flag.
> Something you probably didn't know ... there are two RCU implementations
> in the kernel; Tree and Tiny.  It looks like you've only added
> __call_rcu_lazy() to Tree and you'll also need to add it to Tiny.
I left it out on purpose because the call in tiny is a little different

rcutiny.h:

static inline void kfree_call_rcu(struct rcu_head *head,
 A A A  A A A  A A A  A A A  A  void (*func)(struct rcu_head *rcu))
{
 A A A  call_rcu(head, func);
}

tree.c:

void kfree_call_rcu(struct rcu_head *head,
 A A A  A A A  A A A  void (*func)(struct rcu_head *rcu))
{
 A A A  __call_rcu(head, func, rcu_state_p, -1, 1);
}
EXPORT_SYMBOL_GPL(kfree_call_rcu);

If we want the code to be exactly same I can create a lazy version for 
tiny as well. However,A  I don not know where to move kfree_call_rcu() 
from it's current home in rcutiny.h though. Any thoughts ?
>
>> Also moving macros generated following checkpatch noise. I do not know
>> how to silence checkpatch as there is nothing wrong.
>>
>> CHECK: Macro argument reuse 'offset' - possible side-effects?
>> #91: FILE: include/linux/slab.h:348:
>> +#define __kfree_rcu(head, offset) \
>> +	do { \
>> +		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
>> +		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
>> +	} while (0)
> What checkpatch is warning you about here is that somebody might call
>
> __kfree_rcu(p, a++);
>
> and this would expand into
>
> 	do { \
> 		BUILD_BUG_ON(!__is_kfree_rcu_offset(a++)); \
> 		kfree_call_rcu(p, (rcu_callback_t)(unsigned long)(a++)); \
> 	} while (0)
>
> which would increment 'a' twice, and cause pain and suffering.
>
> That's pretty unlikely usage of __kfree_rcu(), but I suppose it's not
> impossible.  We have various hacks to get around this kind of thing;
> for example I might do this as::
>
> #define __kfree_rcu(head, offset) \
> 	do { \
> 		unsigned long __o = offset;
> 		BUILD_BUG_ON(!__is_kfree_rcu_offset(__o)); \
> 		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(__o)); \
> 	} while (0)
>
> Now offset is only evaluated once per invocation of the macro.  The other
> two warnings are the same problem.
>
Thanks. I was not sure if I was required to fix the noise or based on 
inspection the noise could be ignored. I will make the change and resubmit.

Shoaib

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
