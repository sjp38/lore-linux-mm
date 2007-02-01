Date: Wed, 31 Jan 2007 16:33:33 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] not to disturb page LRU state when unmapping memory
 range
Message-Id: <20070131163333.4a803e5b.akpm@osdl.org>
In-Reply-To: <1170287534.10924.103.camel@lappy>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	<Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
	<1170279811.10924.32.camel@lappy>
	<20070131140450.09f174e9.akpm@osdl.org>
	<1170282300.10924.50.camel@lappy>
	<20070131144855.8fe255ff.akpm@osdl.org>
	<1170287534.10924.103.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 01 Feb 2007 00:52:14 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > In the above (simple, common) scenario the proposed
> > s/mark_page_accessed/SetPageReferenced/ change will cause the page to end
> > up PageReferenced+!PageActive. 
> 
> How so, it will not demote the page to inactive. 
> 
> Now unmap could promote to active, with the change not so. Neither will
> ever demote, only page reclaim will do that.
> 
> currently with mark_page_accessed:
> 
>  referenced := (pte young || PageReferenced) 
> 
> 1 active pte
> 
>   referenced (pte, !PG_referenced), inactive -> referenced,   inactive
>   referenced (pte ,PG_referenced),  inactive -> unreferenced, active
>   *,                                active   -> referenced,   active
> 
> 2 active ptes
> 
>   referenced (pte, !PG_referenced), inactive -> unreferenced, active
>   referenced (pte, PG_referenced),  inactive -> referenced, active
>   *,                                active   -> referenced, active
> 
> 3+ active ptes
> 
>   *, * -> referenced, active
> 
> which I find quite horrid for unmap...
> 
> Or, with the proposed SetPageReferenced:
> 
> 1+ active pte(s)
>   referenced (pte,!PG_referenced), * -> referenced (PG_referenced), *
>   referenced (pte, PG_referenced), * -> referenced (PG_referenced), *
> 
> Its actually an identity map, it just moves pte young bits into the
> referenced bit, which is all the same to page_referenced().

<head spins>


Test it.  On the major fault the pages start out on the inactive list.  On
the munmap they goe onto the active list.  Taking the mark_page_accessed()
out of munmap() causes them to remain on the inactive list.

> >  ie: it ends up on the inactive list and not
> > the active list.  <tests it, confirms>. 
> 
> it will stay on whatever list it was.

Namely the inactive list.  Unlike 2.6.20-rc7.  That's a big change.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
