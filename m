Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 885016B021D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 03:09:47 -0400 (EDT)
Received: by pzk30 with SMTP id 30so116516pzk.12
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 00:09:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <20100412164335.GQ25756@csn.ul.ie>
	 <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
	 <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Apr 2010 15:09:42 +0800
Message-ID: <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On 4/13/10, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Apr 2010 13:34:52 +0900
>
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>
> > On Tue, Apr 13, 2010 at 1:43 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>  > > On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
>  > >> Since alloc_pages_exact_node() is not for allocate page from
>  > >> exact node but just for removing check of node's valid,
>  > >> rename it to alloc_pages_from_valid_node(). Else will make
>  > >> people misunderstanding.
>  > >>
>  > >
>  > > I don't know about this change either but as I introduced the original
>  > > function name, I am biased. My reading of it is - allocate me pages and
>  > > I know exactly which node I need. I see how it it could be read as
>  > > "allocate me pages from exactly this node" but I don't feel the new
>  > > naming is that much clearer either.
>  >
>  > Tend to agree.
>  > Then, don't change function name but add some comment?
>  >
>  > /*
>  >  * allow pages from fallback if page allocator can't find free page in your nid.
>  >  * If you want to allocate page from exact node, please use
>  > __GFP_THISNODE flags with
>  >  * gfp_mask.
>  >  */
>  > static inline struct page *alloc_pages_exact_node(....
>  >
>
> I vote for this rather than renaming.
>
>  There are two functions
>         allo_pages_node()
>         alloc_pages_exact_node().
>
>  Sane progmrammers tend to see implementation details if there are 2
>  similar functions.
>
>  If I name the function,
>         alloc_pages_node_verify_nid() ?
>
>  I think /* This doesn't support nid=-1, automatic behavior. */ is necessary
>  as comment.
>
>  OFF_TOPIC
>
>  If you want renaming,  I think we should define NID=-1 as
>
>  #define ARBITRARY_NID           (-1) or
>  #define CURRENT_NID             (-1) or
>  #define AUTO_NID                (-1)
>
>  or some. Then, we'll have concensus of NID=-1 support.
>  (Maybe some amount of programmers don't know what NID=-1 means.)
>
>  The function will be
>         alloc_pages_node_no_auto_nid() /* AUTO_NID is not supported by this */
>  or
>         alloc_pages_node_veryfy_nid()
>
>  Maybe patch will be bigger and may fail after discussion. But it seems
>  worth to try.
>

Hm..It's a bit bigger.
Actually, what I want to do was in my original mail several days ago,
the title is "mempolicy:add GFP_THISNODE when allocing new page"

What I concern is *just* we shouldn't fallback to other nodes if the
dest node haven't enough free pages during migrate_pages().

The detail is below:
In funtion migrate_pages(), if the dest node have no
enough free pages,it will fallback to other nodes.
Add GFP_THISNODE to avoid this, the same as what
funtion new_page_node() do in migrate.c.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..fc5ddf5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,
struct list_head *pagelist,

 static struct page *new_node_page(struct page *page, unsigned long
node, int **x)
 {
-       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
+       return alloc_pages_exact_node(node,
+                               GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }

Thanks.
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
