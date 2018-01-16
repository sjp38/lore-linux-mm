Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B107B28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:26:19 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a12so6822263pll.21
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:26:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si2633182pfl.212.2018.01.16.13.26.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 13:26:18 -0800 (PST)
Date: Tue, 16 Jan 2018 21:26:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
Message-ID: <20180116212614.gudglzw7kwzd3get@suse.de>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
 <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henry Willard <henry.willard@oracle.com>
Cc: akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 16, 2018 at 11:28:44AM -0800, Henry Willard wrote:
> Workloads consisting of a large number processes running the same program
> with a large shared data section may suffer from excessive numa balancing
> page migration of the pages in the shared data section. This shows up as
> high I/O wait time and degraded performance on machines with higher socket
> or node counts.
> 
> This patch skips shared copy-on-write pages in change_pte_range() for the
> numa balancing case.
> 
> Signed-off-by: Henry Willard <henry.willard@oracle.com>
> Reviewed-by: Hakon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Steve Sistare steven.sistare@oracle.com

Merge the leader and this mail together. It would have been nice to see
data on other realistic workloads as well.

My main source of discomfort is the fact that this is permanent as two
processes perfectly isolated but with a suitably shared COW mapping
will never migrate the data. A potential improvement to get the reported
bandwidth up in the test program would be to skip the rest of the VMA if
page_mapcount != 1 in a COW mapping as it would be reasonable to assume
the remaining pages in the VMA are also affected and the scan is wasteful.
There are counter-examples to this but I suspect that the full VMA being
shared is the common case. Whether you do that or not;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
