Date: Fri, 9 Jun 2000 22:58:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: O_SYNC patches for 2.4.0-test1-ac11
Message-ID: <20000609225802.I2621@redhat.com>
References: <20000609223632.E2621@redhat.com> <m3ya4ettbk.fsf@otr.mynet.cygnus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m3ya4ettbk.fsf@otr.mynet.cygnus.com>; from drepper@redhat.com on Fri, Jun 09, 2000 at 02:53:19PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@cygnus.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Theodore Ts'o <tytso@valinux.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 09, 2000 at 02:53:19PM -0700, Ulrich Drepper wrote:
> 
> > If I don't preallocate the file, then even fdatasync is slow, [...]
> 
> This might be a good argument to implement posix_fallocate() in the
> kernel.

No.  If we do posix_fallocate(), then there are only two choices:
we either pre-zero the file contents (in which case we are as well
doing it from user space), or we record in the inode that the file
isn't pre-zeroed and so optimise things.

If we do that optimisation, then doing an O_DSYNC write to the 
already-allocated file will have to record in the inode that we are
pushing forward the non-prezeroed fencepost in the file, so we end
up having to seek back to the inode for each write anyway, so we
lose any possible benefit during the writes.

Once you have a database file written and preallocated, this is all
academic since all further writes will be in place and so will be 
fast the th O_DSYNC/fdatasync support.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
