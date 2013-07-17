Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D2E446B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 16:14:56 -0400 (EDT)
Date: Wed, 17 Jul 2013 14:14:53 -0600
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH RFC] lib: Make radix_tree_node_alloc() irq safe
Message-ID: <20130717201453.GH22392@kernel.dk>
References: <1373994390-5479-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373994390-5479-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 16 2013, Jan Kara wrote:
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

Looks good to me, great catch Jan.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
