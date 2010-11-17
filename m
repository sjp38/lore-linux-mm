Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10FEB8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:12:23 -0500 (EST)
Date: Thu, 18 Nov 2010 10:11:43 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101117231143.GQ22876@dastard>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 02:05:30PM -0800, Michel Lespinasse wrote:
> On Wed, Nov 17, 2010 at 7:28 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Wed, 2010-11-17 at 23:57 +1100, Nick Piggin wrote:
> >> On Wed, Nov 17, 2010 at 04:23:58AM -0800, Michel Lespinasse wrote:
> >> > When faulting in pages for mlock(), we want to break COW for anonymous
> >> > or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
> >> > no need to write-fault into VM_SHARED vmas since shared file pages can
> >> > be mlocked first and dirtied later, when/if they actually get written to.
> >> > Skipping the write fault is desirable, as we don't want to unnecessarily
> >> > cause these pages to be dirtied and queued for writeback.
> >>
> >> It's not just to break COW, but to do block allocation and such
> >> (filesystem's page_mkwrite op). That needs to at least be explained
> >> in the changelog.
> >
> > Agreed, the 0/3 description actually does mention this.
> >
> >> Filesystem doesn't have a good way to fully pin required things
> >> according to mlock, but page_mkwrite provides some reasonable things
> >> (like block allocation / reservation).
> >
> > Right, but marking all pages dirty isn't really sane. I can imagine
> > making the reservation but not marking things dirty solution, although
> > it might be lots harder to implement, esp since some filesystems don't
> > actually have a page_mkwrite() implementation.
> 
> Really, my understanding is that not pre-allocating filesystem blocks
> is just fine. This is, after all, what happens with ext3 and it's
> never been reported as a bug (that I know of).

It's not ext3 you have to worry about - it's the filesystems that
need special state set up on their pages/buffers for ->writepage to
work correctly that are the problem. You need to call
->write_begin/->write_end to get the state set up properly.

If this state is not set up properly, silent data loss will occur
during mmap writes either by ENOSPC or failing to set up writes into
unwritten extents correctly (i.e. we'll be back to where we were in
2.6.15).

I don't think ->page_mkwrite can be worked around - we need that to
be called on the first write fault of any mmap()d page to ensure it
is set up correctly for writeback.  If we don't get write faults
after the page is mlock()d, then we need the ->page_mkwrite() call
during the mlock() call.

> If filesystem people's feedback is that they really want mlock() to
> continue pre-allocating blocks, maybe we can just do it using
> fallocate() rather than page_mkwrite() callbacks ?

Fallocate is not good enough to avoid ->page_mkwrite callbacks.
Indeed, XFS (at least) requires the ->page_mkwrite() callout even
on preallocated space to correctly mark the buffers as unwritten so
extent conversion in ->writepage is triggered correctly (see test
#166 in xfstests).

Hence I think that avoiding ->page_mkwrite callouts is likely to
break some filesystems in subtle, undetected ways.  IMO, regardless
of what is done, it would be really good to start by writing a new
regression test to exercise and encode the expected the mlock
behaviour so we can detect regressions later on....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
