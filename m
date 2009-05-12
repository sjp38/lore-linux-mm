Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC696B008C
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:45:34 -0400 (EDT)
Date: Tue, 12 May 2009 11:45:53 -0300
From: Mauro Carvalho Chehab <mchehab@infradead.org>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V3
Message-ID: <20090512114553.48e19188@pedra.chehab.org>
In-Reply-To: <aec7e5c30905120630k7cbc245dh211dbd0472928a2d@mail.gmail.com>
References: <20090508085310.31326.38083.sendpatchset@rx1.opensource.se>
	<20090508130658.813e29c1.akpm@linux-foundation.org>
	<20090511103651.49d852f8@pedra.chehab.org>
	<aec7e5c30905120630k7cbc245dh211dbd0472928a2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Em Tue, 12 May 2009 22:30:37 +0900
Magnus Damm <magnus.damm@gmail.com> escreveu:


> >> What does it do, how does it do it and why does it do it?
> >
> > A good documentation is a really good idea here. There videobuf internals are
> > very complex. A good documentation for it is very important to keep it updated.
> 
> I've just posted a little patch that adds function descriptions,
> hopefully that is one step in the right direction.

Good!

I started a documentation of videobuf KABI at:
	~/tokernel/wrk/linus/Documentation/video4linux/v4l2-framework.txt 

For now, it covers only the common code (offering a view for driver writers,
not for videobuf writers), but I think we can extend it (or create a separate
doc) with internal details. In the future, we should consider converting it to
docbook and produce a complete V4L2 KABI doc.

Feel free to add some notes there.

> > I would also suggest if you could also take a look at videobuf-vmalloc and implement a
> > similar method to provide USERPTR. The vmalloc flavor can easily be tested with
> > the virtual (vivi) video driver, so it helps people to better understand how
> > videobuf works. It will also help the USB drivers that use videobuf to use USERPTR.
> 
> Yeah, supporting USERPTR with vivi sounds like a good plan. I'm not
> sure how much work it involves though. The comment in the
> videobuf-vmalloc header says that the buffer code assumes that the
> driver does not touch the data, but I think that's exactly how vivi
> generates the frame data for us. =)

:)

The rationale for that comment is that we shouldn't reformat the received data
inside kernel (like doing format conversions), but, instead, let this task to
happen at userspace if needed. 

With PCI, this is very clear: it just fills the frame data via DMA, and adds the
corresponding meta-data to the videobuf structures at interrupt time. This is
possible, since DMA generates IRQ only after receiving a complete frame, so
meta-data can be added without troubles.

Although videobuf-vmalloc itself doesn't touch at the data (behaving just like
PCI videobuf's), this note is not quite true with the clients of
videobuf-vmalloc (vivi and the USB drivers), since:

1) all USB drivers I know use a small transport layer over USB to indicate
frame begin/end and eventually to multiplex with VBI and/or audio. So,
the usb drivers need to get rid of the USB transport layer, providing only the
stream data to userspace, and filling the meta-data based on the transport layer;

2) vivi produces the stream data.

> I need to figure out the best way to grab references to user space
> pages and map them virtually contiguous like vmalloc does. This will
> take a bit of time, so don't expect anything submitted in time for
> v2.6.31. I've put it fairly high on my TODO list.

Thanks!

> Thanks for your help!

Anytime.

Cheers,
Mauro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
