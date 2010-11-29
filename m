Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE056B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 18:25:09 -0500 (EST)
Date: Mon, 29 Nov 2010 15:25:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
Message-Id: <20101129152500.000c380b.akpm@linux-foundation.org>
In-Reply-To: <AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com>
	<20101122154754.e022d935.akpm@linux-foundation.org>
	<AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert =?UTF-8?Q?=C5=9Awi=C4=99cki?= <robert@swiecki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 15:55:31 +0100
Robert  wi cki <robert@swiecki.net> wrote:

> >> Hi,
> >>
> >> I was doing some fuzzing with http://code.google.com/p/iknowthis/ and
> >> my system pretty quickly crashes with the BUG() below.
> >
> > So it is a repeatable crash?
> 
> Not in a sense that I can provide you with a sequence of syscalls that
> led to this state. Generally it repeats after some time (<12 hours on
> 2 intel-core) of running the
> http://code.google.com/p/iknowthis/source/browse/#svn/trunk
> 
> >> - Even if it's just BUG() it renders my system unusable (I'm able to
> >> type a few characters on the virtual terminal at most)
> >> - Judging from the stacktrace it's sys_madvise(..., ..., MADV_REMOVE)
> >> - I'm testing with ubuntu's 2.6.35-22-server#35 but I got similar
> >> results with 2.6.32 some time ago
> >
> > It is.
> >
> >> - I'm posting this cause diving into linux mm spaghetti code might be
> >> not a trivial task, but if nobody can see anything obvious in a day or
> >> so, I'll try to debug it mysel
> >> - I'm unable to provide a testcase by now, nor any usable state of the
> >> crashing process, cause the system becomes unusable
> >> - It crashes both linux-kernel working on a physical machine as well
> >> as on the VirtualBox emulator
> >> - I'm usually waiting from 0.5h to 12h for this crash to appear, I
> >> think it could be speed up greatly by disabling any irrelevant
> >> syscalls in the fuzzer
> >>
> >> [25142.286531] kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
> >
> > That's
> >
> >        BUG_ON(page_mapped(page));
> >
> > in  remove_from_page_cache().  That state is worth a BUG().

At a guess I'd say that another thread came in and established a
mapping against a page in the to-be-truncated range while
vmtruncate_range() was working on it.  In fact I'd be suspecting that
the mapping was established after truncate_inode_page() ran its
page_mapped() test.

Let's take a look at vmtruncate_range():

int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
{
	struct address_space *mapping = inode->i_mapping;

	/*
	 * If the underlying filesystem is not going to provide
	 * a way to truncate a range of blocks (punch a hole) -
	 * we should return failure right now.
	 */
	if (!inode->i_op->truncate_range)
		return -ENOSYS;

	mutex_lock(&inode->i_mutex);
	down_write(&inode->i_alloc_sem);
	unmap_mapping_range(mapping, offset, (end - offset), 1);
	truncate_inode_pages_range(mapping, offset, end);
	unmap_mapping_range(mapping, offset, (end - offset), 1);
	inode->i_op->truncate_range(inode, offset, end);
	up_write(&inode->i_alloc_sem);
	mutex_unlock(&inode->i_mutex);

	return 0;
}

Now, why does it call unmap_mapping_range() twice?

Nick's original 2007 patch d00806b183152af6d2 ("mm: fix fault vs
invalidate race for linear mappings") added the second
unmap_mapping_range() call, along with this nice comment, which
explains it all:


+       /*
+        * unmap_mapping_range is called twice, first simply for efficiency
+        * so that truncate_inode_pages does fewer single-page unmaps. However
+        * after this first call, and before truncate_inode_pages finishes,
+        * it is possible for private pages to be COWed, which remain after
+        * truncate_inode_pages finishes, hence the second unmap_mapping_range
+        * call must be made for correctness.
+	 /*

Later, some twirp deleted the damn comment.  Why'd we do that?  It
still seems to be valid.

If this _is_ still valid, and the first call to unmap_mapping_range() is
really just a best-effort performance thing which won't reliably clear
all the mappings then perhaps the BUG_ON(page_mapped(page)) assertion
in __remove_from_page_cache() is simply bogus.

We don't appear to have mmap_sem coverage around here, perhaps for
lock-ordering reasons.  I suspect we'll be struggling to plug all holes
here without that coverage.

Fortunately the comment over madvise_remove() says it's tmpfs-only, so
we can blame Hugh :)


hm, I found the lost comment.  It somehow wandered over into
truncate_pagecache(), but is still relevant at the vmtruncate_range()
site.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
