Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 777736B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:27:35 -0400 (EDT)
Date: Tue, 13 Apr 2010 09:27:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
Message-ID: <20100413082712.GR25756@csn.ul.ie>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com> <20100412164335.GQ25756@csn.ul.ie> <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com> <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com> <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 03:09:42PM +0800, Bob Liu wrote:
> On 4/13/10, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 13 Apr 2010 13:34:52 +0900
> >
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >
> > > On Tue, Apr 13, 2010 at 1:43 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >  > > On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
> >  > >> Since alloc_pages_exact_node() is not for allocate page from
> >  > >> exact node but just for removing check of node's valid,
> >  > >> rename it to alloc_pages_from_valid_node(). Else will make
> >  > >> people misunderstanding.
> >  > >>
> >  > >
> >  > > I don't know about this change either but as I introduced the original
> >  > > function name, I am biased. My reading of it is - allocate me pages and
> >  > > I know exactly which node I need. I see how it it could be read as
> >  > > "allocate me pages from exactly this node" but I don't feel the new
> >  > > naming is that much clearer either.
> >  >
> >  > Tend to agree.
> >  > Then, don't change function name but add some comment?
> >  >
> >  > /*
> >  >  * allow pages from fallback if page allocator can't find free page in your nid.
> >  >  * If you want to allocate page from exact node, please use
> >  > __GFP_THISNODE flags with
> >  >  * gfp_mask.
> >  >  */
> >  > static inline struct page *alloc_pages_exact_node(....
> >  >
> >
> > I vote for this rather than renaming.
> >
> >  There are two functions
> >         allo_pages_node()
> >         alloc_pages_exact_node().
> >
> >  Sane progmrammers tend to see implementation details if there are 2
> >  similar functions.
> >
> >  If I name the function,
> >         alloc_pages_node_verify_nid() ?
> >
> >  I think /* This doesn't support nid=-1, automatic behavior. */ is necessary
> >  as comment.
> >
> >  OFF_TOPIC
> >
> >  If you want renaming,  I think we should define NID=-1 as
> >
> >  #define ARBITRARY_NID           (-1) or
> >  #define CURRENT_NID             (-1) or
> >  #define AUTO_NID                (-1)
> >
> >  or some. Then, we'll have concensus of NID=-1 support.
> >  (Maybe some amount of programmers don't know what NID=-1 means.)
> >
> >  The function will be
> >         alloc_pages_node_no_auto_nid() /* AUTO_NID is not supported by this */
> >  or
> >         alloc_pages_node_veryfy_nid()
> >
> >  Maybe patch will be bigger and may fail after discussion. But it seems
> >  worth to try.
> >
> 
> Hm..It's a bit bigger.
> Actually, what I want to do was in my original mail several days ago,
> the title is "mempolicy:add GFP_THISNODE when allocing new page"
> 

Sorry Bob, I still haven't actually read that thread. There has been a lot
going on :(

> What I concern is *just* we shouldn't fallback to other nodes if the
> dest node haven't enough free pages during migrate_pages().
> 
> The detail is below:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

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

If -ENOMEM is returned from migrate_pages, should it not move to the next node?

> ---
>  mm/mempolicy.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..fc5ddf5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,
> struct list_head *pagelist,
> 
>  static struct page *new_node_page(struct page *page, unsigned long
> node, int **x)
>  {
> -       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +       return alloc_pages_exact_node(node,
> +                               GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
> 
> Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
