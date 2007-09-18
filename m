Date: Tue, 18 Sep 2007 13:13:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/4] oom: save zonelist pointer for oom killer calls
In-Reply-To: <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Christoph Lameter wrote:

> On Tue, 18 Sep 2007, David Rientjes wrote:
> 
> > +
> > +	oom_zl = kzalloc(sizeof(*oom_zl), GFP_KERNEL);
> > +	if (!oom_zl)
> > +		goto out;
> 
> An allocation in the oom killer? This could in turn trigger more 
> problems. Maybe its best to put a list head into the zone?
> 

I thought about doing that as well as statically allocating

	#define MAX_OOM_THREADS		4
	static struct zonelist *zonelists[MAX_OOM_THREADS];

and using semaphores.  But in my testing of this patchset and experience 
in working with the watermarks used in __alloc_pages(), we should never 
actually encounter a condition where we can't find
sizeof(struct oom_zonelist) of memory.  That's on the order of how many 
invocations of the OOM killer you have, but I don't actually think you'll 
have many that have a completely exclusive set of zones in the zonelist.  
Watermarks usually do the trick (and is the only reason TIF_MEMDIE works, 
by the way).

I'm not sure how embedding a list_head in struct zone would work even 
though we're adding the premise that a single zone can only be in the OOM 
killer once.  You'd have to recreate the zonelist by stringing together 
these heads in the zone but the whole concept relies upon finding a 
pointer to an already existing struct zonelist.  It works nicely as is 
because the struct zonelist is persistent in __alloc_pages() so it is easy 
to pass it to both zone_in_oom() and zonelist_clear_oom().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
