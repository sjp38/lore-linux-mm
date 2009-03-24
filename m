Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEAD6B0055
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 13:20:58 -0400 (EDT)
Date: Tue, 24 Mar 2009 18:35:11 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090324173511.GJ23439@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903250130.02485.nickpiggin@yahoo.com.au> <20090324144709.GF23439@duck.suse.cz> <200903250203.55520.nickpiggin@yahoo.com.au> <20090324154813.GH23439@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324154813.GH23439@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jan Kara <jack@suse.cz>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue 24-03-09 16:48:14, Jan Kara wrote:
> On Wed 25-03-09 02:03:54, Nick Piggin wrote:
> > On Wednesday 25 March 2009 01:47:09 Jan Kara wrote:
> > > On Wed 25-03-09 01:30:00, Nick Piggin wrote:
> > 
> > > > I don't think it is a very good idea for block_write_full_page recovery
> > > > to do clear_buffer_dirty for !mapped buffers. I think that should rather
> > > > be a redirty_page_for_writepage in the case that the buffer is dirty.
> > > >
> > > > Perhaps not the cleanest way to solve the problem if it is just due to
> > > > transient shortage of space in ext3, but generic code shouldn't be
> > > > allowed to throw away dirty data even if it can't be written back due
> > > > to some software or hardware error.
> > >
> > >   Well, that would be one possibility. But then we'd be left with dirty
> > > pages we cannot ever release since they are constantly dirty (when the
> > > filesystem really becomes out of space). So what I
> > 
> > If the filesystem becomes out of space and we have over-committed these
> > dirty mmapped blocks, then we most definitely want to keep them around.
> > An error of the system losing a few pages (or if it happens an insanely
> > large number of times, then slowly dying due to memory leak) is better
> > than an app suddenly seeing the contents of the page change to nulls
> > under it when the kernel decides to do some page reclaim.
>   Hmm, probably you're right. Definitely it would be much easier to track
> the problem down than it is now... Thinking a bit more... But couldn't a
> malicious user bring the machine easily to OOM this way? That would be
> unfortunate.
  OK, below is the patch which makes things work for me (i.e. no data
lost). What do you think?

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
