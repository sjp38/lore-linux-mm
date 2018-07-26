Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0276B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:32:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so1855528pll.22
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:32:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g13-v6si1768282plo.153.2018.07.26.12.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 12:32:06 -0700 (PDT)
Date: Thu, 26 Jul 2018 12:32:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180726193203.GA12992@bombadil.infradead.org>
References: <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
 <20180723140150.GA31843@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231531240.2545@eggly.anvils>
 <20180723225454.GC18236@bombadil.infradead.org>
 <alpine.LSU.2.11.1807240121590.1105@eggly.anvils>
 <alpine.LSU.2.11.1807252334420.1212@eggly.anvils>
 <20180726143353.GA27612@bombadil.infradead.org>
 <alpine.LSU.2.11.1807260936040.1101@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1807260936040.1101@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Thu, Jul 26, 2018 at 09:40:20AM -0700, Hugh Dickins wrote:
> On Thu, 26 Jul 2018, Matthew Wilcox wrote:
> > On Wed, Jul 25, 2018 at 11:53:15PM -0700, Hugh Dickins wrote:
> > 
> > and fixing the bug differently ;-)  But many thanks for spotting it!
> 
> I thought you might :)

The xas_* functions are all _expected_ to behave the same way when
passed an XA_STATE containing an error -- do nothing.  xas_create_range()
behaved that way initially, then I fixed a bug and broke that invariant.
Now the test suite checks it so I won't break it again.

> > I'll look into the next bug you reported ...
> 
> No need: that idea now works a lot better when I use the initialized
> "start", instead of the uninitialized "index".

Ugh.  xas_create_range() is _supposed_ to return with xas pointing to
the first index in the range.  I wonder what I messed up.  I've had a
go at producing a test-case for this and haven't provoked a bug yet.

Still, I don't want to keep xas_create_range() around long-term.
I want to transition all the places that currently use it to use
multi-index entries.  So I'm going to put your workaround in and then
work on deleting xas_create_range() altogether.

Thanks so much for all your work on this!
