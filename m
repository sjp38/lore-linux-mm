Subject: Re: [patch 6/6] mm: bdi: allow setting a maximum for the bdi dirty
	limit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1JKW0Q-000200-An@pomaz-ex.szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
	 <20080129154954.275142755@szeredi.hu>
	 <20080130163927.760e94cc.akpm@linux-foundation.org>
	 <E1JKW0Q-000200-An@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Thu, 31 Jan 2008 11:17:47 +0100
Message-Id: <1201774667.28547.286.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-01-31 at 10:46 +0100, Miklos Szeredi wrote:
> > On Tue, 29 Jan 2008 16:49:06 +0100
> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > 
> > > Add "max_ratio" to /sys/class/bdi.  This indicates the maximum
> > > percentage of the global dirty threshold allocated to this bdi.
> > 
> > Maybe I'm having a stupid day, but I don't understand the semantics of this
> > min and max at all.  I've read the code, and I've read the comments (well,
> > I've hunted for some) and I've read the docs.
> > 
> > I really don't know how anyone could use this in its current state without
> > doing a lot of code-reading and complex experimentation.  All of which
> > would be unneeded if this tunable was properly documented.
> > 
> > So.  Please provide adequate documentation for this tunable.  I'd suggest
> > that it be pitched at the level of a reasonably competent system operator. 
> > It should help them understand why the tunable exists, why they might
> > choose to alter it, and what effects they can expect to see.  Hopefully a
> > reaonably competent kernel developer can then understand it too.
> 
> OK.  I think what's missing from some docs, is a high level
> description of the per-bdi throttling algorithm, and how it affects
> writeback.  Because with info, I think the min and max ratios are
> trivially understandable: they just override the result of the
> algorithm, in case it would mean too high or too low threshold.
> 
> Peter, could you write something about that?

Sure.

How about something like:

Under normal circumstances each device is given a part of the total
write-back cache that relates to its current avg writeout speed in
relation to the other devices.

min_ratio - allows one to assign a minimum portion of the write-back
cache to a particular device. This is useful in situations where you
might want to provide a minimum QoS. (One request for this feature came
from flash based storage people who wanted to avoid writing out at all
costs - they of course needed some pdflush hacks as well)

max_ratio - allows one to assign a maximum portion of the dirty limit to
a particular device. This is useful in situations where you want to
avoid one device taking all or most of the write-back cache. Eg. an NFS
mount that is prone to get stuck, or a FUSE mount which you don't trust
to play fair.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
