Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 210CB6B0117
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 22:32:09 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Memory management woes - order 1 allocation failures
Date: Fri, 12 Mar 2010 04:32:03 +0100
References: <alpine.DEB.2.00.1002261042020.7719@router.home> <20100302221751.20addf02@lxorguk.ukuu.org.uk> <20100302222933.GF11355@csn.ul.ie>
In-Reply-To: <20100302222933.GF11355@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201003120432.06149.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Greg KH <gregkh@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Tuesday 02 March 2010, Mel Gorman wrote:
> On Tue, Mar 02, 2010 at 10:17:51PM +0000, Alan Cox wrote:
> > > -#define TTY_BUFFER_PAGE		((PAGE_SIZE  - 256) / 2)
> > > +#define TTY_BUFFER_PAGE	(((PAGE_SIZE - sizeof(struct tty_buffer)) /
> > > 2) & ~0xFF)
> >
> > Yes agreed I missed a '-1'
>
> Frans, would you mind testing your NAS box with the following patch
> applied please? It should apply cleanly on top of 2.6.33-rc7. Thanks

Thanks Mel.

I've been running with this patch for about a week now and have so far not 
seen any more allocation failures. I've tried doing large rsyncs a few 
times.

It's not 100% conclusive, but I would say it improves things and I've 
certainly not noticed any issues with the patch.

Before I got the patch I noticed that the default value for 
vm.min_free_kbytes was only 1442 for this machine. Isn't that on the low 
side? Could that have been a factor?

My concern is that, although fixing bugs in GFP_ATOMIC allocations is 
certainly very good, I can't help wondering why the system does not keep a 
bit more memory in reserve instead of using everything up for relatively 
silly things like cache and buffers.
What if during an rsync I plug in some USB device whose driver has some 
valid GFP_ATOMIC allocations? Shouldn't the memory manager allow for such 
situations?

Cheers,
FJP

> tty: Keep the default buffering to sub-page units
>
> We allocate during interrupts so while our buffering is normally diced
> up small anyway on some hardware at speed we can pressure the VM
> excessively for page pairs. We don't really need big buffers to be
> linear so don't try so hard.
>
> In order to make this work well we will tidy up excess callers to
> request_room, which cannot itself enforce this break up.
>
> [mel@csn.ul.ie: Adjust TTY_BUFFER_PAGE to take padding into account]
> Signed-off-by: Alan Cox <alan@linux.intel.com>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Tested-by: Frans Pop <fjp@planet.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
