Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j3SFQM4I718170
	for <linux-mm@kvack.org>; Thu, 28 Apr 2005 11:26:29 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3SFQLYQ365658
	for <linux-mm@kvack.org>; Thu, 28 Apr 2005 09:26:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j3SFQLRv005264
	for <linux-mm@kvack.org>; Thu, 28 Apr 2005 09:26:21 -0600
Subject: Re: [PATCH] drop_buffers() shouldn't de-ref page->mapping if its
	NULL
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <87k6mn5zs6.fsf@devron.myhome.or.jp>
References: <1114645113.26913.662.camel@dyn318077bld.beaverton.ibm.com>
	 <1114646015.26913.668.camel@dyn318077bld.beaverton.ibm.com>
	 <87k6mn5zs6.fsf@devron.myhome.or.jp>
Content-Type: text/plain
Message-Id: <1114701153.26913.679.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 28 Apr 2005 08:12:34 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, skodati@in.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-04-27 at 20:46, OGAWA Hirofumi wrote:
> Badari Pulavarty <pbadari@us.ibm.com> writes:
> 
> > Hi,
> >
> > I answered my own question. It looks like we could have pages
> > with buffers without page->mapping. In such cases, we shouldn't
> > de-ref page->mapping in drop_buffers(). Here is the trivial
> > patch to fix it.
> >
> > Thanks,
> > Badari
> 
> [...]
> 
> >
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > --- linux-2.6.12-rc2.org/fs/buffer.c	2005-04-27 07:19:44.000000000 -0700
> > +++ linux-2.6.12-rc2/fs/buffer.c	2005-04-27 07:20:34.000000000 -0700
> > @@ -2917,7 +2917,7 @@ drop_buffers(struct page *page, struct b
> >  
> >  	bh = head;
> >  	do {
> > -		if (buffer_write_io_error(bh))
> > +		if (buffer_write_io_error(bh) && page->mapping)
> >  			set_bit(AS_EIO, &page->mapping->flags);
> >  		if (buffer_busy(bh))
> >  			goto failed;
> 
> On my experience, this happened the bh leak case only.


Could you explain more on bh leak ? Is there one in the current code ?

> 
> If you are not sure whether this is valid state or not, I worry this
> patch hides real bug.  How about adding the warning, not just remove
> de-ref?

Andrew confirmed that this is a valid case.

I don't understand what you want to do here ? If the mapping is NULL,
we can't de-ref it.  Whats the point in putting a warning and de-refing
it. Its going to cause NULL pointer de-ref anyway.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
