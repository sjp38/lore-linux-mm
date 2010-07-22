Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E903D6B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 10:14:49 -0400 (EDT)
Date: Thu, 22 Jul 2010 10:14:37 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100722141437.GA14882@thunk.org>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 07:45:10PM -0700, David Rientjes wrote:
> The kzalloc() in start_this_handle() is failable, so remove __GFP_NOFAIL
> from its mask.

Unfortunately, while there is error handling in start_this_handle(),
there isn't in all of the callers of start_this_handle(), which is why
the __GFP_NOFAIL is there.  At the moment, if we get an ENOMEM in the
delayed writeback code paths, for example, it's a disaster; user data
can get lost, as a result.

I could add retry code in the places where we really can't fail, and
reflect the change back up to the userspace code everywhere else, but
that will take a while to do, and even then it means that any VFS
syscall (chmod, unlink, rmdir, mkdir, read, close, etc.) would now
potentially return ENOMEM.  And we know how often application
programmers do error checking....

But until we fix up all of the callers of jbd2_journal_start() and
jbd2_journal_restart(), I'd prefer keep this __GFP_NOFAIL in place,
thanks.

						- Ted

P.S.  There may also be some places where we haven't taken locks yet,
and so it might be safe in a few locations to omit the GFP_NOFS flag.
That would mean adding a new version of jbd2_journal_start() which can
take a gfp_mask, but the net result would be a file system that would
be a little bit more of a "good citizen" as far as allowing memory
reclaim.  I am worried about reflecting ENOMEM errors back up to
userspace, though, since I'm painfully aware of how much crappy
userspace code is out there.  What might be nice is a
"__GFP_RETRY_HARDER" which is weaker form of __GFP_NOFAIL...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
