Date: Thu, 2 Aug 2007 12:16:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH] type safe allocator
In-Reply-To: <E1IGVGf-0000sv-00@dorka.pomaz.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0708021211100.7948@schroedinger.engr.sgi.com>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
 <Pine.LNX.4.64.0708012223520.3265@schroedinger.engr.sgi.com>
 <E1IGVGf-0000sv-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Miklos Szeredi wrote:

> > If you define a new flag like GFP_ZERO_ATOMIC and GFP_ZERO_KERNEL you 
> > could do
> > 
> > 	kalloc(struct, GFP_ZERO_KERNEL)
> > 
> > instead of adding new variants?
> 
> I don't really like this, introducing new gfp flags just makes
> grepping harder.

The __GFP_ZERO flag has been around for a long time. GFP_ZERO_ATOMIC and 
GFP_ZERO_KERNEL or so could just be a shorthand notation.

Maybe

#define GFP_ZATOMIC (GFP_ATOMIC | __GFP_ZERO)
#define GFP_ZKERNEL (GFP_KERNEL | __GFP_ZERO)

?

> I do think that at least having a zeroing and a non-zeroing variant
> makes sense.

They require a duplication of the API and have led to inconsistencies 
because the complete API was not available with zeroing capabilities 
(there is still no kzalloc_node f.e.). 
Using a gfp flag allows all allocation functions to optionally zero data 
without having to define multiple functions.

The definition of new variants is a bit complicated since the allocator 
functions contain lots of smarts to do inline constant folding. This is 
necessary to determine the correct slab at compile time. I'd rather have 
as few of those as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
