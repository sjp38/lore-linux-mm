Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 265656B0419
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 09:40:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p20so36702476pgd.21
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 06:40:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e27si1889837pfl.380.2017.04.06.06.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 06:40:25 -0700 (PDT)
Date: Thu, 6 Apr 2017 06:40:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v2] mm, swap: Use kvzalloc to allocate some swap
 data structure
Message-ID: <20170406134024.GD31725@bombadil.infradead.org>
References: <20170405071058.25223-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405071058.25223-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Apr 05, 2017 at 03:10:58PM +0800, Huang, Ying wrote:
> In general, kmalloc() will have less memory fragmentation than
> vmalloc().  From Dave Hansen: For example, we have a two-page data
> structure.  vmalloc() takes two effectively random order-0 pages,
> probably from two different 2M pages and pins them.  That "kills" two
> 2M pages.  kmalloc(), allocating two *contiguous* pages, is very
> unlikely to cross a 2M boundary (it theoretically could).  That means
> it will only "kill" the possibility of a single 2M page.  More 2M
> pages == less fragmentation.

Wait, what?  How does kmalloc() manage to allocate two pages that cross
a 2MB boundary?  AFAIK if you ask kmalloc to allocate N pages, it asks
the page allocator for an order-log(N) page allocation.  Being a buddy
allocator, that comes back with an aligned set of pages.  There's no
way it can get the last page from a 2MB region and the first page from
the next 2MB region.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
