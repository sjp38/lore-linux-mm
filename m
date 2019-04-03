Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FBEAC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 348B2206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="r+t4nMq5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 348B2206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4416F6B0269; Wed,  3 Apr 2019 13:37:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41D216B026A; Wed,  3 Apr 2019 13:37:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FA126B026B; Wed,  3 Apr 2019 13:37:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E697F6B0269
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:00 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w11so14294818iom.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=2nOjJFWIwkGcFHXwrwiTDHk2pp6mkuTCa7ocMjVImag=;
        b=pIbMaT3O7jBrBtCKScrxHohz65O8OZn39gqB5m4YiCwupopJRt0ytaQkru4P8GEgsK
         b6N2cVslm+tx6wJRxx3ikfjhyR1wZzVftbX8m6CzjsmfWcAPT6VbP6ZV5YvWRp79M4Hg
         HTfWcjlAFBAvRo65r5g2FpcTWoSWQax3ANuNlcXbP+vm5xH1nsjwPKz12qEouAN+8/pG
         I2OCyVhy+c2qOmbjKZ1k+9kGDAkTa0w6JDeXFz11qleMcy2RZzkuQOCTk0RhFl/MGOR3
         IMluk1BF8+RyPWX1i2TeSSdDRt1vKP0uuG1oHu8oWR4CZ1qLccq+xQfXjqyfjm6Ke4cZ
         M2gQ==
X-Gm-Message-State: APjAAAUufwsG8ZEcndX7Wfi6lL4OZKPl8KgQ/L47rKpXQy40DtnbI3g8
	hT9QFX/CqG8UdoXfEdG9oiF+LtzkjwT/77AdWrCd4LrlNQtlri95MS6GFX76pCEpK1/hpmUoGuP
	zpv7gHU1Zg4ZWygFezx5DDhZX5ACr5L+zKrkpUJIkniX61EPg5uptLdU2icIXt9EM/g==
X-Received: by 2002:a24:7f8f:: with SMTP id r137mr1123773itc.56.1554313020605;
        Wed, 03 Apr 2019 10:37:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG3zhwwY/Xa+Z527cVGaCX6Onx6RcVbghp+zaccxlnlUlpcMiPYKuHogd6HRKvzTQGbISx
X-Received: by 2002:a24:7f8f:: with SMTP id r137mr1123673itc.56.1554313018910;
        Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313018; cv=none;
        d=google.com; s=arc-20160816;
        b=kucHyNDwAIdV5OtUeWUh1TDOMDlLfj8wGvBXifBxNabiGf7EVCYaWbsRCIA1C5voLN
         ICFvCZwkP/nIa0uPpCpDkrL/0ZbumxXBfASnuIQQT7/SgNZJkXP+MT8IDvdifSf+nVdX
         EnGbWWU2m1bCfaAb20yiBfJjB+9JmY+0cNxgQxm3iwsU5lfGyNRW/G6J9IzzMxGQn5hG
         OEjihhPrzymrQtSEoH72tjAH+ZEqSEC8Z1lNBEKIlfhKBPmWQbB9t6Cj13H7obPWT6we
         23hWFfWYvF2DYppFPNAy4CjHfy8d8zPlMvWNK4M+pFsAkGyQHpacjahz6jog4wZBhnMy
         9s0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=2nOjJFWIwkGcFHXwrwiTDHk2pp6mkuTCa7ocMjVImag=;
        b=u7li2/xNVHc1X8RYy5e0F/d2Ei2vWxolvVtPSso6864wJU8FNM10Y6TIzrEfUG5P54
         wsJiey+TkUaSN/t6RopFfJl+QmPmXgMQtiHRjbNm341wNQ0SH01HwSiTlS0hM8645ZzT
         P4m+s4C8gZNQJzUHYH3CcBavYWxsuAs+aoWEjSmTikyY2L99r806cpi5gwFmXdM7rkLA
         gyEgDPm4gFbjSwiGibgbdAtHDbIaTWTincaVQEyTZESS+SCB0aaC1eMX+RKRP1yopR4J
         ndiTc85Ili2DOphyhwXnYkcxhsR/IzlA92pV/pWbl8ueKi571wZ7qXBYBJs/lnXPlzK3
         WBdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r+t4nMq5;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q66si8747905itb.76.2019.04.03.10.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=r+t4nMq5;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HO2kH166464;
	Wed, 3 Apr 2019 17:35:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=2nOjJFWIwkGcFHXwrwiTDHk2pp6mkuTCa7ocMjVImag=;
 b=r+t4nMq5KbsfIuHwqBZBCktClDXcFzD57iXWgb71zr5ONuOUJXo46Pj315Z99T/K07by
 iswiYdI6AZjxBFII07JF2Cjiwwhkt9tOjKf6z2jKudrDtLFUgi4KI3UQnAgm/QM4HYMe
 2JtWs2cEzgSKuNPnByTklqAaKpkJDKMx+VX6zOo2ygYx39gO2A0K09rP7ghv38FSgp/p
 j+GMWNqPEvtkJnARAk54wdWBV93ZEErHkmSJSJgvX3CLIkAWJEBMSLkIy1IlNFvbTxlr
 +vR8xgwiB2wFuNf78NNU1iEdTBIBpc7N1m/8UlRx7PIat+i2zzw3wT7UoHa0z2GMJW9R 7g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rhyvtahkw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:43 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HYC0e081772;
	Wed, 3 Apr 2019 17:35:42 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2rm8f57yp2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZVKk028584;
	Wed, 3 Apr 2019 17:35:31 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:30 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
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
Subject: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame Ownership (XPFO)
Date: Wed,  3 Apr 2019 11:34:04 -0600
Message-Id: <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
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

From: Juerg Haefliger <juerg.haefliger@canonical.com>

This patch adds basic support infrastructure for XPFO which protects
against 'ret2dir' kernel attacks. The basic idea is to enforce exclusive
ownership of page frames by either the kernel or userspace, unless
explicitly requested by the kernel. Whenever a page destined for
userspace is allocated, it is unmapped from physmap (the kernel's page
table). When such a page is reclaimed from userspace, it is mapped back
to physmap. Individual architectures can enable full XPFO support using
this infrastructure by supplying architecture specific pieces.

Additional fields in the page struct are used for XPFO housekeeping,
specifically:
  - two flags to distinguish user vs. kernel pages and to tag unmapped
    pages.
  - a reference counter to balance kmap/kunmap operations.
  - a lock to serialize access to the XPFO fields.

This patch is based on the work of Vasileios P. Kemerlis et al. who
published their work in this paper:
  http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

CC: x86@kernel.org
Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
[jsteckli@amazon.de: encode all XPFO info in struct page]
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 v9: * Do not use page extensions. Encode all xpfo information in struct
      page (Julian Stecklina).
    * Split architecture specific code into its own separate patch
    * Move kmap*() to include/linux/xpfo.h for cleaner code as suggested
      for an earlier version of this patch
    * Use irq versions of spin_lock to address possible deadlock around
      xpfo_lock caused by interrupts.
    * Incorporated various feedback provided on v6 patch way back.

v6: * use flush_tlb_kernel_range() instead of __flush_tlb_one, so we flush
      the tlb entry on all CPUs when unmapping it in kunmap
    * handle lookup_page_ext()/lookup_xpfo() returning NULL
    * drop lots of BUG()s in favor of WARN()
    * don't disable irqs in xpfo_kmap/xpfo_kunmap, export
      __split_large_page so we can do our own alloc_pages(GFP_ATOMIC) to
      pass it

 .../admin-guide/kernel-parameters.txt         |   6 +
 include/linux/highmem.h                       |  31 +---
 include/linux/mm_types.h                      |   8 +
 include/linux/page-flags.h                    |  23 ++-
 include/linux/xpfo.h                          | 147 ++++++++++++++++++
 include/trace/events/mmflags.h                |  10 +-
 mm/Makefile                                   |   1 +
 mm/compaction.c                               |   2 +-
 mm/internal.h                                 |   2 +-
 mm/page_alloc.c                               |  10 +-
 mm/page_isolation.c                           |   2 +-
 mm/xpfo.c                                     | 106 +++++++++++++
 security/Kconfig                              |  27 ++++
 13 files changed, 337 insertions(+), 38 deletions(-)
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 858b6c0b9a15..9b36da94760e 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2997,6 +2997,12 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
+	noxpfo		[XPFO] Disable eXclusive Page Frame Ownership (XPFO)
+			when CONFIG_XPFO is on. Physical pages mapped into
+			user applications will also be mapped in the
+			kernel's address space as if CONFIG_XPFO was not
+			enabled.
+
 	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
 			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
 			Some features depend on CPU0. Known dependencies are:
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index ea5cdbd8c2c3..59a1a5fa598d 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -8,6 +8,7 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 #include <linux/hardirq.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 
@@ -77,36 +78,6 @@ static inline struct page *kmap_to_page(void *addr)
 
 static inline unsigned long totalhigh_pages(void) { return 0UL; }
 
-#ifndef ARCH_HAS_KMAP
-static inline void *kmap(struct page *page)
-{
-	might_sleep();
-	return page_address(page);
-}
-
-static inline void kunmap(struct page *page)
-{
-}
-
-static inline void *kmap_atomic(struct page *page)
-{
-	preempt_disable();
-	pagefault_disable();
-	return page_address(page);
-}
-#define kmap_atomic_prot(page, prot)	kmap_atomic(page)
-
-static inline void __kunmap_atomic(void *addr)
-{
-	pagefault_enable();
-	preempt_enable();
-}
-
-#define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
-
-#define kmap_flush_unused()	do {} while(0)
-#endif
-
 #endif /* CONFIG_HIGHMEM */
 
 #if defined(CONFIG_HIGHMEM) || defined(CONFIG_X86_32)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..d17d33f36a01 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -204,6 +204,14 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+#ifdef CONFIG_XPFO
+	/* Counts the number of times this page has been kmapped. */
+	atomic_t xpfo_mapcount;
+
+	/* Serialize kmap/kunmap of this page */
+	spinlock_t xpfo_lock;
+#endif
 } _struct_page_alignment;
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 39b4494e29f1..3622e8c33522 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -101,6 +101,10 @@ enum pageflags {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
+#endif
+#ifdef CONFIG_XPFO
+	PG_xpfo_user,		/* Page is allocated to user-space */
+	PG_xpfo_unmapped,	/* Page is unmapped from the linear map */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -398,6 +402,22 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_XPFO
+PAGEFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTCLEARFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTSETFLAG(XpfoUser, xpfo_user, PF_ANY)
+#define __PG_XPFO_USER	(1UL << PG_xpfo_user)
+PAGEFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTCLEARFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTSETFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+#define __PG_XPFO_UNMAPPED	(1UL << PG_xpfo_unmapped)
+#else
+#define __PG_XPFO_USER		0
+PAGEFLAG_FALSE(XpfoUser)
+#define __PG_XPFO_UNMAPPED	0
+PAGEFLAG_FALSE(XpfoUnmapped)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
@@ -780,7 +800,8 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * alloc-free cycle to prevent from reusing the page.
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	\
-	(((1UL << NR_PAGEFLAGS) - 1) & ~__PG_HWPOISON)
+	(((1UL << NR_PAGEFLAGS) - 1) & ~__PG_HWPOISON & ~__PG_XPFO_USER & \
+	 ~__PG_XPFO_UNMAPPED)
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1UL << PG_private | 1UL << PG_private_2)
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
new file mode 100644
index 000000000000..93a1b5aceca3
--- /dev/null
+++ b/include/linux/xpfo.h
@@ -0,0 +1,147 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef _LINUX_XPFO_H
+#define _LINUX_XPFO_H
+
+#include <linux/types.h>
+#include <linux/dma-direction.h>
+#include <linux/uaccess.h>
+
+struct page;
+
+#ifdef CONFIG_XPFO
+
+DECLARE_STATIC_KEY_TRUE(xpfo_inited);
+
+/* Architecture specific implementations */
+void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
+void xpfo_flush_kernel_tlb(struct page *page, int order);
+
+void xpfo_init_single_page(struct page *page);
+
+static inline void xpfo_kmap(void *kaddr, struct page *page)
+{
+	unsigned long flags;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	if (!PageXpfoUser(page))
+		return;
+
+	/*
+	 * The page was previously allocated to user space, so
+	 * map it back into the kernel if needed. No TLB flush required.
+	 */
+	spin_lock_irqsave(&page->xpfo_lock, flags);
+
+	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
+		TestClearPageXpfoUnmapped(page))
+		set_kpte(kaddr, page, PAGE_KERNEL);
+
+	spin_unlock_irqrestore(&page->xpfo_lock, flags);
+}
+
+static inline void xpfo_kunmap(void *kaddr, struct page *page)
+{
+	unsigned long flags;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	if (!PageXpfoUser(page))
+		return;
+
+	/*
+	 * The page is to be allocated back to user space, so unmap it from
+	 * the kernel, flush the TLB and tag it as a user page.
+	 */
+	spin_lock_irqsave(&page->xpfo_lock, flags);
+
+	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
+#ifdef CONFIG_XPFO_DEBUG
+		WARN_ON(PageXpfoUnmapped(page));
+#endif
+		SetPageXpfoUnmapped(page);
+		set_kpte(kaddr, page, __pgprot(0));
+		xpfo_flush_kernel_tlb(page, 0);
+	}
+
+	spin_unlock_irqrestore(&page->xpfo_lock, flags);
+}
+
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map);
+void xpfo_free_pages(struct page *page, int order);
+
+#else /* !CONFIG_XPFO */
+
+static inline void xpfo_init_single_page(struct page *page) { }
+
+static inline void xpfo_kmap(void *kaddr, struct page *page) { }
+static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
+static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp,
+				    bool will_map) { }
+static inline void xpfo_free_pages(struct page *page, int order) { }
+
+static inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot) { }
+static inline void xpfo_flush_kernel_tlb(struct page *page, int order) { }
+
+#endif /* CONFIG_XPFO */
+
+#if (!defined(CONFIG_HIGHMEM)) && (!defined(ARCH_HAS_KMAP))
+static inline void *kmap(struct page *page)
+{
+	void *kaddr;
+
+	might_sleep();
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
+}
+
+static inline void kunmap(struct page *page)
+{
+	xpfo_kunmap(page_address(page), page);
+}
+
+static inline void *kmap_atomic(struct page *page)
+{
+	void *kaddr;
+
+	preempt_disable();
+	pagefault_disable();
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
+}
+
+#define kmap_atomic_prot(page, prot)	kmap_atomic(page)
+
+static inline void __kunmap_atomic(void *addr)
+{
+	xpfo_kunmap(addr, virt_to_page(addr));
+	pagefault_enable();
+	preempt_enable();
+}
+
+#define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
+
+#define kmap_flush_unused()	do {} while (0)
+
+#endif
+
+#endif /* _LINUX_XPFO_H */
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..6bb000bb366f 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_XPFO
+#define IF_HAVE_PG_XPFO(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_XPFO(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -105,7 +111,9 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_XPFO(PG_xpfo_user,		"xpfo_user"	)		\
+IF_HAVE_PG_XPFO(PG_xpfo_unmapped,	"xpfo_unmapped" ) 		\
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..e99e1e6ae5ae 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_XPFO) += xpfo.o
diff --git a/mm/compaction.c b/mm/compaction.c
index ef29490b0f46..fdd5d9783adb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -78,7 +78,7 @@ static void map_pages(struct list_head *list)
 		order = page_private(page);
 		nr_pages = 1 << order;
 
-		post_alloc_hook(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, __GFP_MOVABLE, false);
 		if (order)
 			split_page(page, order);
 
diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb02decf..e076e51376df 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -165,7 +165,7 @@ extern void memblock_free_pages(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
-					gfp_t gfp_flags);
+					gfp_t gfp_flags, bool will_map);
 extern int user_min_free_kbytes;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b9f577b1a2a..2e0dda1322a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1062,6 +1062,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	if (bad)
 		return false;
 
+	xpfo_free_pages(page, order);
 	page_cpupid_reset_last(page);
 	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	reset_page_owner(page, order);
@@ -1229,6 +1230,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	if (!is_highmem_idx(zone))
 		set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
+	xpfo_init_single_page(page);
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
@@ -1938,7 +1940,7 @@ static bool check_new_pages(struct page *page, unsigned int order)
 }
 
 inline void post_alloc_hook(struct page *page, unsigned int order,
-				gfp_t gfp_flags)
+				gfp_t gfp_flags, bool will_map)
 {
 	set_page_private(page, 0);
 	set_page_refcounted(page);
@@ -1947,6 +1949,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	xpfo_alloc_pages(page, order, gfp_flags, will_map);
 	set_page_owner(page, order, gfp_flags);
 }
 
@@ -1954,10 +1957,11 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 							unsigned int alloc_flags)
 {
 	int i;
+	bool needs_zero = !free_pages_prezeroed() && (gfp_flags & __GFP_ZERO);
 
-	post_alloc_hook(page, order, gfp_flags);
+	post_alloc_hook(page, order, gfp_flags, needs_zero);
 
-	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
+	if (needs_zero)
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index ce323e56b34d..d8730dd134a9 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -137,7 +137,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (isolated_page) {
-		post_alloc_hook(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, __GFP_MOVABLE, false);
 		__free_pages(page, order);
 	}
 }
diff --git a/mm/xpfo.c b/mm/xpfo.c
new file mode 100644
index 000000000000..b74fee0479e7
--- /dev/null
+++ b/mm/xpfo.c
@@ -0,0 +1,106 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/xpfo.h>
+
+#include <asm/tlbflush.h>
+
+DEFINE_STATIC_KEY_TRUE(xpfo_inited);
+EXPORT_SYMBOL_GPL(xpfo_inited);
+
+static int __init noxpfo_param(char *str)
+{
+	static_branch_disable(&xpfo_inited);
+
+	return 0;
+}
+
+early_param("noxpfo", noxpfo_param);
+
+bool __init xpfo_enabled(void)
+{
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+	else
+		return true;
+}
+
+void __meminit xpfo_init_single_page(struct page *page)
+{
+	spin_lock_init(&page->xpfo_lock);
+}
+
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map)
+{
+	int i;
+	bool flush_tlb = false;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++)  {
+#ifdef CONFIG_XPFO_DEBUG
+		WARN_ON(PageXpfoUser(page + i));
+		WARN_ON(PageXpfoUnmapped(page + i));
+		lockdep_assert_held(&(page + i)->xpfo_lock);
+		WARN_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
+		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
+			/*
+			 * Tag the page as a user page and flush the TLB if it
+			 * was previously allocated to the kernel.
+			 */
+			if ((!TestSetPageXpfoUser(page + i)) || !will_map) {
+				SetPageXpfoUnmapped(page + i);
+				flush_tlb = true;
+			}
+		} else {
+			/* Tag the page as a non-user (kernel) page */
+			ClearPageXpfoUser(page + i);
+		}
+	}
+
+	if (flush_tlb) {
+		set_kpte(page_address(page), page, __pgprot(0));
+		xpfo_flush_kernel_tlb(page, order);
+	}
+}
+
+void xpfo_free_pages(struct page *page, int order)
+{
+	int i;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++) {
+#ifdef CONFIG_XPFO_DEBUG
+		WARN_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
+
+		/*
+		 * Map the page back into the kernel if it was previously
+		 * allocated to user space.
+		 */
+		if (TestClearPageXpfoUser(page + i)) {
+			ClearPageXpfoUnmapped(page + i);
+			set_kpte(page_address(page + i), page + i,
+				 PAGE_KERNEL);
+		}
+	}
+}
diff --git a/security/Kconfig b/security/Kconfig
index e4fe2f3c2c65..3636ba7e2615 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -6,6 +6,33 @@ menu "Security options"
 
 source "security/keys/Kconfig"
 
+config ARCH_SUPPORTS_XPFO
+	bool
+
+config XPFO
+	bool "Enable eXclusive Page Frame Ownership (XPFO)"
+	depends on ARCH_SUPPORTS_XPFO
+	help
+	  This option offers protection against 'ret2dir' kernel attacks.
+	  When enabled, every time a page frame is allocated to user space, it
+	  is unmapped from the direct mapped RAM region in kernel space
+	  (physmap). Similarly, when a page frame is freed/reclaimed, it is
+	  mapped back to physmap.
+
+	  There is a slight performance impact when this option is enabled.
+
+	  If in doubt, say "N".
+
+config XPFO_DEBUG
+       bool "Enable debugging of XPFO"
+       depends on XPFO
+       help
+         Enables additional checking of XPFO data structures that help find
+	 bugs in the XPFO implementation. This option comes with a slight
+	 performance cost.
+
+	 If in doubt, say "N".
+
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
 	default n
-- 
2.17.1

