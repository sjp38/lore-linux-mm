Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 90E7B6B0023
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:35:55 -0500 (EST)
Date: Thu, 31 Jan 2013 14:35:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv4 2/7] zsmalloc: promote to lib/
Message-ID: <20130131053554.GD23548@blaptop>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359495627-30285-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130129145134.813672cf.akpm@linux-foundation.org>
 <51094A39.8050206@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51094A39.8050206@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Jan 30, 2013 at 10:28:41AM -0600, Seth Jennings wrote:
> On 01/29/2013 04:51 PM, Andrew Morton wrote:
> > On Tue, 29 Jan 2013 15:40:22 -0600
> > Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> > 
> >> This patch promotes the slab-based zsmalloc memory allocator
> >> from the staging tree to lib/
> > 
> > Hate to rain on the parade, but...  we haven't reviewed zsmalloc
> > yet.  At least, I haven't, and I haven't seen others do so.
> > 
> > So how's about we forget that zsmalloc was previously in staging and
> > send the zsmalloc code out for review?  With a very good changelog
> > explaining why it exists, what problems it solves, etc.
> > 
> > 
> > I peeked.
> > 
> > Don't answer any of the below questions - they are examples of
> > concepts which should be accessible to readers of the
> > hopefully-forthcoming very-good-changelog.
> > 
> > - kmap_atomic() returns a void* - there's no need to cast its return value.
> > 
> > - Remove private MAX(), use the (much better implemented) max().
> > 
> > - It says "This was one of the major issues with its predecessor
> >   (xvmalloc)", but drivers/staging/ramster/xvmalloc.c is still in the tree.
> > 
> > - USE_PGTABLE_MAPPING should be done via Kconfig.
> > 
> > - USE_PGTABLE_MAPPING is interesting and the changelog should go into
> >   some details.  What are the pros and cons here?  Why do the two
> >   options exist?  Can we eliminate one mode or the other?
> > 
> > - Various functions are obscure and would benefit from explanatory
> >   comments.  Good comments explain "why it exists", more than "what it
> >   does".
> > 
> >   These include get_size_class_index, get_fullness_group,
> >   insert_zspage, remove_zspage, fix_fullness_group.
> > 
> >   Also a description of this handle encoding thing - what do these
> >   "handles" refer to?  Why is stuff being encoded into them and how?
> > 
> > - I don't understand how the whole thing works :( If I allocate a
> >   16 kbyte object with zs_malloc(), what do I get?  16k of
> >   contiguous memory?  How can it do that if
> >   USE_PGTABLE_MAPPING=false?  Obviously it can't so it's doing
> >   something else.  But what?
> > 
> > - What does zs_create_pool() do and how do I use it?  It appears
> >   to create a pool of all possible object sizes.  But why do we need
> >   more than one such pool kernel-wide?
> > 
> > - I tried to work out the actual value of ZS_SIZE_CLASSES but it
> >   made my head spin.
> > 
> > - We really really don't want to merge zsmalloc!  It would be far
> >   better to use an existing allocator (perhaps after modifying it)
> >   than to add yet another new one.  The really-good-changelog should
> >   be compelling on this point, please.
> > 
> > See, I (and I assume others) are totally on first base here and we need
> > to get through this before we can get onto zswap.  Sorry. 
> > drivers/staging is where code goes to be ignored :(
> 
> I've noticed :-/
> 
> Thank you very much for your review!  I'll work with Nitin and Minchan
> to beef up the documentation so that the answers to your questions are
> more readily apparent in the code/comments.

Actually, Kconfig of USE_PGTABLE_MAPPING is my plan.
Will do it if anyone has no objection.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
