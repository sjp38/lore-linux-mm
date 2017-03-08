Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFF336B038D
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 07:56:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so54925952pgi.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:56:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c10si3192945pfj.210.2017.03.08.04.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 04:56:33 -0800 (PST)
Date: Wed, 8 Mar 2017 04:56:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v6 1/9] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20170308125631.GX16328@bombadil.infradead.org>
References: <20170308072613.17634-1-ying.huang@intel.com>
 <20170308072613.17634-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308072613.17634-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Mar 08, 2017 at 03:26:05PM +0800, Huang, Ying wrote:
> In this patch, the size of the swap cluster is changed to that of the
> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> the THP swap support on x86_64.  Where one swap cluster will be used to
> hold the contents of each THP swapped out.  And some information of the
> swapped out THP (such as compound map count) will be recorded in the
> swap_cluster_info data structure.
> 
> For other architectures which want THP swap support,
> ARCH_USES_THP_SWAP_CLUSTER need to be selected in the Kconfig file for
> the architecture.
> 
> In effect, this will enlarge swap cluster size by 2 times on x86_64.
> Which may make it harder to find a free cluster when the swap space
> becomes fragmented.  So that, this may reduce the continuous swap space
> allocation and sequential write in theory.  The performance test in 0day
> shows no regressions caused by this.

Well ... if there are no regressions found, why not change it
unconditionally?  The value '256' seems relatively arbitrary (I bet it
was tuned by some doofus with a 486, 8MB RAM and ST506 hard drive ...
it certainly hasn't changed since git started in 2005)

Might be worth checking with the PowerPC people to see if their larger
pages causes this smaller patch to perform badly:

diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -199,7 +199,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 	}
 }
 
-#define SWAPFILE_CLUSTER	256
+#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
 #define LATENCY_LIMIT		256
 
 static inline void cluster_set_flag(struct swap_cluster_info *info,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
