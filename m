Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D4DB96B02BA
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:45:34 -0400 (EDT)
Message-ID: <4BE2E3F9.9090708@redhat.com>
Date: Thu, 06 May 2010 11:44:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
References: <1273159987-10167-1-git-send-email-mel@csn.ul.ie> <1273159987-10167-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1273159987-10167-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 05/06/2010 11:33 AM, Mel Gorman wrote:

> @@ -1368,16 +1424,25 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>   	 * are holding mmap_sem. Users without mmap_sem are required to
>   	 * take a reference count to prevent the anon_vma disappearing
>   	 */
> -	anon_vma = page_anon_vma(page);
> +	anon_vma = page_anon_vma_lock_root(page);
>   	if (!anon_vma)
>   		return ret;
> -	spin_lock(&anon_vma->lock);
>   	list_for_each_entry(avc,&anon_vma->head, same_anon_vma) {

One conceptual problem here.  By taking the oldest anon_vma,
instead of the anon_vma of the page, we may end up searching
way too many processes.

Eg. if the page is the page of a child process in a forking
server workload, the above code will end up searching the
parent and all of the siblings - even for a private page, in
the child process's private anon_vma.

For an Apache or Oracle system with 1000 clients (and child
processes), that could be quite a drag - searching 1000 times
as many processes as we should.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
