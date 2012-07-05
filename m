Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 17E186B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:20:07 -0400 (EDT)
Date: Thu, 5 Jul 2012 09:20:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: reduce failure of this_cpu_cmpxchg in
 put_cpu_partial() after unfreezing
In-Reply-To: <CAOJsxLEy++a5R6-7bFaHNG4XqmvJoUTEMMJhpVD5nnxLkAafsw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207050918290.4138@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com> <1340389359-2407-2-git-send-email-js1304@gmail.com> <CAOJsxLEy++a5R6-7bFaHNG4XqmvJoUTEMMJhpVD5nnxLkAafsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 4 Jul 2012, Pekka Enberg wrote:

> On Fri, Jun 22, 2012 at 9:22 PM, Joonsoo Kim <js1304@gmail.com> wrote:
> > In current implementation, after unfreezing, we doesn't touch oldpage,
> > so it remain 'NOT NULL'. When we call this_cpu_cmpxchg()
> > with this old oldpage, this_cpu_cmpxchg() is mostly be failed.
> >
> > We can change value of oldpage to NULL after unfreezing,
> > because unfreeze_partial() ensure that all the cpu partial slabs is removed
> > from cpu partial list. In this time, we could expect that
> > this_cpu_cmpxchg is mostly succeed.
> >
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 92f1c0e..531d8ed 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1968,6 +1968,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >                                 local_irq_save(flags);
> >                                 unfreeze_partials(s);
> >                                 local_irq_restore(flags);
> > +                               oldpage = NULL;
> >                                 pobjects = 0;
> >                                 pages = 0;
> >                                 stat(s, CPU_PARTIAL_DRAIN);
>
> Makes sense. Christoph, David?

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
