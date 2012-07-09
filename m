Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6164B6B0080
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 21:52:18 -0400 (EDT)
Date: Mon, 9 Jul 2012 09:52:09 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: WARNING: __GFP_FS allocations with IRQs disabled
 (kmemcheck_alloc_shadow)
Message-ID: <20120709015209.GB8880@localhost>
References: <20120708040009.GA8363@localhost>
 <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com>
 <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Vegard Nossum <vegard.nossum@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rus <rus@sfinxsoft.com>, Ben Hutchings <ben@decadent.org.uk>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jul 08, 2012 at 04:01:44PM -0700, David Rientjes wrote:
> On Mon, 9 Jul 2012, JoonSoo Kim wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 8c691fa..5d41cad 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1324,8 +1324,14 @@ static struct page *allocate_slab(struct
> > kmem_cache *s, gfp_t flags, int node)
> >                 && !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
> >                 int pages = 1 << oo_order(oo);
> > 
> > +               if (flags & __GFP_WAIT)
> > +                       local_irq_enable();
> > +
> >                 kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
> > 
> > +               if (flags & __GFP_WAIT)
> > +                       local_irq_disable();
> > +
> >                 /*
> >                  * Objects from caches that have a constructor don't get
> >                  * cleared when they're allocated, so we need to do it here.
> 
> This patch is suboptimal when the branch is taken since you just disabled 
> irqs and now are immediately reenabling them and then disabling them 
> again.  (And your patch is also whitespace damaged, has no changelog, and 
> isn't signed off so it can't be applied.)

Agreed.

> The correct fix is what I proposed at 
> http://marc.info/?l=linux-kernel&m=133754837703630 and was awaiting 
> testing.  If Rus, Steven, or Fengguang could test this then we could add 
> it as a stable backport as well.

Acked-by: Fengguang Wu <fengguang.wu@intel.com>
Tested-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
