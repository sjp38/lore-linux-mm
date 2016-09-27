Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14FD9280280
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 05:11:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b71so12835309lfg.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 02:11:23 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id u7si634672lja.18.2016.09.27.02.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 02:11:21 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id g62so15459295lfe.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 02:11:21 -0700 (PDT)
Date: Tue, 27 Sep 2016 12:11:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927091117.GA23640@node.shutemov.name>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
 <20160927085412.GD2838@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927085412.GD2838@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:
> On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > > Also, if those bitlock ops had a different bit that showed contention,
> > > we could actually skip *all* of this, and just see that "oh, nobody is
> > > waiting on this page anyway, so there's no point in looking up those
> > > wait queues". We don't have that many "__wait_on_bit()" users, maybe
> > > we could say that the bitlocks do have to haev *two* bits: one for the
> > > lock bit itself, and one for "there is contention".
> > 
> > That would be fairly simple to implement, the difficulty would be
> > actually getting a page-flag to use for this. We're running pretty low
> > in available bits :/
> 
> Simple is relative unless I drastically overcomplicated things and it
> wouldn't be the first time. 64-bit only side-steps the page flag issue
> as long as we can live with that.

Looks like we don't ever lock slab pages. Unless I miss something.

We can try to use PG_locked + PG_slab to indicate contation.

I tried to boot kernel with CONFIG_SLUB + BUG_ON(PageSlab()) in
trylock/unlock_page() codepath. Works fine, but more inspection is
required.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
