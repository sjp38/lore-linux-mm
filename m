Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B49286B0005
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 06:51:30 -0500 (EST)
Message-ID: <1359719487.5642.18.camel@gandalf.local.home>
Subject: Re: FIX [1/2] slub: Do not dereference NULL pointer in node_match
From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 01 Feb 2013 06:51:27 -0500
In-Reply-To: <CAOJsxLH6BO_m+6Ys0AG8gHQzmoDovdA8kaAecUhcP5foXoEXUA@mail.gmail.com>
References: <20130123214514.370647954@linux.com>
	 <0000013c695fbd30-9023bc55-f780-4d44-965f-ab4507e483d5-000000@email.amazonses.com>
	 <CAOJsxLH6BO_m+6Ys0AG8gHQzmoDovdA8kaAecUhcP5foXoEXUA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Fri, 2013-02-01 at 12:23 +0200, Pekka Enberg wrote:
> On Wed, Jan 23, 2013 at 11:45 PM, Christoph Lameter <cl@linux.com> wrote:
> > The variables accessed in slab_alloc are volatile and therefore
> > the page pointer passed to node_match can be NULL. The processing
> > of data in slab_alloc is tentative until either the cmpxhchg
> > succeeds or the __slab_alloc slowpath is invoked. Both are
> > able to perform the same allocation from the freelist.
> >
> > Check for the NULL pointer in node_match.
> >
> > A false positive will lead to a retry of the loop in __slab_alloc.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Steven, how did you trigger the problem - i.e. is this -rt only
> problem? Does the patch work for you?

I haven't tested Christoph's version yet. I've only tested my own. But
I'll take his and run them through tests as well. This bug is not easy
to hit.

It is not a -rt only bug, and yes it probably should go to stable. The
race is extremely small, but -rt creates scenarios that may only be hit
by 1000 CPU core machines. Because of the preemptive nature of -rt, -rt
is much more susceptible to race conditions than mainline. But these are
real bugs for mainline too. It may only trigger once a year, where in
-rt it will trigger once a week.

-- Steve

> 
> > Index: linux/mm/slub.c
> > ===================================================================
> > --- linux.orig/mm/slub.c        2013-01-18 08:47:29.198954250 -0600
> > +++ linux/mm/slub.c     2013-01-18 08:47:40.579126371 -0600
> > @@ -2041,7 +2041,7 @@ static void flush_all(struct kmem_cache
> >  static inline int node_match(struct page *page, int node)
> >  {
> >  #ifdef CONFIG_NUMA
> > -       if (node != NUMA_NO_NODE && page_to_nid(page) != node)
> > +       if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
> >                 return 0;
> >  #endif
> >         return 1;
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
