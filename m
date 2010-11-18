Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4FD66B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 06:03:13 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oAIB38qA007232
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:03:08 -0800
Received: from ywa6 (ywa6.prod.google.com [10.192.1.6])
	by wpaz9.hot.corp.google.com with ESMTP id oAIB37iA008059
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:03:07 -0800
Received: by ywa6 with SMTP id 6so2379585ywa.40
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:03:07 -0800 (PST)
Date: Thu, 18 Nov 2010 03:03:01 -0800
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101118110301.GA16625@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard>
 <20101117235230.GL3290@thunk.org>
 <20101117165309.fa859fd3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117165309.fa859fd3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ted Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 04:53:09PM -0800, Andrew Morton wrote:
> On Wed, 17 Nov 2010 18:52:30 -0500
> "Ted Ts'o" <tytso@mit.edu> wrote:
> 
> > On Thu, Nov 18, 2010 at 10:11:43AM +1100, Dave Chinner wrote:
> > > I don't think ->page_mkwrite can be worked around - we need that to
> > > be called on the first write fault of any mmap()d page to ensure it
> > > is set up correctly for writeback.  If we don't get write faults
> > > after the page is mlock()d, then we need the ->page_mkwrite() call
> > > during the mlock() call.
> > 
> > OK, so I'm not an mm hacker, so maybe I'm missing something.  Could
> > part of this be fixed by simply sending the write faults for
> > mlock()'ed pages, so page_mkwrite() gets called when the page is
> > dirtied.  Seems like a real waste to have the file system pre-allocate
> > all of the blocks for a mlock()'ed region.  Why does mlock() have to
> > result in the write faults getting suppressed when the page is
> > actually dirtied?

This is actually what the patch does - by having mlock() use a read fault,
pages are loaded in memory and mlocked, but the ptes are not marked as
writable so that a later write access will be caught as a write fault at
that time (with all the usual dirtying and page_mkwrite() callbacks).

> Yup, I don't think it would be too bad to take a minor fault each time
> an mlocked page transitions from clean->dirty.
> 
> In fact we should already be doing that, after the mlocked page gets
> written back by kupdate?  Hope so!

Yes, handle_mm_fault() is careful to never create writable ptes pointing
to clean file pages, so that a later write fault will correctly dirty
the corresponding page.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
