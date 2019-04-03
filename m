Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16D9FC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB78E206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SG5anKd8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB78E206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAD546B0275; Wed,  3 Apr 2019 13:37:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C08376B0276; Wed,  3 Apr 2019 13:37:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A898C6B0277; Wed,  3 Apr 2019 13:37:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 795246B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:15 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 204so10294724ybf.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=BPCoKe4N/Rog3LaZqAmbRh3NwY6xgOGLh9z8YMMslMU=;
        b=UDFrMYq9ETzRhfMYnFoSBFjDu62DMsPMaYmZ1RQpUZhc1DoW6jX14Atll7nvpxYlwi
         E7yZY9RD/1LpO3hfzEvJ0Nh4zP9VvRHz6vPMbMklnFJGigaRkCy+wiDNFNP/yh39oMAV
         ylwamm3P1WxvyWrk6tY/si8FezaGKjMcvDbjdujuhne9JRMltmND+rizyORgeEai3m0l
         Sayfh3vZ5SMydliFJvK2L7fIenjleiQWcY2+e2XUHwJZhAkPbTLShZvIf0/p0vuCnaL9
         Z7iaR6p12Y7L8TmlNhYKk8qPmhNzZdG2L+gfELt6WeVkWQOuZc3W6U/AWHTwsanO/ze4
         0S6w==
X-Gm-Message-State: APjAAAUyhy49Oy7rwSxKtR7DWS4l8LRC3lUKaZrhWE5VPVeu0K7M8EB3
	UfMu+1XfQI0uNu6PMcjSuUUgiqv2ezkXwG/Fs9FLo80kjegAIL1pGwJh4TtsTKOK1Y1IhFjdrQz
	Pf11EkjeOOgBaZud4blmUbSfknXpKiCoZPAS24SHb51jwU574AzCJHw1ea2+v2CLm+A==
X-Received: by 2002:a25:4c84:: with SMTP id z126mr1181815yba.270.1554313035187;
        Wed, 03 Apr 2019 10:37:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtPljSinaU0UQ4GYz189UEm5na8ZVr38kT5Z2E0J+NL+q0caCbZGCcRwymdmz7vWLoR1Yt
X-Received: by 2002:a25:4c84:: with SMTP id z126mr1181714yba.270.1554313033975;
        Wed, 03 Apr 2019 10:37:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313033; cv=none;
        d=google.com; s=arc-20160816;
        b=fgbOLBetZSbhBCJsbc3g82TMciC1+A41X6AYYQYxUlVu47AOmD0x/2mixYYZOgon3I
         tOsmyt3w3NIqUsu0QrBMjv9CE9V3jrtoepjkQ43RLITM596ERFa93cydXqdwd0lQFIxS
         998JUHES+VAsvpOS+lR5FChSGvD3o5PZk0F6t5WnqUOTYJEzrE8mOnuwCUI5p5b84o5h
         z4PjsBS9D6WWVUdT8aoJZjKuHO6zvVPMNM3U0NNhgHqD8PkEn0Mb/+OSwXuHGs6a33ys
         xKem7gFajkDK6g7brSzqcv8qW58GzXWIezCqJAS7GpWctN2bnMJhtFkwzR2OrDgYapRj
         f6Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=BPCoKe4N/Rog3LaZqAmbRh3NwY6xgOGLh9z8YMMslMU=;
        b=EPUe3VpFP9L7lgWdvcv7SciwmlKiD7Rdq4DLRdnVC4XOB/1Ftgbu4ezog3YR67Ullo
         1E3y9YAnNdrq0UldBU1fMZWKPB7IL+emPUOa6T2cmcUuLZpe/tZmWNVRqDpnnhPCjQIK
         HxbnEoPVnDCt1sIWP54aoobUFubIiS3cACJbrU7I7OQjddvVfnMga34no54i5QbQRm00
         IsvTW9XSRBafpEdxdJiwwM3r+NY9WELEcPiWFDRJujqg+Zq2Fu7lWNehuxHnBxKxOwNB
         9xJymihymwWfRVVoPk3il5U7N00+D9RAfiQoqj8QFjFLwDJVXS5HO2lpe6ic2roDxdDQ
         wQbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SG5anKd8;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l18si6492681ywl.434.2019.04.03.10.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SG5anKd8;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNuv5175541;
	Wed, 3 Apr 2019 17:36:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=BPCoKe4N/Rog3LaZqAmbRh3NwY6xgOGLh9z8YMMslMU=;
 b=SG5anKd8PlRvt+kNrFuRkC7L7Qh8X5Jdc62zx1QoGlwH6aQfOAKP6SxUjbMqQVs6iCVv
 +eXoXspZBjqyfQPDahh3j8wMnrTqXsIBu6zJojc0zdtGCjF9nCEhG1RDhoRlKcgioRJW
 SpaUeb83RbynUMLVwGE5n/px02BNncuKu1ZQ8yDDpUP9ydNpbrjMj4q8UMOUdmtW4rSo
 FGUeIkRdaLcqesQ3RxPcB8LFOJ0jAESJHRZvkGU4fWMMuj9sXGV0ZgoFUWHa13yxI1Qn
 tmg6i4Oawm6EPZN9NR6XQrL1A7BW6NYt+2vDCXkEjhu7VSOvBuLJDxNy1m8K008GOGz+ zQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rj13qaeae-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:22 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIC1110882;
	Wed, 3 Apr 2019 17:36:21 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fyqd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:21 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33HaGCv001670;
	Wed, 3 Apr 2019 17:36:16 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:36:15 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org, aaron.lu@intel.com,
        akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
        amir73il@gmail.com, andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 13/13] xpfo, mm: Optimize XPFO TLB flushes by batching them together
Date: Wed,  3 Apr 2019 11:34:14 -0600
Message-Id: <be3868d4514e969f22d37d76a591683be9f6b3ee.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When XPFO forces a TLB flush on all cores, the performance impact is
very significant. Batching as many of these TLB updates as
possible can help lower this impact. When a userspace allocates a
page, kernel tries to get that page from the per-cpu free list.
This free list is replenished in bulk when it runs low. Free
list is being replenished for future allocation to userspace is a
good opportunity to update TLB entries in batch and reduce the
impact of multiple TLB flushes later. This patch adds new tags for
the page so a page can be marked as available for userspace
allocation and unmapped from kernel address space. All such pages
are removed from kernel address space in bulk at the time they are
added to per-cpu free list. This patch when combined with deferred
TLB flushes improves performance further. Using the same benchmark
as before of building kernel in parallel, here are the system
times on two differently sized systems:

Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
make -j60 all

5.0					913.862s
5.0+XPFO+Deferred flush+Batch update	1165.259s	1.28x

Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
make -j4 all

5.0					610.642s
5.0+XPFO+Deferred flush+Batch update	773.075s	1.27x

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
---
v9:
	- Do not map a page freed by userspace back into kernel. Mark
	 it as unmapped instead and map it back in only when needed. This
	 avoids the cost of unmap and TLBV flush if the page is allocated
	 back to userspace.

 arch/x86/include/asm/pgtable.h |  2 +-
 arch/x86/mm/pageattr.c         |  9 ++++--
 arch/x86/mm/xpfo.c             | 11 +++++--
 include/linux/xpfo.h           | 11 +++++++
 mm/page_alloc.c                |  9 ++++++
 mm/xpfo.c                      | 54 +++++++++++++++++++++++++++-------
 6 files changed, 79 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5c0e1581fa56..61f64c6c687c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1461,7 +1461,7 @@ should_split_large_page(pte_t *kpte, unsigned long address,
 extern spinlock_t cpa_lock;
 int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
-		   struct page *base);
+		   struct page *base, bool xpfo_split);
 
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 530b5df0617e..8fe86ac6bff0 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -911,7 +911,7 @@ static void split_set_pte(struct cpa_data *cpa, pte_t *pte, unsigned long pfn,
 
 int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
-		   struct page *base)
+		   struct page *base, bool xpfo_split)
 {
 	unsigned long lpaddr, lpinc, ref_pfn, pfn, pfninc = 1;
 	pte_t *pbase = (pte_t *)page_address(base);
@@ -1008,7 +1008,10 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	 * page attribute in parallel, that also falls into the
 	 * just split large page entry.
 	 */
-	flush_tlb_all();
+	if (xpfo_split)
+		xpfo_flush_tlb_all();
+	else
+		flush_tlb_all();
 	spin_unlock(&pgd_lock);
 
 	return 0;
@@ -1027,7 +1030,7 @@ static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
 	if (!base)
 		return -ENOMEM;
 
-	if (__split_large_page(cpa, kpte, address, base))
+	if (__split_large_page(cpa, kpte, address, base, false))
 		__free_page(base);
 
 	return 0;
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index 638eee5b1f09..8c482c7b54f5 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -47,7 +47,7 @@ inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 
 		cpa.vaddr = kaddr;
 		cpa.pages = &page;
-		cpa.mask_set = prot;
+		cpa.mask_set = canon_pgprot(prot);
 		cpa.mask_clr = msk_clr;
 		cpa.numpages = 1;
 		cpa.flags = 0;
@@ -57,7 +57,7 @@ inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 
 		do_split = should_split_large_page(pte, (unsigned long)kaddr,
 						   &cpa);
-		if (do_split) {
+		if (do_split > 0) {
 			struct page *base;
 
 			base = alloc_pages(GFP_ATOMIC, 0);
@@ -69,7 +69,7 @@ inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 			if (!debug_pagealloc_enabled())
 				spin_lock(&cpa_lock);
 			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr,
-						base) < 0) {
+						base, true) < 0) {
 				__free_page(base);
 				WARN(1, "xpfo: failed to split large page\n");
 			}
@@ -90,6 +90,11 @@ inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 }
 EXPORT_SYMBOL_GPL(set_kpte);
 
+void xpfo_flush_tlb_all(void)
+{
+	xpfo_flush_tlb_kernel_range(0, TLB_FLUSH_ALL);
+}
+
 inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 {
 	int level;
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 37e7f52fa6ce..01da4bb31cd6 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -32,6 +32,7 @@ DECLARE_STATIC_KEY_TRUE(xpfo_inited);
 /* Architecture specific implementations */
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
 void xpfo_flush_kernel_tlb(struct page *page, int order);
+void xpfo_flush_tlb_all(void);
 
 void xpfo_init_single_page(struct page *page);
 
@@ -106,6 +107,9 @@ void xpfo_temp_map(const void *addr, size_t size, void **mapping,
 void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 		     size_t mapping_len);
 
+bool xpfo_pcp_refill(struct page *page, enum migratetype migratetype,
+		     int order);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_init_single_page(struct page *page) { }
@@ -118,6 +122,7 @@ static inline void xpfo_free_pages(struct page *page, int order) { }
 
 static inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot) { }
 static inline void xpfo_flush_kernel_tlb(struct page *page, int order) { }
+static inline void xpfo_flush_tlb_all(void) { }
 
 static inline phys_addr_t user_virt_to_phys(unsigned long addr) { return 0; }
 
@@ -133,6 +138,12 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
 {
 }
 
+static inline bool xpfo_pcp_refill(struct page *page,
+				   enum migratetype migratetype, int order)
+{
+	return false;
+}
+
 #endif /* CONFIG_XPFO */
 
 #if (!defined(CONFIG_HIGHMEM)) && (!defined(ARCH_HAS_KMAP))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e0dda1322a2..7846b2590ef0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3031,6 +3031,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 			struct list_head *list)
 {
 	struct page *page;
+	struct list_head *cur;
+	bool flush_tlb = false;
 
 	do {
 		if (list_empty(list)) {
@@ -3039,6 +3041,13 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 					migratetype, alloc_flags);
 			if (unlikely(list_empty(list)))
 				return NULL;
+			list_for_each(cur, list) {
+				page = list_entry(cur, struct page, lru);
+				flush_tlb |= xpfo_pcp_refill(page,
+							     migratetype, 0);
+			}
+			if (flush_tlb)
+				xpfo_flush_tlb_all();
 		}
 
 		page = list_first_entry(list, struct page, lru);
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 974f1b70ccd9..47d400f1fc65 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -62,17 +62,22 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map)
 		WARN_ON(atomic_read(&(page + i)->xpfo_mapcount));
 #endif
 		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
+			bool user_page = TestSetPageXpfoUser(page + i);
+
 			/*
 			 * Tag the page as a user page and flush the TLB if it
 			 * was previously allocated to the kernel.
 			 */
-			if ((!TestSetPageXpfoUser(page + i)) || !will_map) {
-				SetPageXpfoUnmapped(page + i);
-				flush_tlb = true;
+			if (!user_page || !will_map) {
+				if (!TestSetPageXpfoUnmapped(page + i))
+					flush_tlb = true;
 			}
 		} else {
 			/* Tag the page as a non-user (kernel) page */
 			ClearPageXpfoUser(page + i);
+			if (TestClearPageXpfoUnmapped(page + i))
+				set_kpte(page_address(page + i), page + i,
+					 PAGE_KERNEL);
 		}
 	}
 
@@ -95,14 +100,12 @@ void xpfo_free_pages(struct page *page, int order)
 #endif
 
 		/*
-		 * Map the page back into the kernel if it was previously
-		 * allocated to user space.
+		 * Leave the page as unmapped from kernel. If this page
+		 * gets allocated to userspace soon again, it saves us
+		 * the cost of TLB flush at that time.
 		 */
-		if (TestClearPageXpfoUser(page + i)) {
-			ClearPageXpfoUnmapped(page + i);
-			set_kpte(page_address(page + i), page + i,
-				 PAGE_KERNEL);
-		}
+		if (PageXpfoUser(page + i))
+			SetPageXpfoUnmapped(page + i);
 	}
 }
 
@@ -134,3 +137,34 @@ void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 			kunmap_atomic(mapping[i]);
 }
 EXPORT_SYMBOL(xpfo_temp_unmap);
+
+bool xpfo_pcp_refill(struct page *page, enum migratetype migratetype,
+		     int order)
+{
+	int i;
+	bool flush_tlb = false;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+
+	for (i = 0; i < 1 << order; i++) {
+		if (migratetype == MIGRATE_MOVABLE) {
+			/* GPF_HIGHUSER **
+			 * Tag the page as a user page, mark it as unmapped
+			 * in kernel space and flush the TLB if it was
+			 * previously allocated to the kernel.
+			 */
+			SetPageXpfoUser(page + i);
+			if (!TestSetPageXpfoUnmapped(page + i))
+				flush_tlb = true;
+		} else {
+			/* Tag the page as a non-user (kernel) page */
+			ClearPageXpfoUser(page + i);
+		}
+	}
+
+	if (flush_tlb)
+		set_kpte(page_address(page), page, __pgprot(0));
+
+	return flush_tlb;
+}
-- 
2.17.1

