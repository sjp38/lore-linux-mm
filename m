Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id F00D26B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 02:47:25 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so5900143pdb.5
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 23:47:25 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id sd1si3142650pbb.4.2015.02.19.23.47.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Feb 2015 23:47:25 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NK2006HV8HO8770@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Feb 2015 07:51:24 +0000 (GMT)
Message-id: <54E6E684.4070806@samsung.com>
Date: Fri, 20 Feb 2015 10:47:16 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] kasan, module,
 vmalloc: rework shadow allocation for modules
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com>
 <87pp96stmz.fsf@rustcorp.com.au> <54E5E355.9020404@samsung.com>
 <87fva1sajo.fsf@rustcorp.com.au>
In-reply-to: <87fva1sajo.fsf@rustcorp.com.au>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

On 02/20/2015 03:15 AM, Rusty Russell wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> On 02/19/2015 02:10 AM, Rusty Russell wrote:
>>> This is not portable.  Other archs don't use vmalloc, or don't use
>>> (or define) MODULES_VADDR.  If you really want to hook here, you'd
>>> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
>>>
>>
>> Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
>> I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
>> or make make all those functions weak and allow arch code to redefine them.
> 
> That adds another layer of indirection.  And how would the caller of
> plain vmalloc() even know what to return?
> 

I think I don't understand what do you mean here. vmalloc() callers shouldn't know
anything about kasan/shadow.

You were concerned that this patch is not portable, so I suggested to hide arch specific
part in arch code. That's it.

>>> Thus I think modifying the callers is the better choice.
>>>
>>
>> I could suggest following (though, I still prefer 'modifying vmalloc' approach):
>>   * In do_init_module(), instead of call_rcu(&freeinit->rcu, do_free_init);
>>     use synchronyze_rcu() + module_memfree(). Of course this will be
>>   under CONFIG_KASAN.
> 
> But it would be slow, and a disparate code path, which is usually a bad
> idea.
> 
>>     As you said there other module_memfree() users, so what if they will decide
>>     to free memory in atomic context?
> 
> Hmm, how about a hybrid:
> 
> 1) Add kasan_module_alloc(p, size) after module alloc as your original.
> 2) Hook into vfree(), and ignore it if you can't find the map.
> 

That should work, but it looks messy IMO.

> Or is the latter too expensive?
> 

Not sure whether this will be too expensive or not,
but definitely more expensive than simple (addr >= MODULES_VADDR && addr < MODULES_END) check.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
