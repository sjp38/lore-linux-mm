Subject: Re: msync() behaviour broken for MS_ASYNC, revert patch?
From: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <Pine.LNX.4.58.0403311433240.1116@ppc970.osdl.org>
References: <1080771361.1991.73.camel@sisko.scot.redhat.com>
	 <Pine.LNX.4.58.0403311433240.1116@ppc970.osdl.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1080776487.1991.113.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Date: 01 Apr 2004 00:41:27 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ulrich Drepper <drepper@redhat.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 2004-03-31 at 23:37, Linus Torvalds wrote:
> On Wed, 31 Mar 2004, Stephen C. Tweedie wrote:
> >         
> > although I can't find an unambiguous definition of "queued for service"
> > in the online standard.  I'm reading it as requiring that the I/O has
> > reached the block device layer, not simply that it has been marked dirty
> > for some future writeback pass to catch; Uli agrees with that
> > interpretation.
> 
> That interpretation makes pretty much zero sense.
> 
> If you care about the data hitting the disk, you have to use fsync() or 
> similar _anyway_, and pretending anything else is just bogus.

You can make the same argument for either implementation of MS_ASYNC. 
And there's at least one way in which the "submit IO now" version can be
used meaningfully --- if you've got several specific areas of data in
one or more mappings that need flushed to disk, you'd be able to
initiate IO with multiple MS_ASYNC calls and then wait for completion
with either MS_SYNC or fsync().  That gives you an interface that
corresponds somewhat with the region-based filemap_sync();
filemap_fdatawrite(); filemap_datawait() that the kernel itself uses.  

> Having the requirement that it is on some sw-only request queue is
> nonsensical, since such a queue is totally invisible from a user
> perspective.

It's very much visible, just from a performance perspective, if you want
to support "kick off this IO, I'm going to wait for the completion
shortly."  If that's the interpretation of MS_ASYNC, then the app is
basically saying it doesn't want the writeback mechanism to be idle
until the writes have completed, regardless of whether it's a block
device or an NFS file or whatever underneath.

But whether that's a legal use of MS_ASYNC really depends on what the
standard is requiring.  I could be persuaded either way.  Uli?

Does anyone know what other Unixen do here?

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
