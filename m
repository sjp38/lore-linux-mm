Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8F4936B0037
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 13:04:26 -0500 (EST)
Date: Mon, 4 Feb 2013 19:04:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] mmap_sem in ->fault and ->page_mkwrite
Message-ID: <20130204180423.GI7523@quack.suse.cz>
References: <20130131222335.GA13525@quack.suse.cz>
 <20130131230327.GN4503@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130131230327.GN4503@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu 31-01-13 23:03:27, Al Viro wrote:
> On Thu, Jan 31, 2013 at 11:23:35PM +0100, Jan Kara wrote:
> >   Hi,
> > 
> >   I'm not sure if this is such a great topic but it's a question which
> > I came across a few times already and LSF/MM is a good place for
> > brainstorming somewhat crazy ideas ;).
> > 
> > So currently ->fault() and ->page_mkwrite() are called under mmap_sem held
> > for reading. Now this creates sometimes unpleasant locking dependencies for
> > filesystems (modern filesystems have to do an equivalent of ->write_begin
> > in ->page_mkwrite and that is a non-trivial operation). Just to mention my
> > last itch, I had to split reader side of filesystem freezing lock into two
> > locks - one which ranks above mmap_sem and one which ranks below it. Then
> > writer side has to wait for both locks. It works but ...
> > 
> > So I was wondering: Would it be somehow possible we could drop mmap_sem in
> > these two callbacks (especially ->page_mkwrite())? I understand process'
> > mapping can change under us once we drop the semaphore so we'd have to
> > somehow recheck we have still the right page after re-taking mmap_sem. Like
> > if we protected VMAs with SRCU so that they don't disappear under us once
> > we drop mmap_sem and after retaking mmap_sem we would recheck whether VMA
> > still applies to our fault.
> > 
> > And I know there's VM_FAULT_RETRY but that really seems like a special hack
> > for x86 architecture page fault code. Making it work for all architectures
> > and callers such as get_user_pages() didn't really seem plausible to me.
> 
> Please, *please*, don't.  VMA locking is complete horror without SRCU
> mess thrown in.  It's a bloody bad idea, at least without a very massive
> cleanup prior to that thing.
> 
> Start with drawing the call graph for vma-related code - at least the
> parts from relevant locks grabbed to accesses of fields protected by
> said locks.
  VMAs are protected by mmap_sem AFAIK so that doesn't look all that
complex. But I guess you are pointing at the fact that sometimes mmap_sem
is acquired rather far (sometimes even in arch code) from the places which
use the protection of mmap_sem and so it would be difficult (if possible at
all) to verify that once we drop mmap_sem, all these places will happily
handle that fact. I agree it would be a mess unless we somehow simplify
things first...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
