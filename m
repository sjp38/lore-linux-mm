Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6098D003B
	for <linux-mm@kvack.org>; Mon, 23 May 2011 16:44:43 -0400 (EDT)
Date: Mon, 23 May 2011 13:44:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Consistency of loops in mm/truncate.c?
Message-Id: <20110523134439.22582eee.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1105221526020.17400@sister.anvils>
References: <alpine.LSU.2.00.1105221526020.17400@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 22 May 2011 15:27:41 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Andrew,
> 
> I have a series aimed at 2.6.41 to remove mm/shmem.c's peculiar radix
> tree of swap entries, using slots in the file's standard radix_tree
> instead - prompted in part by https://lkml.org/lkml/2011/1/22/110
> 
> There's a patch to give shmem its own truncation loop, handling pages
> and swap entries in the same pass.  For that I want to start from a
> copy of truncate_inode_page_range(), but notice some discrepancies
> between the different loops in mm/truncate.c, so want to standardize
> them first before copying.
> 
> The advancement of index is hard to follow: we rely upon page->index
> of an unlocked page persisting, yet we're ashamed of doing so, sometimes
> reading it again once locked.  invalidate_mapping_pages() apologizes for
> this, but I think we should now just document that page->index is not
> modified until the page is freed.

That should be true under i_mutex and perhaps other external locking. 
We could put some debug checks in there to catch any situation where
->index changed after the page was locked.

> invalidate_inode_pages2_range() has two sophistications not seen
> elsewhere, which 7afadfdc says were folded in by akpm (along with
> a page->index one):
> 
> - Don't look up more pages than we're going to use:
>   seems a good thing for me to fold into truncate_inode_pages_range()
>   and invalidate_mapping_pages() too.

I guess so.  I doubt if it makes a measurable performance difference
(except maybe in the case of small direct-io's?) but consistency is
good.

> - Check for the cursor wrapping at the end of the mapping:
>   but with
> 
> #if BITS_PER_LONG==32
> #define MAX_LFS_FILESIZE (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
> #elif BITS_PER_LONG==64
> #define MAX_LFS_FILESIZE 0x7fffffffffffffffUL
> #endif
> 
>   I don't see how page->index + 1 would ever be 0, even if one or
>   other of those "-1"s went away; so may I delete the "wrapped" case?

err yes, that seems bogus now and was bogus at the time.  I never
trusted that s_maxbytes thing :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
