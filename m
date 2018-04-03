Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD0156B0010
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 11:12:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e82so3645991wmc.3
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 08:12:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f13sor1643510edn.35.2018.04.03.08.12.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 08:12:23 -0700 (PDT)
Date: Tue, 3 Apr 2018 17:12:20 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: Signal handling in a page fault handler
Message-ID: <20180403151220.GW3881@phenom.ffwll.local>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <152275879566.32747.9293394837417347482@mail.alporthouse.com>
 <e10f5e18-299b-57fd-4ba7-800caa1a105d@shipmail.org>
 <20180403144829.GB28565@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403144829.GB28565@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Thomas Hellstrom <thomas@shipmail.org>, Chris Wilson <chris@chris-wilson.co.uk>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Apr 03, 2018 at 07:48:29AM -0700, Matthew Wilcox wrote:
> On Tue, Apr 03, 2018 at 03:12:35PM +0200, Thomas Hellstrom wrote:
> > I think the TTM page fault handler originally set the standard for this.
> > First, IMO any critical section that waits for the GPU (like typically the
> > page fault handler does), should be locked at least killable. The need for
> > interruptible locks came from the X server's silken mouse relying on signals
> > for smooth mouse operations: You didn't want the X server to be stuck in the
> > kernel waiting for GPU completion when it should handle the cursor move
> > request.. Now that doesn't seem to be the case anymore but to reiterate
> > Chris' question, why would the signal persist once returned to user-space?
> 
> Yeah, you graphics people have had to deal with much more recalcitrant
> hardware than most of the rest of us ... and less reasonable user
> expectations ("My graphics card was doing something and I expected
> everything else to keep going" vs "My hard drive died and my kernel
> paniced, oh well.")
> 
> I don't know exactly how the signal code works at the delivery end;
> I'm not sure when TIF_SIGPENDING gets cleared.  I just get concerned
> when I see one bit of kernel code doing things in a very complicated
> and careful manner and another bit of kernel code blithely assuming
> that everything's going to be OK.

I think you last line pretty much sums up the proper attitude when writing
gpu drivers:

https://i.imgflip.com/27nm7w.jpg

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
