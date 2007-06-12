Date: Tue, 12 Jun 2007 14:08:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <Pine.LNX.4.64.0706121406020.1850@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.99.0706121408250.5104@chino.kir.corp.google.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com>
 <alpine.DEB.0.99.0706121403420.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121406020.1850@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Christoph Lameter wrote:

> On Tue, 12 Jun 2007, David Rientjes wrote:
> 
> > > ===================================================================
> > > --- linux-2.6.22-rc4-mm2.orig/include/linux/gfp.h	2007-06-12 12:33:37.000000000 -0700
> > > +++ linux-2.6.22-rc4-mm2/include/linux/gfp.h	2007-06-12 12:38:37.000000000 -0700
> > > @@ -175,6 +175,13 @@ static inline struct page *alloc_pages_n
> > >  	if (nid < 0)
> > >  		nid = numa_node_id();
> > >  
> > > +	/*
> > > +	 * Check for the special case that GFP_THISNODE is used on a
> > > +	 * memoryless node
> > > +	 */
> > > +	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
> > > +		return NULL;
> > > +
> > 
> > unlikely()?
> 
> The gfp_mask is typically constant. So the whole expression is folded by the 
> compiler into either
> 
> if (!node_memory(nid))
> 	return NULL
> 
> or 
> 
> nothing.
> 

That's the point.  Isn't !node_memory(nid) unlikely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
