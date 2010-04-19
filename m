Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A642A6B01F2
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 13:48:14 -0400 (EDT)
Date: Mon, 19 Apr 2010 12:47:55 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004191245250.9855@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>  <20100413083855.GS25756@csn.ul.ie>  <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>  <20100416111539.GC19264@csn.ul.ie>
  <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>  <alpine.DEB.2.00.1004161049130.7710@router.home> <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Sat, 17 Apr 2010, Bob Liu wrote:

> > GFP_THISNODE forces allocation from the node. Without it we will fallback.
> >
>
> Yeah, but I think we shouldn't fallback at this case, what we want is
> alloc a page
> from exactly the dest node during migrate_to_node(dest).So I added
> GFP_THISNODE.

Why would we want that?

>
> And mel concerned that
> ====
> This appears to be a valid bug fix.  I agree that the way things are structured
> that __GFP_THISNODE should be used in new_node_page(). But maybe a follow-on
> patch is also required. The behaviour is now;
>
> o new_node_page will not return NULL if the target node is empty (fine).
> o migrate_pages will translate this into -ENOMEM (fine)
> o do_migrate_pages breaks early if it gets -ENOMEM ?
>
> It's the last part I'd like you to double check. migrate_pages() takes a
> nodemask of allowed nodes to migrate to. Rather than sending this down
> to the allocator, it iterates over the nodes allowed in the mask. If one
> of those nodes is full, it returns -ENOMEM.
>
> If -ENOMEM is returned from migrate_pages, should it not move to the
> next node?
> ====

?? It will move onto the next node if you leave things as is. If you add
GFP_THISNODE then you can get NULL back from the page allocator because
there is no memory on the local node. Without GFP_THISNODe the allocation
will fallback.

> In my opinion, when we want to preserve the relative position of the page to
> the beginning of the node set, early return is ok. Else should try to alloc the
> new page from the next node(to_nodes).

???

> So I added retry path to allocate new page from next node only when
> from_nodes' weight is different from to_nodes', this case the user should
> konw the relative position of the page to the beginning of the node set
> can be changed.

There is no point in your patch since the functionality is already there
without it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
