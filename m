Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 994A86B0010
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 02:10:20 -0400 (EDT)
Subject: Re: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <CAOJsxLFcvWXcXZGWUrwzAE2rA8SmObrWaeg6ZYV8RfDG=nNCiA@mail.gmail.com>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <CAOJsxLFcvWXcXZGWUrwzAE2rA8SmObrWaeg6ZYV8RfDG=nNCiA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 15 Sep 2011 14:16:21 +0800
Message-ID: <1316067381.14905.19.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 2011-09-15 at 13:48 +0800, Pekka Enberg wrote:
> On Wed, Sep 7, 2011 at 4:03 AM, Alex,Shi <alex.shi@intel.com> wrote:
> > Unfreeze_partials may try to discard slab page, the discarding condition
> > should be 'when node partials number > minimum partial number setting',
> > not '<' in current code.
> >
> > This patch base on penberg's tree's 'slub/partial' head.
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git
> >
> > Signed-off-by: Alex Shi <alex.shi@intel.com>
> >
> > ---
> >  mm/slub.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index b351480..66a5b29 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1954,7 +1954,7 @@ static void unfreeze_partials(struct kmem_cache *s)
> >
> >                        new.frozen = 0;
> >
> > -                       if (!new.inuse && (!n || n->nr_partial < s->min_partial))
> > +                       if (!new.inuse && (!n || n->nr_partial > s->min_partial))
> >                                m = M_FREE;
> >                        else {
> >                                struct kmem_cache_node *n2 = get_node(s,
> 
> Can you please resend the patch with Christoph's ACK and a better
> explanation why the condition needs to be flipped. A reference to
> commit 81107188f123e3c2217ac2f2feb2a1147904c62f ("slub: Fix partial
> count comparison confusion") is probably sufficient.
> 
> P.S. Please use the penberg@cs.helsinki.fi email address for now.
> 
>                         Pekka

Is the following OK? Pekka. :) 

==========
From: Alex Shi <alex.shi@intel.com>
Date: Tue, 6 Sep 2011 14:46:01 +0800
Subject: [PATCH ] Discard slab page when node partial > mininum partial number

Unfreeze_partials will try to discard empty slab pages when the slab
node partial number is greater than s->min_partial, not less than
s->min_partial. Otherwise the empty slab page will keep growing and eat
up all system memory.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1348c09..492beab 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1953,7 +1953,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 
 			new.frozen = 0;
 
-			if (!new.inuse && (!n || n->nr_partial < s->min_partial))
+			if (!new.inuse && (!n || n->nr_partial > s->min_partial))
 				m = M_FREE;
 			else {
 				struct kmem_cache_node *n2 = get_node(s,
-- 
1.7.0





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
