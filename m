Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 425286B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 22:47:49 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so4691925pdb.2
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 19:47:48 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id sm2si27709705pac.214.2015.02.19.19.47.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 19:47:48 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] kasan, module, vmalloc: rework shadow allocation for modules
In-Reply-To: <54E5E355.9020404@samsung.com>
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com> <87pp96stmz.fsf@rustcorp.com.au> <54E5E355.9020404@samsung.com>
Date: Fri, 20 Feb 2015 10:45:23 +1030
Message-ID: <87fva1sajo.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> On 02/19/2015 02:10 AM, Rusty Russell wrote:
>> This is not portable.  Other archs don't use vmalloc, or don't use
>> (or define) MODULES_VADDR.  If you really want to hook here, you'd
>> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
>> 
>
> Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
> I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
> or make make all those functions weak and allow arch code to redefine them.

That adds another layer of indirection.  And how would the caller of
plain vmalloc() even know what to return?

>> Thus I think modifying the callers is the better choice.
>> 
>
> I could suggest following (though, I still prefer 'modifying vmalloc' approach):
>   * In do_init_module(), instead of call_rcu(&freeinit->rcu, do_free_init);
>     use synchronyze_rcu() + module_memfree(). Of course this will be
>   under CONFIG_KASAN.

But it would be slow, and a disparate code path, which is usually a bad
idea.

>     As you said there other module_memfree() users, so what if they will decide
>     to free memory in atomic context?

Hmm, how about a hybrid:

1) Add kasan_module_alloc(p, size) after module alloc as your original.
2) Hook into vfree(), and ignore it if you can't find the map.

Or is the latter too expensive?

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
