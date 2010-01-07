Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 795CA600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 13:10:16 -0500 (EST)
Subject: Re: [PATCH v3] slab: initialize unused alien cache entry as NULL
 at alloc_alien_cache().
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <4B45CF8E.7000707@cs.helsinki.fi>
References: <4B443AE3.2080800@linux.intel.com>
	 <4B45CF8E.7000707@cs.helsinki.fi>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jan 2010 12:10:11 -0600
Message-ID: <1262887811.29868.241.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-07 at 14:11 +0200, Pekka Enberg wrote:
> Haicheng Li kirjoitti:
> > Comparing with existing code, it's a simpler way to use kzalloc_node()
> > to ensure that each unused alien cache entry is NULL.
> > 
> > CC: Pekka Enberg <penberg@cs.helsinki.fi>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  mm/slab.c |    6 ++----
> >  1 files changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 7dfa481..5d1a782 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -971,13 +971,11 @@ static struct array_cache **alloc_alien_cache(int 
> > node, int limit, gfp_t gfp)
> > 
> >      if (limit > 1)
> >          limit = 12;
> > -    ac_ptr = kmalloc_node(memsize, gfp, node);
> > +    ac_ptr = kzalloc_node(memsize, gfp, node);
> >      if (ac_ptr) {
> >          for_each_node(i) {
> > -            if (i == node || !node_online(i)) {
> > -                ac_ptr[i] = NULL;
> > +            if (i == node || !node_online(i))
> >                  continue;
> > -            }
> >              ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d, gfp);
> >              if (!ac_ptr[i]) {
> >                  for (i--; i >= 0; i--)
> 
> Christoph? Matt?

Looks like a fine cleanup.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
