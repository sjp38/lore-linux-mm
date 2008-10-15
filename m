Subject: Re: [rfc] SLOB memory ordering issue
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.LFD.2.00.0810151033170.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au>
	 <1224089658.3316.218.camel@calx>
	 <200810160410.49894.nickpiggin@yahoo.com.au>
	 <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810151033170.3288@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Wed, 15 Oct 2008 12:58:33 -0500
Message-Id: <1224093513.3316.250.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-15 at 10:36 -0700, Linus Torvalds wrote:
> 
> On Wed, 15 Oct 2008, Linus Torvalds wrote:
> > 
> > If you make an allocation visible to other CPU's, you would need to make 
> > sure that allocation is stable with a smp_wmb() before you update the 
> > pointer to that allocation.
> 
> Just to clarify a hopefully obvious issue..
> 
> The assumption here is that you don't protect things with locking. Of 
> course, if all people accessing the new pointer always have the 
> appropriate lock, then memory ordering never matters, since the locks take 
> care of it.

Right. This is the 99.9% case and is why we should definitely not put an
additional barrier in the allocator.

Lockless users are already on their own with regard to memory ordering
issues, so it makes sense for them to absorb the (often nil) incremental
cost of ensuring object initialization gets flushed.

I feel like we ought to document this in the SLAB API, but at the same
time, I think we'll scare more people than we'll enlighten.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
