Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 349F26B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:05:32 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id u42-v6so2638816ybi.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:05:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9-v6sor10447760ybp.73.2018.10.10.08.05.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:05:26 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:05:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-ID: <20181010150524.GB2527@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
 <20181009184732.762-4-hannes@cmpxchg.org>
 <20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 09, 2018 at 03:08:45PM -0700, Andrew Morton wrote:
> On Tue,  9 Oct 2018 14:47:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -378,11 +378,17 @@ void workingset_update_node(struct xa_node *node)
> >  	 * as node->private_list is protected by the i_pages lock.
> >  	 */
> >  	if (node->count && node->count == node->nr_values) {
> > -		if (list_empty(&node->private_list))
> > +		if (list_empty(&node->private_list)) {
> >  			list_lru_add(&shadow_nodes, &node->private_list);
> > +			__inc_lruvec_page_state(virt_to_page(node),
> > +						WORKINGSET_NODES);
> > +		}
> >  	} else {
> > -		if (!list_empty(&node->private_list))
> > +		if (!list_empty(&node->private_list)) {
> >  			list_lru_del(&shadow_nodes, &node->private_list);
> > +			__dec_lruvec_page_state(virt_to_page(node),
> > +						WORKINGSET_NODES);
> > +		}
> >  	}
> >  }
> 
> A bit worried that we're depending on the caller's caller to have
> disabled interrupts to avoid subtle and rare errors.
> 
> Can we do this?

I'm not opposed to it, but the i_pages lock is guaranteed to be held
during the tree update, and that lock is also taken from the io
completion irq to maintain the tree's dirty/writeback state. It seems
like a robust assumption that interrupts will be disabled here.

But all that isn't very obvious from the code at hand, so I wouldn't
mind adding the check for documentation purposes.

It's not a super hot path, but maybe VM_WARN_ON_ONCE()?

> --- a/mm/workingset.c~mm-workingset-add-vmstat-counter-for-shadow-nodes-fix
> +++ a/mm/workingset.c
> @@ -377,6 +377,8 @@ void workingset_update_node(struct radix
>  	 * already where they should be. The list_empty() test is safe
>  	 * as node->private_list is protected by the i_pages lock.
>  	 */
> +	WARN_ON_ONCE(!irqs_disabled());	/* For __inc_lruvec_page_state */
> +
>  	if (node->count && node->count == node->exceptional) {
>  		if (list_empty(&node->private_list)) {
>  			list_lru_add(&shadow_nodes, &node->private_list);
> _
