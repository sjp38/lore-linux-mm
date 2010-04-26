Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 89F796B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:15:41 -0400 (EDT)
Received: by iwn30 with SMTP id 30so1841913iwn.28
        for <linux-mm@kvack.org>; Mon, 26 Apr 2010 16:15:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1272321478-28481-3-git-send-email-mel@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	 <1272321478-28481-3-git-send-email-mel@csn.ul.ie>
Date: Tue, 27 Apr 2010 08:15:43 +0900
Message-ID: <h2y28c262361004261615j3b1aa5f7kbe3f2eb0a30e99a5@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing the
	wrong VMA information
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 27, 2010 at 7:37 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> vma_adjust() is updating anon VMA information without any locks taken.
> In contrast, file-backed mappings use the i_mmap_lock and this lack of
> locking can result in races with page migration. During rmap_walk(),
> vma_address() can return -EFAULT for an address that will soon be valid.
> This leaves a dangling migration PTE behind which can later cause a BUG_ON
> to trigger when the page is faulted in.
>
> With the recent anon_vma changes, there can be more than one anon_vma->lock
> that can be taken in a anon_vma_chain but a second lock cannot be spinned
> upon in case of deadlock. Instead, the rmap walker tries to take locks of
> different anon_vma's. If the attempt fails, the operation is restarted.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Actually, I am worry about rollback approach like this.
If we don't often need anon_vmas serializing, that's enough.
But I am not sure how often we need locking of anon_vmas like this.
Whenever we need it, we have to use rollback approach like this in future.
In my opinion, it's not good.

Rik, can't we make anon_vma locks more simple?
Anyway, Mel's patch is best now.

I hope improving locks of anon_vmas without rollback approach in near future.

Thanks, Mel.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
