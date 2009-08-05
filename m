Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FBA86B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 07:39:19 -0400 (EDT)
Date: Wed, 5 Aug 2009 12:39:06 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 3/12] ksm: pages_unshared and pages_volatile
In-Reply-To: <20090804144920.bfc6a44f.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0908051216020.13195@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031311061.16754@sister.anvils>
 <20090804144920.bfc6a44f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ieidus@redhat.com, aarcange@redhat.com, riel@redhat.com, chrisw@redhat.com, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Aug 2009, Andrew Morton wrote:
> On Mon, 3 Aug 2009 13:11:53 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > pages_volatile is harder to define.  It includes those pages changing
> > too fast to get into the unstable tree, but also whatever other edge
> > conditions prevent a page getting into the trees: a high value may
> > deserve investigation.  Don't try to calculate it from the various
> > conditions: it's the total of rmap_items less those accounted for.
...
> >  static inline struct rmap_item *alloc_rmap_item(void)
> >  {
> > -	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> > +	struct rmap_item *rmap_item;
> > +
> > +	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> > +	if (rmap_item)
> > +		ksm_rmap_items++;
> > +	return rmap_item;
> >  }
> 
> ksm_rmap_items was already available via /proc/slabinfo.  I guess that
> wasn't a particularly nice user interface ;)

procfs is not a nice interface for sysfs to be reading
when it's asked to show pages_volatile!

And not even always available, I think: SLOB wouldn't be able to report
the number of objects of any particular type, SLUB would need slub_nomerge
(or a debug flag) to keep the kmem_cache separate; and even SLAB would
have to assemble numbers from different cpus and queues, I guess.
Easier and more reliable for KSM to do its own thing here.

I do agree that slabinfo or slqbinfo or /proc/slabinfo is a good enough
interface for checking up on the number of rmap_items in use; it's what
I was using most of the time.  I did once fleetingly wonder whether to
show the count of rmap_items under /sys/kernel/mm/ksm, but rejected it
as not interesting enough to deserve more than what slabinfo tells.

But here the rmap_item count is being used to deduce something more
interesting (though more obscure), and I don't want SL?B divergences
to perturb the resulting number more than it is already.  I did start
out without the rmap_items count, incrementing and decrementing
pages_volatile all over the place; but soon abandoned that in
favour of the difference calculation.

But I think I'm taking you more seriously than you intended,
sorry for my humourlessness!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
