Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05B406B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 17:21:48 -0500 (EST)
Date: Mon, 22 Nov 2010 14:21:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 2/2] Prevent promotion of page in madvise_dontneed
Message-Id: <20101122142109.2f3e168c.akpm@linux-foundation.org>
In-Reply-To: <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010 23:30:24 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now zap_pte_range alwayas promotes pages which are pte_young &&
> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
> it's unnecessary since the page wouldn't use any more.
> 
> If the page is sharred by other processes and it's real working set

This patch doesn't actually do anything.  It passes variable `promote'
all the way down to unmap_vmas(), but unmap_vmas() doesn't use that new
variable.

Have a comment fixlet:

--- a/mm/memory.c~mm-prevent-promotion-of-page-in-madvise_dontneed-fix
+++ a/mm/memory.c
@@ -1075,7 +1075,7 @@ static unsigned long unmap_page_range(st
  * @end_addr: virtual address at which to end unmapping
  * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
  * @details: details of nonlinear truncation or shared cache invalidation
- * @promote: whether pages inclued vma would be promoted or not
+ * @promote: whether pages included in the vma should be promoted or not
  *
  * Returns the end address of the unmapping (restart addr if interrupted).
  *
_

Also, I'd suggest that we avoid introducing the term "promote".  It
isn't a term which is presently used in Linux MM.  Probably "activate"
has a better-known meaning.

And `activate' could be a bool if one is in the mood for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
