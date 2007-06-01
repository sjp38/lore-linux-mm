Message-ID: <46603371.50808@goop.org>
Date: Fri, 01 Jun 2007 07:55:45 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
References: <20070531002047.702473071@sgi.com>
In-Reply-To: <20070531002047.702473071@sgi.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

clameter@sgi.com wrote:
> A while back we talked about having the capability of switching off checks
> like the one for kmalloc(0) for stable kernel releases. This is a first stab
> at such functionality. It adds #ifdef CONFIG_STABLE for now. Maybe we can
> come up with some better way to handle it later. There should alsol be some
> way to set CONFIG_STABLE from the Makefile.
>
> CONFIG_STABLE switches off
>
> - kmalloc(0) check in both slab allocators
> - SLUB banner
> - Makes SLUB tolerate object corruption like SLAB (not sure if we really want
>   to go down this route. See patch)
>   

Perhaps I missed it, but what's the rationale for complaining about
0-sized allocations?  They seem like a perfectly reasonable thing to me;
they turn up at the boundary conditions of many algorithms, and avoiding
them just cruds up the callsites to make them go through hoops to avoid
allocation. 

Why not just do a 1 byte allocation instead, and be done with it?  Any
non-constant-sized allocation will potentially have to deal with this
case, so it seems to me we could just put the fix in common code (and
use an inline wrapper to avoid it when dealing with constant non-zero
sized allocations).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
