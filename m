Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 170AA6B008A
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK94YF027801
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:04 -0500
Message-Id: <20100226200902.721243055@redhat.com>
Date: Fri, 26 Feb 2010 21:04:57 +0100
From: aarcange@redhat.com
Subject: [patch 24/35] kvm mmu transparent hugepage support
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=kvm_transparent_hugepage
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Marcelo Tosatti <mtosatti@redhat.com>

This should work for both hugetlbfs and transparent hugepages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/kvm/mmu.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -470,6 +470,15 @@ static int host_mapping_level(struct kvm
 
 	page_size = kvm_host_page_size(kvm, gfn);
 
+	/* check for transparent hugepages */
+	if (page_size == PAGE_SIZE) {
+		struct page *page = gfn_to_page(kvm, gfn);
+
+		if (!is_error_page(page) && PageHead(page))
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
