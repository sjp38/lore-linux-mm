Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0C76B0003
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 23:26:24 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id u4so4851949iti.2
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 20:26:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e5si4874065itf.84.2018.01.27.20.26.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 20:26:23 -0800 (PST)
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180124013651.GA1718@codemonkey.org.uk>
 <20180127222433.GA24097@codemonkey.org.uk>
 <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
 <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
Message-ID: <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
Date: Sun, 28 Jan 2018 13:25:29 +0900
MIME-Version: 1.0
In-Reply-To: <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>

On 2018/01/28 10:16, Tetsuo Handa wrote:
> Linus Torvalds wrote:
>> On Sat, Jan 27, 2018 at 2:24 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
>>> On Tue, Jan 23, 2018 at 08:36:51PM -0500, Dave Jones wrote:
>>>  > Just triggered this on a server I was rsync'ing to.
>>>
>>> Actually, I can trigger this really easily, even with an rsync from one
>>> disk to another.  Though that also smells a little like networking in
>>> the traces. Maybe netdev has ideas.
>>
>> Is this new to 4.15? Or is it just that you're testing something new?
>>
>> If it's new and easy to repro, can you just bisect it? And if it isn't
>> new, can you perhaps check whether it's new to 4.14 (ie 4.13 being
>> ok)?
>>
>> Because that fs_reclaim_acquire/release() debugging isn't new to 4.15,
>> but it was rewritten for 4.14.. I'm wondering if that remodeling ended
>> up triggering something.
> 
> --- linux-4.13.16/mm/page_alloc.c
> +++ linux-4.14.15/mm/page_alloc.c

Oops. This output was inverted.

> @@ -3527,53 +3519,12 @@
>  			return true;
>  	}
>  	return false;
>  }
>  #endif /* CONFIG_COMPACTION */
>  
> -#ifdef CONFIG_LOCKDEP
> -struct lockdep_map __fs_reclaim_map =
> -	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
> -
> -static bool __need_fs_reclaim(gfp_t gfp_mask)
> -{
> -	gfp_mask = current_gfp_context(gfp_mask);
> -
> -	/* no reclaim without waiting on it */
> -	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
> -		return false;
> -
> -	/* this guy won't enter reclaim */
> -	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> -		return false;

Since __kmalloc_reserve() from __alloc_skb() adds __GFP_NOMEMALLOC | __GFP_NOWARN
to gfp_mask, __need_fs_reclaim() is failing to return false here.

But why checking __GFP_NOMEMALLOC here? __alloc_pages_slowpath() skips direct
reclaim if !(gfp_mask & __GFP_DIRECT_RECLAIM) or (current->flags & PF_MEMALLOC),
doesn't it?

----------
static inline struct page *
__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
                                                struct alloc_context *ac)
{
(...snipped...)
        /* Caller is not willing to reclaim, we can't balance anything */
        if (!can_direct_reclaim)
                goto nopage;

        /* Avoid recursion of direct reclaim */
        if (current->flags & PF_MEMALLOC)
                goto nopage;

        /* Try direct reclaim and then allocating */
        page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
                                                        &did_some_progress);
        if (page)
                goto got_pg;
(...snipped...)
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
