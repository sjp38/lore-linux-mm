Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3444F6B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 18:27:39 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4MMRaJ2017271
	for <linux-mm@kvack.org>; Sun, 22 May 2011 15:27:36 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq5.eem.corp.google.com with ESMTP id p4MMRX00015493
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 May 2011 15:27:34 -0700
Received: by pwi5 with SMTP id 5so2656348pwi.3
        for <linux-mm@kvack.org>; Sun, 22 May 2011 15:27:33 -0700 (PDT)
Date: Sun, 22 May 2011 15:27:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Consistency of loops in mm/truncate.c?
Message-ID: <alpine.LSU.2.00.1105221526020.17400@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Andrew,

I have a series aimed at 2.6.41 to remove mm/shmem.c's peculiar radix
tree of swap entries, using slots in the file's standard radix_tree
instead - prompted in part by https://lkml.org/lkml/2011/1/22/110

There's a patch to give shmem its own truncation loop, handling pages
and swap entries in the same pass.  For that I want to start from a
copy of truncate_inode_page_range(), but notice some discrepancies
between the different loops in mm/truncate.c, so want to standardize
them first before copying.

The advancement of index is hard to follow: we rely upon page->index
of an unlocked page persisting, yet we're ashamed of doing so, sometimes
reading it again once locked.  invalidate_mapping_pages() apologizes for
this, but I think we should now just document that page->index is not
modified until the page is freed.

invalidate_inode_pages2_range() has two sophistications not seen
elsewhere, which 7afadfdc says were folded in by akpm (along with
a page->index one):

- Don't look up more pages than we're going to use:
  seems a good thing for me to fold into truncate_inode_pages_range()
  and invalidate_mapping_pages() too.

- Check for the cursor wrapping at the end of the mapping:
  but with

#if BITS_PER_LONG==32
#define MAX_LFS_FILESIZE (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
#elif BITS_PER_LONG==64
#define MAX_LFS_FILESIZE 0x7fffffffffffffffUL
#endif

  I don't see how page->index + 1 would ever be 0, even if one or
  other of those "-1"s went away; so may I delete the "wrapped" case?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
