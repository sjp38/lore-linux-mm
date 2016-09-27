Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33D146B029A
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 03:31:01 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 92so19822971iom.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 00:31:01 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u185si1492576itc.12.2016.09.27.00.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 00:31:00 -0700 (PDT)
Date: Tue, 27 Sep 2016 09:30:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927073055.GM2794@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 26, 2016 at 01:58:00PM -0700, Linus Torvalds wrote:

> Why is the page_waitqueue() handling so expensive? Let me count the ways:

>  (b) It's cache miss heaven. It takes a cache miss on three different
> things:looking up the zone 'wait_table', then looking up the hash
> queue there, and finally (inside __wake_up_bit) looking up the wait
> queue itself (which will effectively always be NULL).

> Is there really any reason for that incredible indirection? Do we
> really want to make the page_waitqueue() be a per-zone thing at all?
> Especially since all those wait-queues won't even be *used* unless
> there is actual IO going on and people are really getting into
> contention on the page lock.. Why isn't the page_waitqueue() just one
> statically sized array?

I suspect the reason is to have per node hash tables, just like we get
per node page-frame arrays with sparsemem.

> Also, if those bitlock ops had a different bit that showed contention,
> we could actually skip *all* of this, and just see that "oh, nobody is
> waiting on this page anyway, so there's no point in looking up those
> wait queues". We don't have that many "__wait_on_bit()" users, maybe
> we could say that the bitlocks do have to haev *two* bits: one for the
> lock bit itself, and one for "there is contention".

That would be fairly simple to implement, the difficulty would be
actually getting a page-flag to use for this. We're running pretty low
in available bits :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
