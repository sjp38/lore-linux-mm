Date: Thu, 26 Jul 2007 14:23:30 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070726122330.GA21750@one.firstfloor.org>
References: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu> <20070726102025.GJ27237@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070726102025.GJ27237@ftp.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> BTW, I really wonder how much pain could be avoided if updatedb recorded
> mtime of directories and checked it.  I.e. instead of just doing blind
> find(1), walk the stored directory tree comparing timestamps with those
> in filesystem.  If directory mtime has not changed, don't bother rereading
> it and just go for (stored) subdirectories.  If it has changed - reread the
> sucker.  If we have a match for stored subdirectory of changed directory,
> check inumber; if it doesn't match, consider the entire subtree as new
> one.  AFAICS, that could eliminate quite a bit of IO...

That would just save reading the directories. Not sure
it helps that much. Much better would be actually if it didn't stat the 
individual files (and force their dentries/inodes in). I bet it does that to 
find out if they are directories or not. But in a modern system it could just 
check the type in the dirent on file systems that support 
that and not do a stat. Then you would get much less dentries/inodes.

Also I expect in general the new slub dcache freeing that is pending
will improve things a lot.

But even if updatedb was fixed to be more efficient we probably
still need a general solution for other tree walking programs
that cannot be optimized this way.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
