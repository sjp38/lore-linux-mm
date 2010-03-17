Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AF1B66B0173
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:21:25 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 24 of 34] kvm mmu transparent hugepage support
Message-Id: <de32d2c23867c211089a.1268839166@v2.random>
In-Reply-To: <patchbomb.1268839142@v2.random>
References: <patchbomb.1268839142@v2.random>
Date: Wed, 17 Mar 2010 16:19:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

From: Marcelo Tosatti <mtosatti@redhat.com>

This should work for both hugetlbfs and transparent hugepages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -470,6 +470,15 @@ static int host_mapping_level(struct kvm
 
 	page_size = kvm_host_page_size(kvm, gfn);
 
+	/* check for transparent hugepages */
+	if (page_size == PAGE_SIZE) {
+		struct page *page = gfn_to_page(kvm, gfn);
+
+		if (!is_error_page(page) && PageTransCompound(page))
+			page_size = KVM_HPAGE_SIZE(2);
+		kvm_release_page_clean(page);
+	}
+
 	for (i = PT_PAGE_TABLE_LEVEL;
 	     i < (PT_PAGE_TABLE_LEVEL + KVM_NR_PAGE_SIZES); ++i) {
 		if (page_size >= KVM_HPAGE_SIZE(i))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
