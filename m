Date: Sun, 28 Jan 2007 16:48:06 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128154806.GA10615@elte.hu>
References: <1169993494.10987.23.camel@lappy> <20070128144933.GD16552@infradead.org> <20070128151700.GA7644@elte.hu> <20070128152858.GA23410@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070128152858.GA23410@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

* Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jan 28, 2007 at 04:17:00PM +0100, Ingo Molnar wrote:
> > scalability. I did lock profiling on the -rt kernel, which exposes 
> > such things nicely. Half of the lock contention events during kernel 
> > compile were due to kmap(). (The system had 2 GB of RAM, so 40% 
> > lowmem, 60% highmem.)
> 
> Numbers please, and not on -rt but on mainline.  Please show the 
> profiles.

i'm sorry, but do you realize that files_lock is a global lock, 
triggered by /every single/ file close?

   " files_lock is a global lock and we touch it for every single
     sys_close() system call that the system does. "

You really dont need to be a rocket scientist to see that it's a 
globally bouncing cacheline that has a major effect on certain 
VFS-intense workloads. Peter has worked hard to eliminate its effects 
without having to couple this to an intrusive rewrite of the TTY layer.

( really, i personally find your dismissive style apalling and i think 
  such a reception of a nice patchset must be humiliating to Peter. I
  certainly try to avoid to be involved with any VFS internals, due to
  this unwelcoming tone of discussion. Had you been around when i
  started contributing to the Linux kernel i'd probably not be hacking
  the kernel today. You are a good hacker but the simultaneous
  collateral damage you are causing is significantly reducing the net
  benefit. )

> > ps. please fix your mailer to not emit Mail-Followup-To headers. In 
> > Mutt you can do this via "set followup_to=no" in your .muttrc.
> 
> I have told you last time that this is absolutely intentional and I 
> won't change it.

( You are messing up the reply headers, everyone is listed in the 'To:'
  field for any reply to your mail, instead of being added to the Cc:
  list. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
