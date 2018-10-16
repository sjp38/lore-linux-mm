Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD6066B000C
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:49:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26-v6so13538280eda.7
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 01:49:27 -0700 (PDT)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id u21si6565098edy.88.2018.10.16.01.49.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Oct 2018 01:49:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id A0B80B87C7
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:49:23 +0100 (IST)
Date: Tue, 16 Oct 2018 09:49:23 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-ID: <20181016084923.GH5819@techsingularity.net>
References: <20181009184732.762-1-hannes@cmpxchg.org>
 <20181009184732.762-4-hannes@cmpxchg.org>
 <20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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
> 
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

Note that for whatever reason, I've observed that irqs_disabled() is
actually quite an expensive call. I'm not saying the warning is a bad
idea but it should not be sprinkled around unnecessary and may be more
suitable as a debug option.

-- 
Mel Gorman
SUSE Labs
