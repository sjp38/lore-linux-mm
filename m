Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CF2096B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 16:56:15 -0500 (EST)
Date: Tue, 31 Jan 2012 22:56:05 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] sunrpc: initialize delayed work on each rpc_inode
 allocation
In-Reply-To: <20120131101216.00788753@tlielax.poochiereds.net>
Message-ID: <alpine.LFD.2.02.1201312231311.6143@ionos>
References: <1327426850-14837-1-git-send-email-jlayton@redhat.com> <4F2700E2.9020803@RedHat.com> <1327957652.4090.32.camel@lade.trondhjem.org> <20120130185753.50280816@tlielax.poochiereds.net> <4F2800B4.6040302@panasas.com>
 <20120131101216.00788753@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, Steve Dickson <SteveD@redhat.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

On Tue, 31 Jan 2012, Jeff Layton wrote:

> On Tue, 31 Jan 2012 16:54:44 +0200
> Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> > On 01/31/2012 01:57 AM, Jeff Layton wrote:
> > >     WARNING: at lib/debugobjects.c:262 debug_print_object+0x8c/0xb0()
> > > 
> > > For now, this patch is really just papering over that problem, but it
> > > should be "mostly harmless". That said, I'm ok with dropping it if
> > > Thomas is planning to fix this in the debugobjects code however.
> > > 
> > 
> > I disagree it's harmless. What if kmem_cache_free/kmem_cache_alloc deploys
> > a poisoning schema, in debug mode. Which stumps over memory. Is it
> > initialized then?
> > 
> 
> Different slab allocators handle that differently. As best I can tell:
> 
> SLAB: calls ctor on the poisoned object before handing it back out
> 
> SLUB: avoids poisoning the object if there's a ->ctor defined

Brilliant. Preventing debug code from catching bugs is really a great
idea. This needs to be fixed ASAP.
 
> SLOB: I'm not sure -- haven't looked at it
> 
> > What was the last state of the timer, is it safe for resume?
> > 
> 
> Yes, either way it's safe to reuse the recycled object, aside from the
> problem with debugobjects. If it's not then that's clearly a bug in the
> slab allocator.
> > For us this is a new object we should initialize it.
> > 
> 
> I tend to agree that not relying on slab ctor functions is preferable.
> They are widely used though so this problem almost assuredly exists in
> other places besides just rpc_pipefs. If it's not fixed in the
> debugobjects code (or the slab allocators) then I wouldn't be surprised
> if this popped up again in another area.

There is nothing the debugobjects code can do about this. The
indication for removing the object from the hash is the
kmem_cache_free() operation and from that point on the object is not
longer usable. That's correct and it's not going to change.

The correct solution to this problem is to do the following:

Extend the kmemcache with a debug_ctor() callback. 

In case of slab poisoning make it call ctor().

In case of debugobjects (w/o slab poisoning) make it a function which
reinitializes the timer or what ever subobject which needs an explicit
state check. In case of timers this should be a separate function
(e.g. timer_reinit()) which soleley makes the timer known to the debug
code again.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
