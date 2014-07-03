Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 03E6B6B003B
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 09:02:10 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so11291977wib.1
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 06:02:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec4si22627657wib.69.2014.07.03.06.02.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 06:02:09 -0700 (PDT)
Message-ID: <53B55450.3060908@suse.cz>
Date: Thu, 03 Jul 2014 15:02:08 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm/fs: fix pessimization in hole-punching pagecache
References: <alpine.LSU.2.11.1407021204180.12131@eggly.anvils> <alpine.LSU.2.11.1407021212060.12131@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407021212060.12131@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/02/2014 09:13 PM, Hugh Dickins wrote:
> I wanted to revert my v3.1 commit d0823576bf4b ("mm: pincer in
> truncate_inode_pages_range"), to keep truncate_inode_pages_range()
> in synch with shmem_undo_range(); but have stepped back - a change
> to hole-punching in truncate_inode_pages_range() is a change to
> hole-punching in every filesystem (except tmpfs) that supports it.
>
> If there's a logical proof why no filesystem can depend for its own
> correctness on the pincer guarantee in truncate_inode_pages_range() -
> an instant when the entire hole is removed from pagecache - then let's
> revisit later.  But the evidence is that only tmpfs suffered from the
> livelock, and we have no intention of extending hole-punch to ramfs.
> So for now just add a few comments (to match or differ from those in
> shmem_undo_range()), and fix one silliness noticed in d0823576bf4b...
>
> Its "index == start" addition to the hole-punch termination test was
> incomplete: it opened a way for the end condition to be missed, and the
> loop go on looking through the radix_tree, all the way to end of file.
> Fix that pessimization by resetting index when detected in inner loop.
>
> Note that it's actually hard to hit this case, without the obsessive
> concurrent faulting that trinity does: normally all pages are removed
> in the initial trylock_page() pass, and this loop finds nothing to do.
> I had to "#if 0" out the initial pass to reproduce bug and test fix.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Lukas Czerner <lczerner@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> ---
>
>   mm/truncate.c |   11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
>
> --- 3.16-rc3/mm/truncate.c	2014-06-08 11:19:54.000000000 -0700
> +++ linux/mm/truncate.c	2014-07-02 03:36:05.972553533 -0700
> @@ -355,14 +355,16 @@ void truncate_inode_pages_range(struct a
>   	for ( ; ; ) {
>   		cond_resched();
>   		if (!pagevec_lookup_entries(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE),
> -			indices)) {
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
> +			/* If all gone from start onwards, we're done */
>   			if (index == start)
>   				break;
> +			/* Otherwise restart to make sure all gone */
>   			index = start;
>   			continue;
>   		}
>   		if (index == start && indices[0] >= end) {
> +			/* All gone out of hole to be punched, we're done */
>   			pagevec_remove_exceptionals(&pvec);
>   			pagevec_release(&pvec);
>   			break;
> @@ -373,8 +375,11 @@ void truncate_inode_pages_range(struct a
>
>   			/* We rely upon deletion not changing page->index */
>   			index = indices[i];
> -			if (index >= end)
> +			if (index >= end) {
> +				/* Restart punch to make sure all gone */
> +				index = start - 1;
>   				break;
> +			}
>
>   			if (radix_tree_exceptional_entry(page)) {
>   				clear_exceptional_entry(mapping, index, page);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
