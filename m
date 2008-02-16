Date: Sat, 16 Feb 2008 11:31:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080216025803.40d8ccbc.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802161129020.25573@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.371510599@sgi.com>
 <20080215193719.262c03a1.akpm@linux-foundation.org> <47B6BDDF.90502@inria.fr>
 <20080216025803.40d8ccbc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Brice Goglin <Brice.Goglin@inria.fr>, Andrea Arcangeli <andrea@qumranet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008, Andrew Morton wrote:

> "looks good" maybe.  But it's in the details where I fear this will come
> unstuck.  The likelihood that some callbacks really will want to be able to
> block in places where this interface doesn't permit that - either to wait
> for IO to complete or to wait for other threads to clear critical regions.

We can get the invalidate_range to always be called without spinlocks if 
we deal with the case of the inode_mmap_lock being held in truncate case.

If you always want to be able to sleep then we could drop the 
invalidate_page() that is called while pte locks held and require the use 
of a device driver rmap?

> >From that POV it doesn't look like a sufficiently general and useful
> design.  Looks like it was grafted onto the current VM implementation in a
> way which just about suits two particular clients if they try hard enough.

You missed KVM. We did the best we could being as least invasive as 
possible.

> Which is all perfectly understandable - it would be hard to rework core MM
> to be able to make this interface more general.  But I do think it's
> half-baked and there is a decent risk that future (or present) code which
> _could_ use something like this won't be able to use this one, and will
> continue to futz with mlock, page-pinning, etc.
> 
> Not that I know what the fix to that is..

You do not see a chance of this being okay if we adopt the two measures 
that I mentioned above?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
