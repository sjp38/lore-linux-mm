Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB1C5F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 16:30:44 -0400 (EDT)
Date: Sun, 12 Apr 2009 21:31:07 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC][PATCH 8/9] vfs: Implement generic revoked file operations
Message-ID: <20090412203107.GH4394@shareable.org>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1prfj5qxp.fsf@fess.ebiederm.org> <20090412185659.GE4394@shareable.org> <m11vrxprk6.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m11vrxprk6.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> >> revoked_file_ops return 0 from reads (aka EOF). Tell poll the file is
> >> always ready for I/O and return -EIO from all other operations.
> >
> > I think read should return -EIO too.  If a program is reading from a
> > /proc file (say), and the thing it's reading suddenly disappears, EOF
> > gives the false impression that it's read to the end of formatted data
> > from that file and it can process the data as if it's complete, which
> > is wrong.
> 
> Good point EIO is the current read return value for a removed proc file.
> 
> For closed pipes, and hung up ttys the read return value is 0, and from
> my reading that is what bsd returns after a sys_revoke.

A few suggestions below.  Feel free to ignore them on account of the
basic revoking functionality being more important :-)

I'm not sure a revoked pipe should look like a normally closed one.
ECONNRESET?

For hung up ttys, I agree.  But where's the SIGHUP :-) You probably do
want the process using it to die if it's not handling SIGHUP, because
terminal-using processes don't always terminate themselves on EOF.

For things writing to a pipe or file, SIGPIPE may be appropriate in
addition to EIO, to avoid runaway processes.  Looks odd I know.  For
writing to a terminal, SIGHUP again.

> The reason I have f_op settable is because I never expected complete
> agreement on the return codes, and because it makes auditing and spotting
> this kind of thing easier.
>
> I guess I should make two variations on revoked_file_ops then.  Say
> eof_file_ops, eio_file_ops.  Identical except for their treatment of
> reads.

Fair enough.  It's good to have good defaults.  I'm not convinced
eof_file_ops is ever a good default.  sighup_file_ops and
sigpipe_file_ops maybe :-)

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
