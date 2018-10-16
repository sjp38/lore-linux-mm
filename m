Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5576B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 18:27:51 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t3-v6so18539235pgp.0
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 15:27:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b89-v6si16152917plb.143.2018.10.16.15.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 15:27:50 -0700 (PDT)
Date: Tue, 16 Oct 2018 15:27:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: workingset: add vmstat counter for shadow nodes
Message-Id: <20181016152748.28b6df15a0410447c3abdc2a@linux-foundation.org>
In-Reply-To: <20181016084923.GH5819@techsingularity.net>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	<20181009184732.762-4-hannes@cmpxchg.org>
	<20181009150845.8656eb8ede045ca5f4cc4b21@linux-foundation.org>
	<20181016084923.GH5819@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 16 Oct 2018 09:49:23 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> > Can we do this?
> > 
> > --- a/mm/workingset.c~mm-workingset-add-vmstat-counter-for-shadow-nodes-fix
> > +++ a/mm/workingset.c
> > @@ -377,6 +377,8 @@ void workingset_update_node(struct radix
> >  	 * already where they should be. The list_empty() test is safe
> >  	 * as node->private_list is protected by the i_pages lock.
> >  	 */
> > +	WARN_ON_ONCE(!irqs_disabled());	/* For __inc_lruvec_page_state */
> > +
> >  	if (node->count && node->count == node->exceptional) {
> >  		if (list_empty(&node->private_list)) {
> >  			list_lru_add(&shadow_nodes, &node->private_list);
> 
> Note that for whatever reason, I've observed that irqs_disabled() is
> actually quite an expensive call. I'm not saying the warning is a bad
> idea but it should not be sprinkled around unnecessary and may be more
> suitable as a debug option.

Yup, it is now VM_WARN_ON_ONCE().
