Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 049446B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:39:26 -0400 (EDT)
Date: Wed, 15 Aug 2012 17:40:19 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120815144019.GH3068@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com>
 <20120813084123.GF14081@redhat.com>
 <87lihis5qi.fsf@rustcorp.com.au>
 <20120814083320.GA3597@redhat.com>
 <20120814184409.GC13338@t510.redhat.com>
 <20120814193109.GA28840@redhat.com>
 <20120815123457.GA2175@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120815123457.GA2175@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Wed, Aug 15, 2012 at 09:34:58AM -0300, Rafael Aquini wrote:
> On Tue, Aug 14, 2012 at 10:31:09PM +0300, Michael S. Tsirkin wrote:
> > > > now CPU1 executes the next instruction:
> > > > 
> > > > }
> > > > 
> > > > which would normally return to function's caller,
> > > > but it has been overwritten by CPU2 so we get corruption.
> > > > 
> > > > No?
> > > 
> > > At the point CPU2 is unloading the module, it will be kept looping at the
> > > snippet Rusty pointed out because the isolation / migration steps do not mess
> > > with 'vb->num_pages'. The driver will only unload after leaking the total amount
> > > of balloon's inflated pages, which means (for this hypothetical case) CPU2 will
> > > wait until CPU1 finishes the putaback procedure.
> > > 
> > 
> > Yes but only until unlock finishes. The last return from function
> > is not guarded and can be overwritten.
> 
> CPU1 will be returning to putback_balloon_page() which code is located at core
> mm/compaction.c, outside the driver.

Sorry, I don't seem to be able to articulate this clearly.
But this is a correctness issue so I am compelled to try again.

Here is some pseudo code:

int pages_lock;

void virtballoon_isolatepage(void *page, unsigned long mode)
{
       pages_lock = 0;
}

assignment of 0 emulates spin unlock.
I removed all other content. Now look at disassembly:

080483d0 <virtballoon_isolatepage>:
virtballoon_isolatepage():
 80483d0:       c7 05 88 96 04 08 00    movl   $0x0,0x8049688
 80483d7:       00 00 00 

<----------- Above is "spin unlock"

 80483da:       c3                      ret    

^^^^
Here we are still executing module code (one instruction of it!)
after we have dropped the lock.


So if module goes away at the point marked by <--------
above (and nothing seems to prevent that,
since pages_lock is unlocked), the last instruction can get overwritten
and then random code will get executed instead.

In the end the rule is simple: you can not
prevent module unloading from within module
itself. It always must be the caller of your
module that uses some lock to do this.

My proposal is to use rcu for this since it is lightweight
and also does not require us to pass extra
state around.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
