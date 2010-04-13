Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9141F6B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 03:36:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D7al0r014692
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Apr 2010 16:36:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A58345DE6F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:36:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4E2A45DE86
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:36:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB9A1DB8037
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:36:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98F511DB8040
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:36:41 +0900 (JST)
Date: Tue, 13 Apr 2010 16:32:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
Message-Id: <20100413163244.c7d974e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	<20100412164335.GQ25756@csn.ul.ie>
	<i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
	<20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
	<v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010 15:09:42 +0800
Bob Liu <lliubbo@gmail.com> wrote:

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
> What I concern is *just* we shouldn't fallback to other nodes if the
> dest node haven't enough free pages during migrate_pages().
> 

Hmm. your patch for mempolicy seems good and it's BUGFIX.
So, this patch should go as it is.

If you want to add comments to alloc_pages_exact_node(), please do.

But I think it's better to divide BUGFIX and CLEANUP patches.

I'll ack your patch for mempolicy.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Naming issue never needs quick fix. How about repositing as it is ?
Minchan, how do you think ?

Thanks,
-Kame

> The detail is below:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
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
> -- 
> Regards,
> --Bob
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
