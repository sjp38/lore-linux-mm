Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 7F4BD6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 09:06:30 -0400 (EDT)
Date: Thu, 23 Aug 2012 10:06:07 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120823130606.GB3746@t510.redhat.com>
References: <20120821192357.GD12294@t510.redhat.com>
 <20120821193031.GC9027@redhat.com>
 <20120821204556.GF12294@t510.redhat.com>
 <20120822000741.GI9027@redhat.com>
 <20120822011930.GA23753@t510.redhat.com>
 <20120822093317.GC10680@redhat.com>
 <20120823021903.GA23660@x61.redhat.com>
 <20120823100107.GA17409@redhat.com>
 <20120823121338.GA3062@t510.redhat.com>
 <20120823123432.GA25659@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120823123432.GA25659@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 23, 2012 at 03:34:32PM +0300, Michael S. Tsirkin wrote:
> > So, nothing has changed here.
> 
> Yes, your patch does change things:
> leak_balloon now might return without freeing any pages.
> In that case we will not be making any progress, and just
> spin, pinning CPU.

That's a transitory condition, that migh happen if leak_balloon() takes place
when compaction, or migration are under their way and it might only affects the
module unload case. Also it won't pin CPU because it keeps releasing the locks
it grabs, as it loops. So, we are locubrating about rarities, IMHO. 

> 
> >  
> > > > Just as before, same thing here. If you leaked less than required, balloon()
> > > > will keep calling leak_balloon() until the balloon target is reached. This
> > > > scheme was working before, and it will keep working after this patch.
> > > >
> > > 
> > > IIUC we never hit this path before.
> > >  
> > So, how does balloon() works then?
> > 
> 
> It gets a request to leak a given number of pages
> and executes it, then tells host that it is done.
> It never needs to spin busy-waiting on a CPU for this.
>

So, what this patch changes for the ordinary leak_balloon() case?

 
> Well busy wait pinning CPU is ugly.  Instead we should block thread and
> wake it up when done.  I don't mind how we fix it specifically.
>

I already told you that we do not do that by any mean introduced by this patch.
You're just being stubborn here. If those bits are broken, they were already
broken before I did come up with this proposal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
