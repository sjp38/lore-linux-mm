Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E95C6B00CF
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:17:01 -0500 (EST)
Received: by yenm12 with SMTP id m12so2329856yen.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:16:59 -0800 (PST)
Date: Wed, 23 Nov 2011 11:16:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] fs: wire up .truncate_range and .fallocate
In-Reply-To: <20111123103829.GA23168@lst.de>
Message-ID: <alpine.LSU.2.00.1111231107430.2226@sister.anvils>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com> <1322038412-29013-2-git-send-email-amwang@redhat.com> <20111123103829.GA23168@lst.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Nov 2011, Christoph Hellwig wrote:
> 
> It also seems like all fallocate implementaions for far got away
> without the unmap_mapping_range, so either people didn't test them
> hard enough, or tmpfs doesn't need it either.  I fear the former
> is true.

They're saved by the funny little one-by-one unmap_mapping_range()
fallback in truncate_inode_page().  It's inefficient (in those rare
cases when someone is punching a hole somewhere that's mapped) and
we ought to do better, but we don't have an actual bug there.

Hugh

int truncate_inode_page(struct address_space *mapping, struct page *page)
{
	if (page_mapped(page)) {
		unmap_mapping_range(mapping,
				   (loff_t)page->index << PAGE_CACHE_SHIFT,
				   PAGE_CACHE_SIZE, 0);
	}
	return truncate_complete_page(mapping, page);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
