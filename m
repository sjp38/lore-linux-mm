Subject: Re: limit on number of kmapped pages
References: <Pine.LNX.3.96.1010123205643.7482A-100000@kanga.kvack.org>
From: David Wragg <dpw@doc.ic.ac.uk>
Date: 24 Jan 2001 10:09:22 +0000
In-Reply-To: "Benjamin C.R. LaHaise"'s message of "Tue, 23 Jan 2001 21:03:09 -0500 (EST)"
Message-ID: <y7r7l3ldzxp.fsf@sytry.doc.ic.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Benjamin C.R. LaHaise" <blah@kvack.org> writes:
> On 24 Jan 2001, David Wragg wrote:
> 
> > ebiederm@xmission.com (Eric W. Biederman) writes:
> > > Why do you need such a large buffer? 
> > 
> > ext2 doesn't guarantee sustained write bandwidth (in particular,
> > writing a page to an ext2 file can have a high latency due to reading
> > the block bitmap synchronously).  To deal with this I need at least a
> > 2MB buffer.
> 
> This is the wrong way of going about things -- you should probably insert
> the pages into the page cache and write them into the filesystem via
> writepage. 

I currently use prepare_write/commit_write, but I think writepage
would have the same issue: When ext2 allocates a block, and has to
allocate from a new block group, it may do a synchronous read of the
new block group bitmap.  So before the writepage (or whatever) that
causes this completes, it has to wait for the read to get picked by
the elevator, the seek for the read, etc.  By the time it gets back to
writing normally, I've buffered a couple of MB of data.

But I do have a workaround for the ext2 issue.

> That way the pages don't need to be mapped while being written
> out.

Point taken, though the kmap needed before prepare_write is much less
significant than the kmap I need to do before copying data into the
page.

> For incoming data from a network socket, making use of the
> data_ready callbacks and directly copying from the skbs in one pass with a
> kmap of only one page at a time.
>
> Maybe I'm guessing incorrect at what is being attempted, but kmap should
> be used sparingly and as briefly as possible.

I'm going to see if the one-page-kmapped approach makes a measurable
difference.

I'd still like to know what the basis for the current kmap limit
setting is.


David Wragg
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
