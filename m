Date: Tue, 8 Apr 2008 14:14:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 18/18] dentries: dentry defragmentation
In-Reply-To: <20080407231434.88352977.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081409270.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230229.922470579@sgi.com>
 <20080407231434.88352977.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> > +		dentry = v[i];
> > +
> > +		if (dentry)
> > +			d_invalidate(dentry);
> > +	}
> 
> So ->kick can be passed a v[] which has NULLs in it, whereas ->get does
> not.  How come?

->get() may see that we cannot reclaim an entity because its going away. 
Then we zap the pointer. Described in the core docs.

> 
> > +	/*
> > +	 * If we are the last one holding a reference then the dentries can
> > +	 * be freed. We need the dcache_lock.
> > +	 */
> > +	spin_lock(&dcache_lock);
> 
> hrm.   What is a tyical value of `nr' here?

Number of dentries in a page. 19.

> > +	spin_unlock(&dcache_lock);
> 
> Do we know what the typical success rate is of the above code?

About 60-70% of slab pages are successfully reclaimed (updatedb). 
Percentage increases if more memory is used by caches dentries.
 
> More importantly - what is the worst success rate, and under which
> circumstances will it occur, and what are the consequences?

If just dentries remain that are pinned then the function 
will not succeed and the slab page will be marked unkickable and no longer 
scanned.

> > +	 * operations are complete
> > +	 */
> > +	synchronize_rcu();
> 
> Do we?  Why?

dentries must be removed by RCU. We cannot free the page before the RCU 
period has expired.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
