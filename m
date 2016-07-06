Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60A0D828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 20:54:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so479745496pfa.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 17:54:12 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y62si1000555pfy.262.2016.07.05.17.54.10
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 17:54:10 -0700 (PDT)
Date: Wed, 6 Jul 2016 09:57:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4] kasan/quarantine: fix bugs on qlist_move_cache()
Message-ID: <20160706005718.GA23627@js1304-P5Q-DELUXE>
References: <1467606714-30231-1-git-send-email-iamjoonsoo.kim@lge.com>
 <577A3114.9080008@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <577A3114.9080008@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Kuthonuzo Luruo <poll.stdin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 04, 2016 at 12:49:08PM +0300, Andrey Ryabinin wrote:
> 
> 
> On 07/04/2016 07:31 AM, js1304@gmail.com wrote:
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
> > v4: fix cache size bug s/cache->size/obj_cache->size/
> > v3: fix build warning
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/kasan/quarantine.c | 21 +++++++--------------
> >  1 file changed, 7 insertions(+), 14 deletions(-)
> > 
> > diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> > index 4973505..b2e1827 100644
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
> >  		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
> >  
> > -		if (obj_cache == cache) {
> > -			if (unlikely(from->head == qlink)) {
> > -				from->head = curr->next;
> > -				prev = curr;
> > -			} else
> > -				prev->next = curr->next;
> > -			if (unlikely(from->tail == qlink))
> > -				from->tail = curr->next;
> > -			from->bytes -= cache->size;
> > -			qlist_put(to, qlink, cache->size);
> > -		} else {
> > -			prev = curr;
> > -		}
> >  		curr = curr->next;
> 
> Nit: Wouldn't be more appropriate to swap 'curr' and 'qlink' variable names?
> Because now qlink is acts as a "current" pointer.

Okay. I sent fixed version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
