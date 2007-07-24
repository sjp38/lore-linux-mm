Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins>
	 <20070723112143.GB19437@skynet.ie> <1185190711.8197.15.camel@twins>
	 <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 08:01:09 +0200
Message-Id: <1185256869.8197.27.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 16:17 -0700, Christoph Lameter wrote:
> On Mon, 23 Jul 2007, Peter Zijlstra wrote:
> 
> > ---
> > Daniel recently spotted that __GFP_ZERO is not (and has never been)
> > part of GFP_LEVEL_MASK. I could not find a reason for this in the
> > original patch: 3977971c7f09ce08ed1b8d7a67b2098eb732e4cd in the -bk
> > tree.
> > 
> > This of course is in stark contradiction with the comment accompanying
> > GFP_LEVEL_MASK.
> 
> NACK.
> 
> The effect that this patch will have is that __GFP_ZERO is passed through 
> to the page allocator which will needlessly zero pages. GFP_LEVEL_MASK is 
> used to filter out the flags that are to be passed to the page allocator. 
> __GFP_ZERO is not passed on but handled by the slab allocators.

Then we can either fixup the slab allocators to mask out __GFP_ZERO, or
do something like the below.

Personally I like the consistency of adding __GFP_ZERO here (removes
this odd exception) and just masking it in the sl[aou]b thingies.

Anybody else got a preference?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/gfp.h |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: linux-2.6-2/include/linux/gfp.h
===================================================================
--- linux-2.6-2.orig/include/linux/gfp.h
+++ linux-2.6-2/include/linux/gfp.h
@@ -53,7 +53,14 @@ struct vm_area_struct;
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
-/* if you forget to add the bitmask here kernel will crash, period */
+/*
+ * If you forget to add the bitmask here kernel will crash, period!
+ *
+ * GFP_LEVEL_MASK is used to filter out the flags that are to be passed to the
+ * page allocator.
+ *
+ * __GFP_ZERO is not passed on but handled by the slab allocators.
+ */
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_COMP| \


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
