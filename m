Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 242486B00D3
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:33:30 -0500 (EST)
Date: Tue, 9 Mar 2010 14:33:19 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
In-Reply-To: <20100309122253.3f3d4a53.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1003091431330.28897@router.home>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain> <20100309122253.3f3d4a53.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010, Andrew Morton wrote:

> > __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> > access to the possible cpus. This might result in access to
> > uninitialized areas as the per cpu allocator only populates the per
> > cpu memory for possible cpus.
> >
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > Index: linux-2.6/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6.orig/mm/page_alloc.c
> > +++ linux-2.6/mm/page_alloc.c
> > @@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
> >  	int cpu;
> >  	unsigned long batch = zone_batchsize(zone), flags;
> >
> > -	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> > +	for_each_possible_cpu(cpu) {
> >  		struct per_cpu_pageset *pset;
> >  		struct per_cpu_pages *pcp;
> >
>
> I'm having trouble working out whether we want to backport this into
> 2.6.33.x or earlier.  Help?

Nope. This problem was created as a result of the dynamic allocation of
pagesets from percpu memory that went in during the merge window.
(99dcc3e5a94ed491fbef402831d8c0bbb267f995)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
