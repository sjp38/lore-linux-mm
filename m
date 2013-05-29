Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 8799E6B012C
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:29:07 -0400 (EDT)
Date: Wed, 29 May 2013 14:29:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-Id: <20130529142904.ace2a29b90a9076d0ee251fd@linux-foundation.org>
In-Reply-To: <754ae8a0-23af-4c87-953f-d608cba84191@default>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
	<20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
	<20130529154500.GB428@cerebellum>
	<20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
	<20130529204236.GD428@cerebellum>
	<20130529134835.58dd89774f47205da4a06202@linux-foundation.org>
	<754ae8a0-23af-4c87-953f-d608cba84191@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, 29 May 2013 14:09:02 -0700 (PDT) Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > memory_failure() is merely an example of a general problem: code which
> > reads from the memmap[] array and expects its elements to be of type
> > `struct page'.  Other examples might be memory hotplugging, memory leak
> > checkers etc.  I have vague memories of out-of-tree patches
> > (bigphysarea?) doing this as well.
> > 
> > It's a general problem to which we need a general solution.
> 
> <Obi-tmem Kenobe slowly materializes... "use the force, Luke!">
> 
> One could reasonably argue that any code that makes incorrect
> assumptions about the contents of a struct page structure is buggy
> and should be fixed.

Well it has type "struct page" and all code has a right to expect the
contents to match that type.

>  Isn't the "general solution" already described
> in the following comment, excerpted from include/linux/mm.h, which
> implies that "scribbling on existing pageframes" [carefully], is fine?
> (And, if not, shouldn't that comment be fixed, or am I misreading
> it?)
> 
> <start excerpt>
>  * For the non-reserved pages, page_count(page) denotes a reference count.
>  *   page_count() == 0 means the page is free. page->lru is then used for
>  *   freelist management in the buddy allocator.
>  *   page_count() > 0  means the page has been allocated.

Well kinda maybe.  How all the random memmap-peekers handle this I do
not know.  Setting PageReserved is a big hammer which should keep other
little paws out of there, although I guess it's abusive of whatever
PageReserved is supposed to mean.

It's what we used to call a variant record.  The tag is page.flags and
the protocol is, umm,

PageReserved: doesn't refer to a page at all - don't touch
PageSlab: belongs to slab or slub
!PageSlab: regular kernel/user/pagecache page

Are there any more?

So what to do here?  How about

- Position the zbud fields within struct page via the preferred
  means: editing its definition.

- Decide upon and document the means by which the zbud variant is tagged

- Demonstrate how this is safe against existing memmap-peekers

- Do all this without consuming another page flag :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
