Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D3AA36B0070
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 01:11:24 -0400 (EDT)
Date: Mon, 20 Aug 2012 08:12:18 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120820051218.GA1095@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
 <20120813084123.GF14081@redhat.com>
 <87lihis5qi.fsf@rustcorp.com.au>
 <20120814083320.GA3597@redhat.com>
 <20120814184409.GC13338@t510.redhat.com>
 <20120814193109.GA28840@redhat.com>
 <20120815123457.GA2175@t510.redhat.com>
 <20120815144019.GH3068@redhat.com>
 <87fw7i5ma0.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fw7i5ma0.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Mon, Aug 20, 2012 at 11:59:11AM +0930, Rusty Russell wrote:
> On Wed, 15 Aug 2012 17:40:19 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > On Wed, Aug 15, 2012 at 09:34:58AM -0300, Rafael Aquini wrote:
> > > On Tue, Aug 14, 2012 at 10:31:09PM +0300, Michael S. Tsirkin wrote:
> > > > > > now CPU1 executes the next instruction:
> > > > > > 
> > > > > > }
> > > > > > 
> > > > > > which would normally return to function's caller,
> > > > > > but it has been overwritten by CPU2 so we get corruption.
> > > > > > 
> > > > > > No?
> > > > > 
> > > > > At the point CPU2 is unloading the module, it will be kept looping at the
> > > > > snippet Rusty pointed out because the isolation / migration steps do not mess
> > > > > with 'vb->num_pages'. The driver will only unload after leaking the total amount
> > > > > of balloon's inflated pages, which means (for this hypothetical case) CPU2 will
> > > > > wait until CPU1 finishes the putaback procedure.
> > > > > 
> > > > 
> > > > Yes but only until unlock finishes. The last return from function
> > > > is not guarded and can be overwritten.
> > > 
> > > CPU1 will be returning to putback_balloon_page() which code is located at core
> > > mm/compaction.c, outside the driver.
> > 
> > Sorry, I don't seem to be able to articulate this clearly.
> > But this is a correctness issue so I am compelled to try again.
> 
> But if there are 0 balloon pages, how is it migrating a page?

It could be we just finished migrating a page
dropped page lock and are 1 instruction away from
returning from callback.

> > In the end the rule is simple: you can not
> > prevent module unloading from within module
> > itself. It always must be the caller of your
> > module that uses some lock to do this.
> 
> Not quite.  If you clean up everything in your cleanup function, it also
> works,

No, we also need a way to make sure we returned
to caller, this is missing here.

> which is what this does, right?
> 
> Cheers,
> Rusty.


This makes sure callback was invoked but not that it returned
to caller.

All will be well if callbacks are done in rcu critical section
and we synchronise it before unload.


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
