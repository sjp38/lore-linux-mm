Message-ID: <41811F3A.1090706@shadowen.org>
Date: Thu, 28 Oct 2004 17:32:58 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC] sparsemem patches (was nonlinear)
References: <098973549.shadowen.org> <418118A1.9060004@us.ibm.com>
In-Reply-To: <418118A1.9060004@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> One thing that should simplify your code a bit are the no-buddy-bitmap 
> patches which are sitting in -mm right now.  You might want to think 
> about porting to -mm, it should reduce the total amount of code.

I've been meaning to bench those to see what effect losing the bitmaps 
has.  The difficult of the port to -mm due to the overlapping changes in 
the bitmaps has held me of that testing.  Sigh, going to have to bite 
the bullet.

> Also, after taking a bit more critical a look at the set, I'm not sure 
> they're quite ready for merging yet.  There are still a pretty good 
> number of #ifdefs
> 
> For instance, this:
> 
> +#ifdef HAVE_ARCH_ALLOC_REMAP
> +        map = (unsigned long *) alloc_remap(pgdat->node_id,
> +            bitmap_size);
> +        if (!map)
> +#endif
> +            map = (unsigned long *)alloc_bootmem_node(pgdat,
> +                bitmap_size);
> +        zone->free_area[order].map = map;
> 
> Could all be solved by doing #ifdef in a header to declare alloc_remap() 
> to return NULL if !HAVE_ARCH_ALLOC_REMAP.  In any case 
> HAVE_ARCH_ALLOC_REMAP should be defined via a Kconfig file, not in a 
> header.

Yep, this is all a little slack and rubbish.  Basically cause I don't 
really think its the right way to do it.  I think we should really be 
putting the remap space into the bootmem allocators for each of the 
nodes.  Then either we are ok, cause the things we want allocated in 
there are allocated first and use it up.  We'd need the concept of 
falling back to node 0 when its out ... but.  In short, I'm still 
thinking about this part of the patch as its ugly as you noticed.

> Have you given any thought to using virt_to_page(page)->foo method to 
> store section information instead of using page->flags?  It seems we're 
> already sucking up page->flags left and right, and I'd hate to consume 
> that many more.

As Martin indicates we don't use any more flags on the bit challenged 
arches where this would be an issue.  The little trick you used has some 
overhead to it, and current testing is showing an unexpected performance 
improvement with this stack.

> Although simple arithmetically, the calculations for the flags shift 
> does constitute a lot of code churn, and does add quite a bit of 
> complexity.

Yes, there is a lot of churn, though I hope the replacement 
infrastructure is more friendly to adding things to flags as needed.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
