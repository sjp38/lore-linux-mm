Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5176D6B0005
	for <linux-mm@kvack.org>; Sun, 29 Apr 2018 16:30:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f19so6375890pfn.6
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 13:30:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q8-v6si5339987pgf.293.2018.04.29.13.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 29 Apr 2018 13:30:29 -0700 (PDT)
Date: Sun, 29 Apr 2018 13:30:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180429203023.GA11891@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien>
 <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien>
 <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien>
 <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Sun, Apr 29, 2018 at 09:59:27AM -0700, Kees Cook wrote:
> Did this ever happen?

Not yet.  I brought it up at LSFMM, and I'll repost the patches soon.

> I'd also like to see kmalloc_array_3d() or
> something that takes three size arguments. We have a lot of this
> pattern too:
> 
> kmalloc(sizeof(foo) * A * B, gfp...)
> 
> And we could turn that into:
> 
> kmalloc_array_3d(sizeof(foo), A, B, gfp...)

Are either of A or B constant?  Because if so, we could just use
kmalloc_array.  If not, then kmalloc_array_3d becomes a little more
expensive than kmalloc_array because we have to do a divide at runtime
instead of compile-time.  that's still better than allocating too few
bytes, of course.

I'm wondering how far down the abc + ab + ac + bc + d rabbit-hole we're
going to end up going.  As far as we have to, I guess.
