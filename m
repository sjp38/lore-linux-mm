Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 14 May 2007 18:10:11 +0200
Message-Id: <1179159011.2942.16.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 08:53 -0700, Christoph Lameter wrote:
> On Mon, 14 May 2007, Peter Zijlstra wrote:
> 
> > In the interest of creating a reserve based allocator; we need to make the slab
> > allocator (*sigh*, all three) fair with respect to GFP flags.
> 
> I am not sure what the point of all of this is. 
> 
> > That is, we need to protect memory from being used by easier gfp flags than it
> > was allocated with. If our reserve is placed below GFP_ATOMIC, we do not want a
> > GFP_KERNEL allocation to walk away with it - a scenario that is perfectly
> > possible with the current allocators.
> 
> Why does this have to handled by the slab allocators at all? If you have 
> free pages in the page allocator then the slab allocators will be able to 
> use that reserve.

Yes, too freely. GFP flags are only ever checked when you allocate a new
page. Hence, if you have a low reaching alloc allocating a slab page;
subsequent non critical GFP_KERNEL allocs can fill up that slab. Hence
you would need to reserve a slab per object instead of the normal
packing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
