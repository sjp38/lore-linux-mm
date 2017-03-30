Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4220A6B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 14:27:27 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n77so32097684itn.8
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 11:27:27 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id g124si3603350ite.8.2017.03.30.11.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 11:27:26 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm/vmalloc: remove vfree_atomic()
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170330102719.13119-4-aryabinin@virtuozzo.com>
 <20170330171845.GA19841@bombadil.infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c9a25b31-ff8e-94a5-cd39-fa6dc7b961b3@virtuozzo.com>
Date: Thu, 30 Mar 2017 18:27:28 +0300
MIME-Version: 1.0
In-Reply-To: <20170330171845.GA19841@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, tglx@linutronix.de

On 03/30/2017 08:18 PM, Matthew Wilcox wrote:
> On Thu, Mar 30, 2017 at 01:27:19PM +0300, Andrey Ryabinin wrote:
>> vfree() can be used in any atomic context and there is no
>> vfree_atomic() callers left, so let's remove it.
> 
> We might still get warnings though.
> 
>> @@ -1588,9 +1556,11 @@ void vfree(const void *addr)
>>  
>>  	if (!addr)
>>  		return;
>> -	if (unlikely(in_interrupt()))
>> -		__vfree_deferred(addr);
>> -	else
>> +	if (unlikely(in_interrupt())) {
>> +		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
>> +		if (llist_add((struct llist_node *)addr, &p->list))
>> +			schedule_work(&p->wq);
>> +	} else
>>  		__vunmap(addr, 1);
>>  }
>>  EXPORT_SYMBOL(vfree);
> 
> If I disable preemption, then call vfree(), in_interrupt() will not be
> true (I've only incremented preempt_count()), then __vunmap() calls
> remove_vm_area() which calls might_sleep(), which will warn.

The first patch removed this might_sleep() .

> So I think this check needs to change from in_interrupt() to in_atomic().
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
