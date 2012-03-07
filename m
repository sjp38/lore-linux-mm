Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 067EA6B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 23:25:41 -0500 (EST)
Received: by iajr24 with SMTP id r24so10473624iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 20:25:41 -0800 (PST)
Date: Tue, 6 Mar 2012 20:25:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
In-Reply-To: <20120306160833.0e9bf50a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 6 Mar 2012, Andrew Morton wrote:

> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1611,6 +1611,7 @@ unsigned slab_node(struct mempolicy *policy)
> >  
> >  	default:
> >  		BUG();
> > +		return numa_node_id();
> >  	}
> >  }
> 
> Wait.  If the above code generated a warning then surely we get a *lot*
> of warnings!  I'd expect that a lot of code assumes that BUG() never
> returns?
> 

allyesconfig with CONFIG_BUG=n results in 50 such warnings tree wide, and 
this is the only one in mm/*.

> Also, does CONIG_BUG=n even make sense?  If we got here and we know
> that the kernel has malfunctioned, what point is there in pretending
> otherwise?  Odd.
> 

I don't suspect we'll be very popular if we try to remove it, I can see 
how it would be useful when BUG() is used when the problem isn't really 
fatal (to stop something like disk corruption), like the above case isn't. 
If policy->mode isn't one of MPOL_{BIND,INTERLEAVE,PREFERRED} then we'd 
want WARN_ON_ONCE() at best; someone either didn't test their patch or 
we've flipped a bit, but the kernel can run happily along using the local 
node for slab allocations while still notifying the user.

mm/mempolicy.c misuses BUG() in every case,  Not having the perfect NUMA 
optimizations is surely annoying, but let's not crash someone's kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
