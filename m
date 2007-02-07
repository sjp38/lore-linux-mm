Date: Wed, 7 Feb 2007 15:56:15 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1 of 2] Implement generic block_page_mkwrite() functionality
In-Reply-To: <20070207144415.GN44411608@melbourne.sgi.com>
Message-ID: <Pine.LNX.4.64.0702071454250.32223@blonde.wat.veritas.com>
References: <20070207124922.GK44411608@melbourne.sgi.com>
 <Pine.LNX.4.64.0702071256530.25060@blonde.wat.veritas.com>
 <20070207144415.GN44411608@melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, David Chinner wrote:
> On Wed, Feb 07, 2007 at 01:00:28PM +0000, Hugh Dickins wrote:
> > 
> > I'm worried about concurrent truncation.  Isn't it the case that
> > i_mutex is held when prepare_write and commit_write are normally
> > called?  But not here when page_mkwrite is called.
> 
> I'm not holding i_mutex. I assumed that it was probably safe to do
> because we are likely to be reading the page off disk just before we
> call mkwrite and that has to be synchronised with truncate in some
> manner....

"assumed"..."probably"..."likely"..."just before"..."in some manner"
doesn't sound very safe, does it :-?

The well-established paths are almost safe against truncation (I insert
"almost" there because although we like to think they're entirely safe,
from time to time a hole is discovered, and Nick has been wrestling
with filling them for some while now).

But page_mkwrite is something new: so far, it's up to the implementor
(the filesystem) to work out how to guard against truncation.

> 
> So, do I need to grab the i_mutex here? Is that safe to do that in
> the middle of a page fault?

It's certainly easier to think about if you don't grab i_mutex there:
sys_msync used to take i_mutex within down_read of mmap_sem, but we
were quite happy to get rid of that, because usually it's down_read
of mmap_sem within i_mutex (page fault when writing from userspace
to file).  I can't at this moment put my finger on an actual deadlock
if you take i_mutex in page_mkwrite, but it feels wrong: hmm, if you
add another thread waiting to down_write the mmap_sem, I think you
would be able to deadlock.

You don't need to lock out all truncation, but you do need to lock
out truncation of the page in question.  Instead of your i_size
checks, check page->mapping isn't NULL after the lock_page?

But aside from the truncation issue, if prepare_write and commit_write
are always called with i_mutex held at present, I'm doubtful whether
you can provide a generic default page_mkwrite which calls them without.
Which would take us back to grabbing i_mutex within page_mkwrite.  Ugh.

> If we do race with a truncate and the
> page is now beyond EOF, what am I supposed to return?

Something negative.  Nothing presently reports the error code in
question, it just does SIGBUS; but it would be better for the
truncation case to avoid -ENOMEM and -ENOSPC, which could easily
have meanings here.  I don't see a good choice, so maybe -EINVAL.

> 
> I'm fishing for what I'm supposed to be doing here because there's
> zero implementations of this callout in the kernel and the comments
> in the code explaining the interface constraints are
> non-existant....

Well, you seem to be the first to implement it.  Hmm, that's not true,
David was: what magic saved him from addressing the truncation issue?

Don't be surprised if it turns out page_mkwrite needs more thought.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
