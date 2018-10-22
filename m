Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB4C56B000C
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:19:01 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 36so29706630ott.22
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:19:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l3si13176520otf.33.2018.10.21.22.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 22:19:00 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9M59U9k034174
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:59 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n94xr5q68-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:59 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 22 Oct 2018 06:18:57 +0100
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v1 2/4] kvmppc: Add support for shared pages in HMM driver
Date: Mon, 22 Oct 2018 10:48:35 +0530
In-Reply-To: <20181022051837.1165-1-bharata@linux.ibm.com>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
Message-Id: <20181022051837.1165-3-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com, Bharata B Rao <bharata@linux.ibm.com>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support shared pages in HMM driver.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/kvm/book3s_hv_hmm.c | 69 ++++++++++++++++++++++++++++++--
 1 file changed, 65 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
index a2ee3163a312..09b8e19b7605 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -50,6 +50,7 @@ struct kvmppc_hmm_page_pvt {
 	struct hlist_head *hmm_hash;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
 
 struct kvmppc_hmm_migrate_args {
@@ -278,6 +279,65 @@ static unsigned long kvmppc_gpa_to_hva(struct kvm *kvm, unsigned long gpa,
 	return hva;
 }
 
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the HMM fault handler to release the HMM page.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long gpa,
+		  unsigned long addr, unsigned long page_shift)
+{
+
+	int ret;
+	struct hlist_head *list, *hmm_hash;
+	unsigned int lpid = kvm->arch.lpid;
+	unsigned long flags;
+	struct kvmppc_hmm_pfn_entry *p;
+	struct page *hmm_page, *page;
+	struct kvmppc_hmm_page_pvt *pvt;
+	unsigned long pfn;
+
+	/*
+	 * First check if the requested page has already been given to
+	 * UV as a secure page. If so, ensure that we don't issue a
+	 * UV_PAGE_OUT but instead directly send the page
+	 */
+	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
+	hmm_hash = kvm->arch.hmm_hash;
+	list = &hmm_hash[kvmppc_hmm_pfn_hash_fn(gpa)];
+	hlist_for_each_entry(p, list, hlist) {
+		if (p->addr == gpa) {
+			hmm_page = pfn_to_page(p->hmm_pfn);
+			get_page(hmm_page); /* TODO: Necessary ? */
+			pvt = (struct kvmppc_hmm_page_pvt *)
+				hmm_devmem_page_get_drvdata(hmm_page);
+			pvt->skip_page_out = true;
+			put_page(hmm_page);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+
+	ret = get_user_pages_fast(addr, 1, 0, &page);
+	if (ret != 1)
+		return H_PARAMETER;
+
+	pfn = page_to_pfn(page);
+	if (is_zero_pfn(pfn)) {
+		put_page(page);
+		return H_SUCCESS;
+	}
+
+	ret = uv_page_in(lpid, pfn << page_shift, gpa, 0, page_shift);
+	put_page(page);
+
+	return (ret == U_SUCCESS) ? H_SUCCESS : H_PARAMETER;
+}
+
 /*
  * Move page from normal memory to secure memory.
  */
@@ -300,8 +360,8 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
 		return H_PARAMETER;
 	end = addr + (1UL << page_shift);
 
-	if (flags)
-		return H_P2;
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, gpa, addr, page_shift);
 
 	args.hmm_hash = kvm->arch.hmm_hash;
 	args.lpid = kvm->arch.lpid;
@@ -349,8 +409,9 @@ kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	       hmm_devmem_page_get_drvdata(spage);
 
 	pfn = page_to_pfn(dpage);
-	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
-			  pvt->gpa, 0, PAGE_SHIFT);
+	if (!pvt->skip_page_out)
+		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+				  pvt->gpa, 0, PAGE_SHIFT);
 	if (ret == U_SUCCESS)
 		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
 }
-- 
2.17.1
