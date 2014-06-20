Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 764966B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:46:02 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so4182981wes.36
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:46:01 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id df5si12056760wjb.42.2014.06.20.10.45.59
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 10:46:00 -0700 (PDT)
Date: Fri, 20 Jun 2014 20:45:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 01/13] mm, THP: don't hold mmap_sem in khugepaged when
 allocating THP
Message-ID: <20140620174533.GA9635@node.dhcp.inet.fi>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403279383-5862-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 05:49:31PM +0200, Vlastimil Babka wrote:
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

There is no point in touching ->mmap_sem in khugepaged_alloc_page() at
all. Please, move up_read() outside khugepaged_alloc_page().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
