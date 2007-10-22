From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Mon, 22 Oct 2007 11:56:07 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710211956.50624.nickpiggin@yahoo.com.au> <m1d4v8b9ct.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1d4v8b9ct.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200710221156.07790.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 22 October 2007 04:39, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > On Sunday 21 October 2007 18:23, Eric W. Biederman wrote:
> >> Christian Borntraeger <borntraeger@de.ibm.com> writes:
> >>
> >> Let me put it another way.  Looking at /proc/slabinfo I can get
> >> 37 buffer_heads per page.  I can allocate 10% of memory in
> >> buffer_heads before we start to reclaim them.  So it requires just
> >> over 3.7 buffer_heads on very page of low memory to even trigger
> >> this case.  That is a large 1k filesystem or a weird sized partition,
> >> that we have written to directly.
> >
> > On a highmem machine it it could be relatively common.
>
> Possibly.  But the same proportions still hold.  1k filesystems
> are not the default these days and ramdisks are relatively uncommon.
> The memory quantities involved are all low mem.

You don't need 1K filesystems to have buffers attached though,
of course. You can hit the limit with a 4K filesystem with less
than 8GB in pagecache I'd say.



> > You don't want to change that for a stable patch, however.
> > It fixes the bug.
>
> No it avoids the bug which is something slightly different.
> Further I contend that it is not obviously correct that there
> are no other side effects (because it doesn't actually fix the
> bug), and that makes it of dubious value for a backport.

The bug in question isn't exactly that it uses buffercache for its
backing store (although that's obviously rather hairy as well). It's
this specific problem sequence. And it does fix the problem.


> If I had to slap a patch on there at this point just implementing
> an empty try_to_release_page (which disables try_to_free_buffers)
> would be my choice.

How is that better? Now you're making the exact same change for
all filesystems that you didn't think was obviously correct for
rd.c.


> > I just don't think what you have is the proper fix. Calling
> > into the core vfs and vm because right now it does something
> > that works for you but is completely unrelated to what you
> > are conceptually doing is not the right fix.
>
> I think there is a strong conceptual relation and other code
> doing largely the same thing is already in the kernel (ramfs).  Plus
> my gut feel says shared code will make maintenance easier.

ramfs is rather a different case. Filesystems intimately know
about the pagecache.


> You do have a point that the reuse may not be perfect and if that
> is the case we need to watch out for the potential to mess things
> up.
>
> So far I don't see any problems with the reuse.

It's just wrong. I guess if you don't see that by now, then we
have to just disagree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
