Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id DCD876B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 19:12:01 -0400 (EDT)
Date: Wed, 17 Jul 2013 16:12:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] lib: Make radix_tree_node_alloc() irq safe
Message-Id: <20130717161200.40a97074623be2685beb8156@linux-foundation.org>
In-Reply-To: <1373994390-5479-1-git-send-email-jack@suse.cz>
References: <1373994390-5479-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>

On Tue, 16 Jul 2013 19:06:30 +0200 Jan Kara <jack@suse.cz> wrote:

> With users of radix_tree_preload() run from interrupt (CFQ is one such
> possible user), the following race can happen:
> 
> radix_tree_preload()
> ...
> radix_tree_insert()
>   radix_tree_node_alloc()
>     if (rtp->nr) {
>       ret = rtp->nodes[rtp->nr - 1];
> <interrupt>
> ...
> radix_tree_preload()
> ...
> radix_tree_insert()
>   radix_tree_node_alloc()
>     if (rtp->nr) {
>       ret = rtp->nodes[rtp->nr - 1];
> 
> And we give out one radix tree node twice. That clearly results in radix
> tree corruption with different results (usually OOPS) depending on which
> two users of radix tree race.
> 
> Fix the problem by disabling interrupts when working with rtp variable.
> In-interrupt user can still deplete our preloaded nodes but at least we
> won't corrupt radix trees.
> 
> ...
>
>   There are some questions regarding this patch:
> Do we really want to allow in-interrupt users of radix_tree_preload()?  CFQ
> could certainly do this in older kernels but that particular call site where I
> saw the bug hit isn't there anymore so I'm not sure this can really happen with
> recent kernels.

Well, it was never anticipated that interrupt-time code would run
radix_tree_preload().  The whole point in the preloading was to be able
to perform GFP_KERNEL allocations before entering the spinlocked region
which needs to allocate memory.

Doing all that from within an interrupt is daft, because the interrupt code
can't use GFP_KERNEL anyway.

> Also it is actually harmful to do preloading if you are in interrupt context
> anyway. The disadvantage of disallowing radix_tree_preload() in interrupt is
> that we would need to tweak radix_tree_node_alloc() to somehow recognize
> whether the caller wants it to use preloaded nodes or not and that callers
> would have to get it right (although maybe some magic in radix_tree_preload()
> could handle that).
> 
> Opinions?

BUG_ON(in_interrupt()) :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
