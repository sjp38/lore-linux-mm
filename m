Date: Mon, 24 Sep 2007 23:29:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <46F8A7FE.7000907@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.0.9999.0709242322100.5727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <46F88DFB.3020307@linux.vnet.ibm.com> <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com> <46F8A7FE.7000907@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Balbir Singh wrote:

> > One thing that has been changed in -mm with regard to my last patchset is 
> > that kswapd and try_to_free_pages() are allowed to call shrink_zone() 
> > concurrently.
> > 
> 
> Aah.. interesting. Could you define concurrently more precisely,
> concurrently as in the same zone or for different zones concurrently?
> 

Same zone, thankfully.

Previous to my 9-patch series that serialized the OOM killer, there was an 
atomic_t reclaim_in_progress member of each struct zone that was 
incremented each time shrink_zone() was called and decremented each time 
it exited.  The only place where this was tested was in zone_reclaim() and 
it returned 0 to __alloc_pages() if it was non-zero prior to calling 
__zone_reclaim().

So other callers to shrink_zone(), such as kswapd and try_to_free_pages(), 
were still able to invoke it several times for the same zone but 
zone_reclaim() could not if the zone was being shrunk, regardless of where 
shrink_zone() was called from. 

That's partially still true: kswapd and try_to_free_pages() (and actually 
balance_pgdat()) can still call it several times, but the first call to 
zone_reclaim() will also succeed since we're now indicating zone reclaims 
with a flag instead of an accumulator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
