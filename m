Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55E3D6006B4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 15:52:55 -0400 (EDT)
Date: Fri, 23 Jul 2010 15:52:40 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100723195240.GG1256@thunk.org>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
 <20100722141437.GA14882@thunk.org>
 <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
 <20100722230935.GB16373@thunk.org>
 <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
 <20100723141054.GE13090@thunk.org>
 <20100723145730.GD3305@quack.suse.cz>
 <20100723150543.GG13090@thunk.org>
 <alpine.DEB.2.00.1007231240180.5317@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007231240180.5317@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 12:40:50PM -0700, David Rientjes wrote:
> On Fri, 23 Jul 2010, Ted Ts'o wrote:
> 
> > __GFP_NOFAIL is going away, so add our own retry loop.  Also add
> > jbd2__journal_start() and jbd2__journal_restart() which take a gfp
> > mask, so that file systems can optionally (re)start transaction
> > handles using GFP_KERNEL.  If they do this, then they need to be
> > prepared to handle receiving an PTR_ERR(-ENOMEM) error, and be ready
> > to reflect that error up to userspace.
> > 
> > Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Will you be pushing the equivalent patch for jbd?

I imagine Jan (as the person who has been primarily handling ext3
patches) is waiting to see how invasive the patches are to ext4 before
deciding whether he's willing backport the equivalent changes to ext3
so that some of the calls that end up calling start_this_handle() end
up passing GFP_KERNEL when it's OK for them to fail --- since ext3 is
in maintenance mode, so we tend not to backport the more disruptive
patches to ext3.  It's really a cost/benefit tradeoff, really.

I am certain that some application programmers will complain when
their programs start breaking because they're not prepared to handle
an ENOMEM failure from certain system calls that have never failed
that way before.  (I should introduce you to some Japanese enterprise
programmers who believe that if a system call ever starts returning an
error code not documented in a Linux manpage, it's a ABI compatibility
bug.  They're on crack, of course, but it's been hard convincing them
that it's their fault for writing brittle/fragile applications.)

So I could imagine that Jan and some of the enterprise distributions
that are shipping ext3 might not want this change, given the "better
the devil you know (random lockups in the case of extreme memory
pressure)" is better than the devil you don't (more system calls might
return ENOMEM, with undetermined application impacts, in the case of
extreme memory pressure).  So in the jbd layer, they might want to
simply unconditionally loop, so it would be bug-for-bug compatible
with existing ext3 behavior.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
