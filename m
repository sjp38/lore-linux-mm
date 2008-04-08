Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 8 of 9] XPMEM would have used sys_madvise() except that
	madvise_dontneed()
Message-Id: <3b14e26a4e0491f00bb9.1207669451@duo.random>
In-Reply-To: <patchbomb.1207669443@duo.random>
Date: Tue, 08 Apr 2008 17:44:11 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1207666972 -7200
# Node ID 3b14e26a4e0491f00bb989be04d8b7e0755ed2d7
# Parent  a0c52e4b9b71e2627238b69c0a58905097973279
XPMEM would have used sys_madvise() except that madvise_dontneed()
returns an -EINVAL if VM_PFNMAP is set, which is always true for the pages
XPMEM imports from other partitions and is also true for uncached pages
allocated locally via the mspec allocator.  XPMEM needs zap_page_range()
functionality for these types of pages as well as 'normal' pages.

Signed-off-by: Dean Nelson <dcn@sgi.com>

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -900,6 +900,7 @@
 
 	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
+EXPORT_SYMBOL_GPL(zap_page_range);
 
 /*
  * Do a quick page-table lookup for a single page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
