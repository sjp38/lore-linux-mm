Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1D416B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:48:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o33-v6so7733837plb.16
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:48:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q124si2022886pgq.215.2018.04.03.06.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 06:48:55 -0700 (PDT)
Date: Tue, 3 Apr 2018 06:48:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Signal handling in a page fault handler
Message-ID: <20180403134854.GA28565@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <152275879566.32747.9293394837417347482@mail.alporthouse.com>
 <20180403131025.GF5832@bombadil.infradead.org>
 <152276164305.32747.4969221700358143640@mail.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152276164305.32747.4969221700358143640@mail.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Apr 03, 2018 at 02:20:43PM +0100, Chris Wilson wrote:
> Quoting Matthew Wilcox (2018-04-03 14:10:25)
> > On Tue, Apr 03, 2018 at 01:33:15PM +0100, Chris Wilson wrote:
> > > Quoting Matthew Wilcox (2018-04-02 15:10:58)
> > > > I don't think the graphics drivers really want to be interrupted by
> > > > any signal.
> > > 
> > > Assume the worst case and we may block for 10s. Even a 10ms delay may be
> > > unacceptable to some signal handlers (one presumes). For the number one
> > > ^C usecase, yes that may be reduced to only bother if it's killable, but
> > > I wonder if there are not timing loops (e.g. sigitimer in Xorg < 1.19)
> > > that want to be able to interrupt random blockages.
> > 
> > Ah, setitimer / SIGALRM.  So what do we want to have happen if that
> > signal handler touches the mmaped device memory?
> 
> Burn in a great ball of fire :) Isn't that what usually happens if you
> do anything in a signal handler?

I don't know.  My mummy and daddy don't let me play with sharp things
like signals.

> Hmm, if SIGBUS has a handler does that count as a killable signal? The
> ddx does have code to service SIGBUS emitted when accessing the mmapped
> pointer that may result from the page insertion failing with no memory
> (or other random error). There we stop accessing via the pointer and
> use another indirect method.

Any signal with a handler is non-fatal, and so a call to
mutex_lock_killable() would not return if SIGBUS was delivered to a thread
blocking in a page fault.  mutex_lock_interruptible() would return -EINTR.
