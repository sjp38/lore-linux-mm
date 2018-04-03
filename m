Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2BE6B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 10:48:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u7-v6so6438448plr.13
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 07:48:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1-v6si3043910pld.412.2018.04.03.07.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 07:48:32 -0700 (PDT)
Date: Tue, 3 Apr 2018 07:48:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Signal handling in a page fault handler
Message-ID: <20180403144829.GB28565@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <152275879566.32747.9293394837417347482@mail.alporthouse.com>
 <e10f5e18-299b-57fd-4ba7-800caa1a105d@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e10f5e18-299b-57fd-4ba7-800caa1a105d@shipmail.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Hellstrom <thomas@shipmail.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Apr 03, 2018 at 03:12:35PM +0200, Thomas Hellstrom wrote:
> I think the TTM page fault handler originally set the standard for this.
> First, IMO any critical section that waits for the GPU (like typically the
> page fault handler does), should be locked at least killable. The need for
> interruptible locks came from the X server's silken mouse relying on signals
> for smooth mouse operations: You didn't want the X server to be stuck in the
> kernel waiting for GPU completion when it should handle the cursor move
> request.. Now that doesn't seem to be the case anymore but to reiterate
> Chris' question, why would the signal persist once returned to user-space?

Yeah, you graphics people have had to deal with much more recalcitrant
hardware than most of the rest of us ... and less reasonable user
expectations ("My graphics card was doing something and I expected
everything else to keep going" vs "My hard drive died and my kernel
paniced, oh well.")

I don't know exactly how the signal code works at the delivery end;
I'm not sure when TIF_SIGPENDING gets cleared.  I just get concerned
when I see one bit of kernel code doing things in a very complicated
and careful manner and another bit of kernel code blithely assuming
that everything's going to be OK.
