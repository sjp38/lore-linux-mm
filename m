Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 832C26B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:52:29 -0400 (EDT)
Message-ID: <1343746344.8473.4.camel@dabdike.int.hansenpartnership.com>
Subject: Re: Any reason to use put_page in slub.c?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 31 Jul 2012 15:52:24 +0100
In-Reply-To: <alpine.DEB.2.00.1207310927420.32295@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com>
	 <alpine.DEB.2.00.1207271054230.18371@router.home>
	 <50163D94.5050607@parallels.com>
	 <alpine.DEB.2.00.1207301421150.27584@router.home>
	 <5017968C.6050301@parallels.com>
	 <alpine.DEB.2.00.1207310906350.32295@router.home>
	 <5017E72D.2060303@parallels.com>
	 <alpine.DEB.2.00.1207310915150.32295@router.home>
	 <5017E929.70602@parallels.com>
	 <alpine.DEB.2.00.1207310927420.32295@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2012-07-31 at 09:31 -0500, Christoph Lameter wrote:
> On Tue, 31 Jul 2012, Glauber Costa wrote:
> 
> > On 07/31/2012 06:17 PM, Christoph Lameter wrote:
> > > On Tue, 31 Jul 2012, Glauber Costa wrote:
> > >
> > >> On 07/31/2012 06:09 PM, Christoph Lameter wrote:
> > >>> That is understood. Typically these object where page sized though and
> > >>> various assumptions (pretty dangerous ones as you are finding out) are
> > >>> made regarding object reuse. The fallback of SLUB for higher order allocs
> > >>> to the page allocator avoids these problems for higher order pages.
> > >> omg...
> > >
> > > I would be very thankful if you would go through the tree and check for
> > > any remaining use cases like that. Would take care of your problem.
> >
> > I would be happy to do it. Do you have any example of any user that
> > behaved like this in the past, so I can search for something similar?
> >
> > This can potentially take many forms, and auditing every kfree out there
> > is not humanly possible. The best I can do is to search for known
> > patterns here...
> 
> The basic problem is that someone will take the address of an object that
> is allocated via slab and then access the page struct to increase the page
> count.
> 
> So you would see
> 
> page = virt_to_page(<slab_object>);
> 
> get_page(page);
> 
> 
> The main cuprit in the past has been the DMA code in the SCSI layer. I
> think it was the first 512 byte control block for the device that was the
> main issue. There was a discussion betwen Hugh Dickins and me when SLUB
> was first released about this issue and it resulted in some changes so
> that certain fields in the page struct were not touched by SLUB since they
> were needed for I/O.

Hey, don't try to pin this on me.  We don't use get_page() at all on the
ordinary DMA route.  There are four get_page() calls in the whole of
drivers/scsi.  One is in the sg.c fault path, which looks genuine.  The
other three are in fcoe and iSCSI ... what they're trying to do is to
ensure that the page hangs around until the device sees the data in a
network tx path.

I can't see why any of these pages would come from kmalloc() or any
other slab object since they should all be user pages.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
