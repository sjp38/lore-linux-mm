Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 52FA56B01F0
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:39:17 -0400 (EDT)
Date: Tue, 13 Apr 2010 09:38:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
Message-ID: <20100413083855.GS25756@csn.ul.ie>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com> <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 04:20:53PM +0800, Bob Liu wrote:
> On 4/6/10, Bob Liu <lliubbo@gmail.com> wrote:
> > In funtion migrate_pages(), if the dest node have no
> > enough free pages,it will fallback to other nodes.
> > Add GFP_THISNODE to avoid this, the same as what
> > funtion new_page_node() do in migrate.c.
> >
> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > ---
> >  mm/mempolicy.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 08f40a2..fc5ddf5 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
> >
> >  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
> >  {
> > -       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> > +       return alloc_pages_exact_node(node,
> > +                               GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
> >  }
> >
> 
> Hi, Minchan and Kame
>      Would you please add ack or review to this thread. It's BUGFIX
> and not change, so i don't resend one.
> 

Sorry for taking so long to get around to this thread. I talked on this
patch already but it's in another thread. Here is what I said there

====
This appears to be a valid bug fix.  I agree that the way things are structured
that __GFP_THISNODE should be used in new_node_page(). But maybe a follow-on
patch is also required. The behaviour is now;

o new_node_page will not return NULL if the target node is empty (fine).
o migrate_pages will translate this into -ENOMEM (fine)
o do_migrate_pages breaks early if it gets -ENOMEM ?

It's the last part I'd like you to double check. migrate_pages() takes a
nodemask of allowed nodes to migrate to. Rather than sending this down
to the allocator, it iterates over the nodes allowed in the mask. If one
of those nodes is full, it returns -ENOMEM.

If -ENOMEM is returned from migrate_pages, should it not move to the
next node?
====

My concern before acking this patch is that the function might be exiting
too early when given a set of nodes. Granted, because __GFP_THISNODE is not
specified, it's perfectly possible that migration is currently moving pages
to the wrong node which is also very bad.

>      About code clean, there should be some new CLEANUP patches or
> just don't make any changes decided after we finish before
> discussions.
> 

Cleanup patches can be sent separately. I might be biased against a function
rename but the bugfix is more important.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
