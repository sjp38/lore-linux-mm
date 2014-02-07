Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DFC0D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:52:35 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3617343pde.34
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:52:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id i8si6323376pav.190.2014.02.07.12.52.34
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 12:52:34 -0800 (PST)
Date: Fri, 7 Feb 2014 12:52:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-02-05 list_lru_add lockdep splat
Message-Id: <20140207125233.4b84482453da6a656ff427dd@linux-foundation.org>
In-Reply-To: <20140206164136.GC6963@cmpxchg.org>
References: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
	<20140206164136.GC6963@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Feb 2014 11:41:36 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> 
> Make the shadow lru->node[i].lock IRQ-safe to remove the order
> dictated by interruption.  This slightly increases the IRQ-disabled
> section in the shadow shrinker, but it still drops all locks and
> enables IRQ after every reclaimed shadow radix tree node.
> 
> ...
>
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -273,7 +273,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>  	unsigned long max_nodes;
>  	unsigned long pages;
>  
> +	local_irq_disable();
>  	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +	local_irq_enable();

This is a bit ugly-looking.

A reader will look at that and wonder why the heck we're disabling
interrupts here.  Against what?  Is there some way in which we can
clarify this?

Perhaps adding list_lru_count_node_irq[save] and
list_lru_walk_node_irq[save] would be better - is it reasonable to
assume this is the only caller of the list_lru code which will ever
want irq-safe treatment?

This is all somewhat a side-effect of list_lru implementing its own
locking rather than requiring caller-provided locking.  It's always a
mistake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
