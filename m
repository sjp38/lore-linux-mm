Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 80A276B0008
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:23:47 -0500 (EST)
Date: Thu, 31 Jan 2013 23:23:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] mmap_sem in ->fault and ->page_mkwrite
Message-ID: <20130131222335.GA13525@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

  Hi,

  I'm not sure if this is such a great topic but it's a question which
I came across a few times already and LSF/MM is a good place for
brainstorming somewhat crazy ideas ;).

So currently ->fault() and ->page_mkwrite() are called under mmap_sem held
for reading. Now this creates sometimes unpleasant locking dependencies for
filesystems (modern filesystems have to do an equivalent of ->write_begin
in ->page_mkwrite and that is a non-trivial operation). Just to mention my
last itch, I had to split reader side of filesystem freezing lock into two
locks - one which ranks above mmap_sem and one which ranks below it. Then
writer side has to wait for both locks. It works but ...

So I was wondering: Would it be somehow possible we could drop mmap_sem in
these two callbacks (especially ->page_mkwrite())? I understand process'
mapping can change under us once we drop the semaphore so we'd have to
somehow recheck we have still the right page after re-taking mmap_sem. Like
if we protected VMAs with SRCU so that they don't disappear under us once
we drop mmap_sem and after retaking mmap_sem we would recheck whether VMA
still applies to our fault.

And I know there's VM_FAULT_RETRY but that really seems like a special hack
for x86 architecture page fault code. Making it work for all architectures
and callers such as get_user_pages() didn't really seem plausible to me.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
