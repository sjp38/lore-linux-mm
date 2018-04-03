Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 413516B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:20:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u5so1492714wrc.23
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:20:54 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id j100si2044701wrj.71.2018.04.03.06.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 06:20:52 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20180403131025.GF5832@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <152275879566.32747.9293394837417347482@mail.alporthouse.com>
 <20180403131025.GF5832@bombadil.infradead.org>
Message-ID: <152276164305.32747.4969221700358143640@mail.alporthouse.com>
Subject: Re: Signal handling in a page fault handler
Date: Tue, 03 Apr 2018 14:20:43 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

Quoting Matthew Wilcox (2018-04-03 14:10:25)
> On Tue, Apr 03, 2018 at 01:33:15PM +0100, Chris Wilson wrote:
> > Quoting Matthew Wilcox (2018-04-02 15:10:58)
> > > I don't think the graphics drivers really want to be interrupted by
> > > any signal.
> > =

> > Assume the worst case and we may block for 10s. Even a 10ms delay may be
> > unacceptable to some signal handlers (one presumes). For the number one
> > ^C usecase, yes that may be reduced to only bother if it's killable, but
> > I wonder if there are not timing loops (e.g. sigitimer in Xorg < 1.19)
> > that want to be able to interrupt random blockages.
> =

> Ah, setitimer / SIGALRM.  So what do we want to have happen if that
> signal handler touches the mmaped device memory?

Burn in a great ball of fire :) Isn't that what usually happens if you
do anything in a signal handler?

Hmm, if SIGBUS has a handler does that count as a killable signal? The
ddx does have code to service SIGBUS emitted when accessing the mmapped
pointer that may result from the page insertion failing with no memory
(or other random error). There we stop accessing via the pointer and
use another indirect method.
-Chris
