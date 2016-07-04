Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3177F828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 00:33:33 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fu3so27036298obb.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 21:33:33 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f189si490410ith.102.2016.07.03.21.33.31
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 21:33:32 -0700 (PDT)
Date: Mon, 4 Jul 2016 13:36:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
Message-ID: <20160704043647.GA14840@js1304-P5Q-DELUXE>
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
 <57767B66.7070904@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57767B66.7070904@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 01, 2016 at 05:17:10PM +0300, Andrey Ryabinin wrote:
> 
> 
> On 07/01/2016 05:02 PM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > There are two bugs on qlist_move_cache(). One is that qlist's tail
> > isn't set properly. curr->next can be NULL since it is singly linked
> > list and NULL value on tail is invalid if there is one item on qlist.
> > Another one is that if cache is matched, qlist_put() is called and
> > it will set curr->next to NULL. It would cause to stop the loop
> > prematurely.
> > 
> > These problems come from complicated implementation so I'd like to
> > re-implement it completely. Implementation in this patch is really
> > simple. Iterate all qlist_nodes and put them to appropriate list.
> > 
> > Unfortunately, I got this bug sometime ago and lose oops message.
> > But, the bug looks trivial and no need to attach oops.
> > 
> > v3: fix build warning
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/kasan/quarantine.c | 21 +++++++--------------
> >  1 file changed, 7 insertions(+), 14 deletions(-)
> > 
> > diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> > index 4973505..cf92494 100644
> > --- a/mm/kasan/quarantine.c
> > +++ b/mm/kasan/quarantine.c
> > @@ -238,30 +238,23 @@ static void qlist_move_cache(struct qlist_head *from,
> >  				   struct qlist_head *to,
> >  				   struct kmem_cache *cache)
> >  {
> > -	struct qlist_node *prev = NULL, *curr;
> > +	struct qlist_node *curr;
> >  
> >  	if (unlikely(qlist_empty(from)))
> >  		return;
> >  
> >  	curr = from->head;
> > +	qlist_init(from);
> >  	while (curr) {
> >  		struct qlist_node *qlink = curr;
> 
> Can you please also get rid of either qlink or curr.
> Those are essentially the same pointers.

Hello,

Before putting the qlist_node to the list, we need to calculate
curr->next and remember it to iterate the list. I use curr
for this purpose so qlink and curr are not the same pointer.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
