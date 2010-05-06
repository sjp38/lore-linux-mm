Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E71BD62009A
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:52:03 -0400 (EDT)
Date: Thu, 6 May 2010 16:51:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506155143.GD8704@csn.ul.ie>
References: <1273159987-10167-1-git-send-email-mel@csn.ul.ie> <1273159987-10167-2-git-send-email-mel@csn.ul.ie> <4BE2E3F9.9090708@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BE2E3F9.9090708@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 11:44:57AM -0400, Rik van Riel wrote:
> On 05/06/2010 11:33 AM, Mel Gorman wrote:
>
>> @@ -1368,16 +1424,25 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>>   	 * are holding mmap_sem. Users without mmap_sem are required to
>>   	 * take a reference count to prevent the anon_vma disappearing
>>   	 */
>> -	anon_vma = page_anon_vma(page);
>> +	anon_vma = page_anon_vma_lock_root(page);
>>   	if (!anon_vma)
>>   		return ret;
>> -	spin_lock(&anon_vma->lock);
>>   	list_for_each_entry(avc,&anon_vma->head, same_anon_vma) {
>
> One conceptual problem here.  By taking the oldest anon_vma,
> instead of the anon_vma of the page, we may end up searching
> way too many processes.
>
> Eg. if the page is the page of a child process in a forking
> server workload, the above code will end up searching the
> parent and all of the siblings - even for a private page, in
> the child process's private anon_vma.
>
> For an Apache or Oracle system with 1000 clients (and child
> processes), that could be quite a drag - searching 1000 times
> as many processes as we should.
>

That does indeed suck. If we were always locking the root anon_vma, we'd get
away with it but that would involve introducing RCU into the munmap/mmap/etc
path. Is there any way around this problem or will migration just have to
take it on the chin until anon_vma is reference counted and we can
cheaply lock the root anon_vma?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
