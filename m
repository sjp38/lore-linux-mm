Date: Tue, 7 Aug 2001 21:08:03 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Message-ID: <20010807210803.C2476@thunk.org>
References: <Pine.LNX.4.33.0108071251100.3977-100000@penguin.transmeta.com> <493160000.997215771@tiny>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <493160000.997215771@tiny>; from mason@suse.com on Tue, Aug 07, 2001 at 04:22:51PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 07, 2001 at 04:22:51PM -0400, Chris Mason wrote:
> 
> On Tuesday, August 07, 2001 12:52:11 PM -0700 Linus Torvalds
> <torvalds@transmeta.com> wrote:
> 
> > On Tue, 7 Aug 2001, Chris Mason wrote:
> >> 
> >> Linus seemed pretty sure kswapd wasn't deadlocked, but though I would
> >> mention this anyway....
> > 
> > The thing that Leonard seems able to repeat pretty well is just doing a
> > "mke2fs" on a big partition. I don't think xfs is involved there at all.
> 
> It depends, mke2fs could be just another GFP_NOFS process waiting around
> for kswapd to free buffers.  If a journaled filesystem is there, and it is
> locking up kswapd, any heavy buffer allocator could make the problem seem
> worse.

mke2fs is a completely different case.  That's just a simple write
throttling problem --- mke2fs simply is doing a lot of disk writes to
a block device very quickly (zeroing out the inode table).  The kernel
shouldn't be allowing a user process to dirty so many buffers that VM
starts getting f*cked --- in the past mke2fs could actually cause the
OOM to start randomly killing processes.

There's a workaround which causes the problem to go away; if you
export the MKE2FS_SYNC environment variable and set it to a small
value (say, 5 or 10), then every 5 or 10 block groups, mke2fs will
call sync(), and this effectively acts as a write throttler.

I had considered making this the default, but this is such a great way
of demonstrating that a kernel has a write throttling problem that I
haven't done so, since it's effectively hiding a kernel VM bug.
(Simply writing to a block device shouldn't cause the OOM to trigger;
and since mke2fs is just doing block device writes, it's not a
GFP_NOFS case.)

(We seem to have a habit of repeatedly breaking write throttling; it
was broken for a while in 2.2, then it got fixed, then someone wanted
to "fix" the VM, and they would break write throttling again... and
again... and again....)

							- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
