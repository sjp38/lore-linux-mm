Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 292376B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:18:25 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so4173957wes.21
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:18:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si17640400wjr.7.2014.07.25.05.18.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:18:23 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:18:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 01/15] mm, THP: don't hold mmap_sem in khugepaged when
 allocating THP
Message-ID: <20140725121815.GV10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:09PM +0200, Vlastimil Babka wrote:
> When allocating huge page for collapsing, khugepaged currently holds mmap_sem
> for reading on the mm where collapsing occurs. Afterwards the read lock is
> dropped before write lock is taken on the same mmap_sem.
> 
> Holding mmap_sem during whole huge page allocation is therefore useless, the
> vma needs to be rechecked after taking the write lock anyway. Furthemore, huge
> page allocation might involve a rather long sync compaction, and thus block
> any mmap_sem writers and i.e. affect workloads that perform frequent m(un)map
> or mprotect oterations.
> 
> This patch simply releases the read lock before allocating a huge page. It
> also deletes an outdated comment that assumed vma must be stable, as it was
> using alloc_hugepage_vma(). This is no longer true since commit 9f1b868a13
> ("mm: thp: khugepaged: add policy for finding target node").
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
