Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D76B260023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:45:58 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:45:38 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/11] mm,migration: Take a reference to the anon_vma
	before migrating
Message-ID: <20100317114537.GF12388@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-2-git-send-email-mel@csn.ul.ie> <20100317103434.4C8B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100317103434.4C8B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 10:44:06AM +0900, KOSAKI Motohiro wrote:
> >  rcu_unlock:
> > +
> > +	/* Drop an anon_vma reference if we took one */
> > +	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> > +		int empty = list_empty(&anon_vma->head);
> > +		spin_unlock(&anon_vma->lock);
> > +		if (empty)
> > +			anon_vma_free(anon_vma);
> > +	}
> > +
> 
> Why don't we check ksm_refcount here?

The counts later get merged and the ksm code should be doing its own
checking. Checking both counts here would obscure what is going on and
not help after patch 3 of the series.

> Also, why drop_anon_vma() doesn't need check migrate_refcount?
> 

Same reason. Counts get merged later.


> plus, if we add this logic, we can remove SLAB_DESTROY_BY_RCU from 
> anon_vma_cachep and rcu_read_lock() from unmap_and_move(), I think.
> It is for preventing anon_vma recycle logic. but no free directly mean
> no memory recycle.
> 

This is true, but I don't think such a change belongs in this patch
series. If this series gets merged, then it would be sensible to investigate
if refcounting anon_vma is a good idea or would it be a bouncing write-shared
cacheline mess.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
