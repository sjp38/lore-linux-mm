Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5639C6B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:34:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so30714699pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:34:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id to7si43341787pac.282.2016.08.09.09.34.48
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:34:48 -0700 (PDT)
Subject: Re: [RFC] mm: Don't use radix tree writeback tags for pages in swap
 cache
References: <1470759443-9229-1-git-send-email-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57AA061B.2050002@intel.com>
Date: Tue, 9 Aug 2016 09:34:35 -0700
MIME-Version: 1.0
In-Reply-To: <1470759443-9229-1-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On 08/09/2016 09:17 AM, Huang, Ying wrote:
> File pages uses a set of radix tags (DIRTY, TOWRITE, WRITEBACK) to
> accelerate finding the pages with the specific tag in the the radix tree
> during writing back an inode.  But for anonymous pages in swap cache,
> there are no inode based writeback.  So there is no need to find the
> pages with some writeback tags in the radix tree.  It is no necessary to
> touch radix tree writeback tags for pages in swap cache.

Seems simple enough.  Do we do any of this unnecessary work for the
other radix tree tags?  If so, maybe we should just fix this once and
for all.  Could we, for instance, WARN_ONCE() in radix_tree_tag_set() if
it sees a swap mapping get handed in there?

In any case, I think the new !PageSwapCache(page) check either needs
commenting, or a common helper for the two sites that you can comment.

> With this patch, the swap out bandwidth improved 22.3% in vm-scalability
> swap-w-seq test case with 8 processes on a Xeon E5 v3 system, because of
> reduced contention on swap cache radix tree lock.  To test sequence swap
> out, the test case uses 8 processes sequentially allocate and write to
> anonymous pages until RAM and part of the swap device is used up.

What was the swap device here, btw?  What is the actual bandwidth
increase you are seeing?  Is it 1MB/s -> 1.223MB/s? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
