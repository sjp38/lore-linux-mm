Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7D01E6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 08:35:17 -0400 (EDT)
Date: Wed, 15 Aug 2012 09:34:58 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120815123457.GA2175@t510.redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
 <20120813084123.GF14081@redhat.com>
 <87lihis5qi.fsf@rustcorp.com.au>
 <20120814083320.GA3597@redhat.com>
 <20120814184409.GC13338@t510.redhat.com>
 <20120814193109.GA28840@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120814193109.GA28840@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 14, 2012 at 10:31:09PM +0300, Michael S. Tsirkin wrote:
> > > now CPU1 executes the next instruction:
> > > 
> > > }
> > > 
> > > which would normally return to function's caller,
> > > but it has been overwritten by CPU2 so we get corruption.
> > > 
> > > No?
> > 
> > At the point CPU2 is unloading the module, it will be kept looping at the
> > snippet Rusty pointed out because the isolation / migration steps do not mess
> > with 'vb->num_pages'. The driver will only unload after leaking the total amount
> > of balloon's inflated pages, which means (for this hypothetical case) CPU2 will
> > wait until CPU1 finishes the putaback procedure.
> > 
> 
> Yes but only until unlock finishes. The last return from function
> is not guarded and can be overwritten.

CPU1 will be returning to putback_balloon_page() which code is located at core
mm/compaction.c, outside the driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
