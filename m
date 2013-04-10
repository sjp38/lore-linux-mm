Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 29CE06B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 09:54:55 -0400 (EDT)
Date: Wed, 10 Apr 2013 13:54:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm, slub: count freed pages via rcu as this task's
 reclaimed_slab
In-Reply-To: <5164DA6A.5060607@gmail.com>
Message-ID: <0000013df43a48e5-6addd57e-952b-4754-848e-6d454b0a906c-000000@email.amazonses.com>
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com> <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com> <5163E194.3080600@gmail.com> <0000013def363b50-9a16dd09-72ad-494f-9c25-17269fc3aab3-000000@email.amazonses.com>
 <5164DA6A.5060607@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Wed, 10 Apr 2013, Simon Jeons wrote:

> It seems that you misunderstand my question. I don't doubt slab/slub can use
> high order pages. However, what I focus on is why slab/slub can use compound
> page, PageCompound() just on behalf of hugetlbfs pages or thp pages which
> should used by apps, isn't it?

I am not entirely clear on what you are asking for. The following gives a
couple of answers to what I guess the question was.

THP pages and user pages are on the lru and are managed differently.
The slab allocators cannot work with those pages.

Slab allocators *can* allocate higher order pages therefore they could
allocate a page of the same order as huge pages and manage it that way.

However there is no way that these pages could be handled like THP pages
since they cannot be broken up (unless we add the capability to move slab
objects which I wanted to do for a long time).


You can boot a Linux system that uses huge pages for slab allocation
by specifying the following parameter on the kernel command line.

	slub_min_order=9

The slub allocator will start using huge pages for all its storage
needs. You need a large number of huge pages to do this. Lots of memory
is going to be lost due to fragmentation but its going to be fast since
the slowpaths are rarely used. OOMs due to reclaim failure become much
more likely ;-).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
