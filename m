Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6890AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 021D6206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m6ea2Uwq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 021D6206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C1F06B026F; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94A686B0271; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 775F06B0272; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5473C6B0271
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id s11so12705049ywa.18
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=b6onsz6VNX7DtbTr5TqzUNVhpOrN6pO3jfRzW4prgsk=;
        b=doYu/AyARmrG+2JeDmBhQ1AjYLEbzMqgN2sF9R00ue+G3Q6QZsDw+0HajFwK6o3Yd5
         XwT0Swr+siSSKmAhqjPU2uGwijQyyQ6qXrqZ84+s3ha06glVley+mBStUaP/hPtsv6Wg
         PH05tUJx4hGgwra7zuB5Z65QDlvngaQxJDU3V6OlRj5VL+b+RhNhIFZLWr0i7btjH1nI
         jo1JTloiSWGdt8+E82QjyUHJyZJqnWyAMbbiTDTvW2g7LnNzruF7eOUk3P8PljKT3wIl
         6tADM/QRjCr4C3z69k9OqNMXp8BFiUdiMNY7gGZQJpv3tgnTT/cO/M5/TMlo9FLtfE+d
         +hjA==
X-Gm-Message-State: APjAAAUxx3qIY/rxQYMu8eO6+lE8Y7DrJmM5sBPJ8s3plcjshDaUO1ED
	FhbYRjvKvAVcBSVy1gqN4pfarG6wYY8TVxM8n5b+3oLfmZZqIj3H58jB5JhT4wNqDe1/qkjgOUA
	lFHa18Iwkufw2yVMuzVju4kwOCYq5CwzPFyrcX0uf8g0MVvV0PRRMqcOIIZcRbZw4YQ==
X-Received: by 2002:a25:e4c6:: with SMTP id b189mr1168070ybh.454.1554313024108;
        Wed, 03 Apr 2019 10:37:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUVzI1Nig6Qgtr8WKBhtQ/tJ/530wEIgI/WFnZyZY5ezmEpqTF/ksnwCK/6j8NhXincczG
X-Received: by 2002:a25:e4c6:: with SMTP id b189mr1167996ybh.454.1554313023167;
        Wed, 03 Apr 2019 10:37:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313023; cv=none;
        d=google.com; s=arc-20160816;
        b=SX6twYi3nkTY5hVZFbSOseXBeZYLx85OwWfNmIzp1Dts9GtH0oo706R2DjDGRR0jzi
         owKB78o4DEkITHUTtkkycE6JLSBfmNzrHlWnWyzI0DHAf7zSxnItKZZ+47oxS2Ids68d
         ewWrcY+/mD/nF/3zdawH53E58eKsTi/g9561uv3z4Y5zoB3KXFOuxgjvMcJ+ISu+hZLY
         dcN+lY5D5kkcMfJS+Y3lLKjN/sn6a3S2fDt85cy7cuLz7dA554Xs8dYAB8GqSYTre8fe
         +10LkpIy9XcY75M8r3kw+8e0ei8tOHCiyi2dB2q6tHKh3CPIxosdFrWAdMx8o7P+cCl+
         nIfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=b6onsz6VNX7DtbTr5TqzUNVhpOrN6pO3jfRzW4prgsk=;
        b=cIuLdyLoE/dNFkTvU7PPMHmyIqOuCDCWJAinOIuuBxkk80gb5ut70UgnfK79WLaToy
         hP8vfhSIRaVWMQSdLUpRJe2an6ifZIMFY6BRcMQFtH8FmoAuGs0qcA/whuLheDHPt5wo
         dzRg/hr5L1J/YPhMXZOB7Kd1lkebmJV7GXwcHSLCvG9p2vbAXnQRDbgjQszx2/bA2A4v
         sp7qOiHYRYk1kOzBanYlTVm8EdATBm09nrFpWQlLJVqF7LJCi7PgBislWE7ni2psXZ37
         AJ9j4onsUr1it0TMf9AfyGI/d9UN87DGg6qCWgD7uHlYXqdpDE1AQTFhbXMwwXbmgaPK
         hllw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m6ea2Uwq;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g5si10686231ybb.287.2019.04.03.10.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m6ea2Uwq;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNeek171670;
	Wed, 3 Apr 2019 17:35:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=b6onsz6VNX7DtbTr5TqzUNVhpOrN6pO3jfRzW4prgsk=;
 b=m6ea2UwqzBDaAmNQRgMpNsMJ0c4I7NC/WYQD9k10Ju8tN9Bh1BDehTDeYnj8QLawIjuV
 4hpLBnsVvZP3329bGZa+hG8vig6xgrCjVOyQ7jGSs90Kr+Dt/MxPIJ77p+hr2lUP1qb2
 nSz2yaRDJTsnGM2NanyqxY8wWRS5WZ+4lyPovf64GyOVZwYnqqhKm+PU5vQtz7cPPqMU
 WKKPyUr4OYpkMAEKhMm6bxwS0Iax+rXMZizx/7oJC5aHCdADQpLu4AvZHxhxOe4s8s88
 pihbXFhaMN67EolwQFVqgtHWnBMXaQJYo/bybuJH5xUH+Ejh17OR9jA2osF8nLmayDMk CQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rhwydape0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:45 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIRj110867;
	Wed, 3 Apr 2019 17:35:45 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fyev-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:45 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33HZeqd001363;
	Wed, 3 Apr 2019 17:35:40 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:39 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
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
Subject: [RFC PATCH v9 05/13] mm: add a user_virt_to_phys symbol
Date: Wed,  3 Apr 2019 11:34:06 -0600
Message-Id: <107cc547b68f044651a87ed1aa583e3526b053a6.1554248002.git.khalid.aziz@oracle.com>
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

From: Tycho Andersen <tycho@tycho.ws>

We need someting like this for testing XPFO. Since it's architecture
specific, putting it in the test code is slightly awkward, so let's make it
an arch-specific symbol and export it for use in LKDTM.

CC: linux-arm-kernel@lists.infradead.org
CC: x86@kernel.org
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v7: * make user_virt_to_phys a GPL symbol

v6: * add a definition of user_virt_to_phys in the !CONFIG_XPFO case

 arch/x86/mm/xpfo.c   | 57 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/xpfo.h |  4 ++++
 2 files changed, 61 insertions(+)

diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index 3045bb7e4659..b42513347865 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -121,3 +121,60 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
 EXPORT_SYMBOL_GPL(xpfo_flush_kernel_tlb);
+
+/* Convert a user space virtual address to a physical address.
+ * Shamelessly copied from slow_virt_to_phys() and lookup_address() in
+ * arch/x86/mm/pageattr.c
+ */
+phys_addr_t user_virt_to_phys(unsigned long addr)
+{
+	phys_addr_t phys_addr;
+	unsigned long offset;
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset(current->mm, addr);
+	if (pgd_none(*pgd))
+		return 0;
+
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return 0;
+
+	if (p4d_large(*p4d) || !p4d_present(*p4d)) {
+		phys_addr = (unsigned long)p4d_pfn(*p4d) << PAGE_SHIFT;
+		offset = addr & ~P4D_MASK;
+		goto out;
+	}
+
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return 0;
+
+	if (pud_large(*pud) || !pud_present(*pud)) {
+		phys_addr = (unsigned long)pud_pfn(*pud) << PAGE_SHIFT;
+		offset = addr & ~PUD_MASK;
+		goto out;
+	}
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return 0;
+
+	if (pmd_large(*pmd) || !pmd_present(*pmd)) {
+		phys_addr = (unsigned long)pmd_pfn(*pmd) << PAGE_SHIFT;
+		offset = addr & ~PMD_MASK;
+		goto out;
+	}
+
+	pte =  pte_offset_kernel(pmd, addr);
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
+	offset = addr & ~PAGE_MASK;
+
+out:
+	return (phys_addr_t)(phys_addr | offset);
+}
+EXPORT_SYMBOL_GPL(user_virt_to_phys);
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index c1d232da7ee0..5d8d06e4b796 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -89,6 +89,8 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page)
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map);
 void xpfo_free_pages(struct page *page, int order);
 
+phys_addr_t user_virt_to_phys(unsigned long addr);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_init_single_page(struct page *page) { }
@@ -102,6 +104,8 @@ static inline void xpfo_free_pages(struct page *page, int order) { }
 static inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot) { }
 static inline void xpfo_flush_kernel_tlb(struct page *page, int order) { }
 
+static inline phys_addr_t user_virt_to_phys(unsigned long addr) { return 0; }
+
 #endif /* CONFIG_XPFO */
 
 #if (!defined(CONFIG_HIGHMEM)) && (!defined(ARCH_HAS_KMAP))
-- 
2.17.1

