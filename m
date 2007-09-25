Date: Mon, 24 Sep 2007 21:34:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <46F88DFB.3020307@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <46F88DFB.3020307@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Balbir Singh wrote:

> > +
> > +	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
> > +		return 0;
> 
> What's the consequence of this on the caller of zone_reclaim()?
> I see that the zone is marked as full and will not be re-examined
> again.
> 

It's only marked as full in the zonelist cache for the zonelist that 
__alloc_pages() was called with, which is an optimization.  The zone is 
already flagged as being in __zone_reclaim() so there's no need to 
reinvoke it for this allocation attempt; that behavior is unchanged from 
current behavior.

One thing that has been changed in -mm with regard to my last patchset is 
that kswapd and try_to_free_pages() are allowed to call shrink_zone() 
concurrently.

ZONE_RECLAIM_LOCKED will be cleared upon return from __zone_reclaim().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
