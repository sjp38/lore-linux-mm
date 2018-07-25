Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 357446B0008
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 17:16:46 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g15-v6so6216754plo.11
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 14:16:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y62-v6si15516313pfd.254.2018.07.25.14.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 14:16:45 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:16:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-Id: <20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>
In-Reply-To: <2018072514375722198958@wingtech.com>
References: <2018072514375722198958@wingtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, mhocko <mhocko@suse.com>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed, 25 Jul 2018 14:37:58 +0800 "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com> wrote:

> From: zhaowuyun <zhaowuyun@wingtech.com>
>  
> issue is that there are two processes A and B, A is kworker/u16:8
> normal priority, B is AudioTrack, RT priority, they are on the
> same CPU 3.
>  
> The task A preempted by task B in the moment
> after __delete_from_swap_cache(page) and before swapcache_free(swap).
>  
> The task B does __read_swap_cache_async in the do {} while loop, it
> will never find the page from swapper_space because the page is removed
> by the task A, and it will never sucessfully in swapcache_prepare because
> the entry is EEXIST.
>  
> The task B then stuck in the loop infinitely because it is a RT task,
> no one can preempt it.
>  
> so need to disable preemption until the swapcache_free executed.

Yes, right, sorry, I must have merged cbab0e4eec299 in my sleep. 
cond_resched() is a no-op in the presence of realtime policy threads
and using to attempt to yield to a different thread it in this fashion
is broken.

Disabling preemption on the other side of the race should fix things,
but it's using a bandaid to plug the leakage from the earlier bandaid. 
The proper way to coordinate threads is to use a sleeping lock, such
as a mutex, or some other wait/wakeup mechanism.

And once that's done, we can hopefully eliminate the do loop from
__read_swap_cache_async().  That also services ENOMEM from
radix_tree_insert(), but __add_to_swap_cache() appears to handle that
OK and we shouldn't just loop around retrying the insert and the
radix_tree_preload() should ensure that radix_tree_insert() never fails
anyway.  Unless we're calling __read_swap_cache_async() with screwy
gfp_flags from somewhere.
