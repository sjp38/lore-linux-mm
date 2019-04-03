Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B80D7C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CC2C206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uA/GfXn2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CC2C206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6026B026C; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332956B026B; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06F016B026C; Wed,  3 Apr 2019 13:37:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB67A6B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:01 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id k65so13055731ybc.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=+01mLH7UeRlyUX9m4clHTbWXXa1hEWoneLzdofN2ooQ=;
        b=WXJLdD1hAHrvK2RnsONH6+cQA8pn4neko6473BSh4bLpH9VJY24hqpFXamBvygCI3s
         jPPOkHYPgbcz5aN9l92Pa7Nf1RA+/QjabeV2rxq9kdGL2IEDsg32oXfd89C6i4jU+iv0
         Z7M/zwqOSmfPlDkAVGC8KXC3omwdG8WkFGWgsOla01NK8Qtdq9jn1j8OYL5A7pRSJK/3
         iIbM4b6z/t3eSlzJ78N1rfH8UgF07NdMq+mbbBGpt2Ge03aOsn+DEAc8W3pbXhqWpFNP
         0nTSKz2nu9bfRAZeP3KYll8nD2x/qaDBD/lA0USy9KFbKEYvtSsUrsdA43vbp/sH1Aec
         BxOA==
X-Gm-Message-State: APjAAAXigGPM3415xogqiP7CbCWpf8djkmIIHMJ1wIMmQEX+GVePxgUw
	3vUCvqVxCtjggZwydx5rgcr0QH/pcPLaVyJ40xDucYCYWg1g+mTWNr5N2XqTxr7I+hbErgYrW/0
	f1LtgohCFwjoPRAM/iiN4LFwU7ZUHOc/765+DVAUEsPuk/d2s42KnREwCGE1QMronlQ==
X-Received: by 2002:a25:bbc2:: with SMTP id c2mr1196903ybk.356.1554313021533;
        Wed, 03 Apr 2019 10:37:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznKmWJFUBPRFR4TC0P99xt6TZ4cyMGkjoWBHgBE1tWO1ZOm42hRNgF1VTZynmXDzr8LpoA
X-Received: by 2002:a25:bbc2:: with SMTP id c2mr1196800ybk.356.1554313020434;
        Wed, 03 Apr 2019 10:37:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313020; cv=none;
        d=google.com; s=arc-20160816;
        b=N8rbAkUmK/8bBk4TShDOTf2szCIgT7AqpANmYYwuCdSWGXq3nlZWB6DcOKwMenOHSh
         deXUP/Mkerma/3lb9nh41hX917d0NKhG4wZ2R+ITTvpHs0EwCQkG5y7VF+3prtSsJijm
         ijcH6DbcfzIlqMJ/hn3wkUTxEyPT55evnJDqJC1oTaW1bzn9tvG/vTbdSyh5sw14lZAR
         8TNqRM6UjL9/rgTIj+c8pBfXzi/ESsk75UM2/RRYwi4cnYhXCB70L43Cjc51Zjmdf9mi
         ns/7Gq9dL9XeNnxt+2JDmj87Ho9X8N6FKbZOfIjSVtt+vFQ8KEizf6SuGAuXWnolNUsR
         0s8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=+01mLH7UeRlyUX9m4clHTbWXXa1hEWoneLzdofN2ooQ=;
        b=YIyK9MB0eNeZXNWFSpbdbM6ZwvxUlYOUNdvaKi6f2T8CWdG7dX2rSBqBckTCJ7TwyG
         fZ/ia9y4tetdcARbhJzDM8AAWG59GGiNCJFX5Mk6z9KAnFmR74L6TOD9VUTkjfRarUkH
         hlqGejDita3NPYQ9rx54pg0lvP2eXrQN3rR9f2yiPxub635wDnICRCW/5+Z5MaENdGwC
         /Wb8N2+QojSRcdWDKWyLcGZYapqnxtbeVaZ4rUuTNWR9R9EfbsJZwkaq35htyTcjWU+X
         YeRB+CdbcmXpuGv/+I0l4VVdpm9wmu39t9Lgqt4EUKd4IK5oa2dcSssnEpcR7D4H15Dl
         GxVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="uA/GfXn2";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id s187si3340975ybf.317.2019.04.03.10.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="uA/GfXn2";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNml0172016;
	Wed, 3 Apr 2019 17:35:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=+01mLH7UeRlyUX9m4clHTbWXXa1hEWoneLzdofN2ooQ=;
 b=uA/GfXn2tZZmE7mbGgEjJtH6lkX7duJMRcKDROSU1jH8FAus0LkOk3aZo51FvqFswZ/l
 uAJ1y7abrVRzgsC2B86iaQT35HVOnjmEXz3KKtMfg647l24qTnwuLISV3AM22cHm+G8r
 7BQ+BB4Rmk0UCL9EOGF2+mLd/4ZcZ3EvofXyofppe5A3iPWuAiazort95ATH7khXJvlW
 VgR+opBTIGKzeN/v1eHhAbWrlDrqdR4tIA8lfX7qM/V+5CdnokgKycQo83eFdt7Nz2w5
 sJ10GZj9aZx9sUyw2MsjHTbydAnB2K9QWB6v6aWJQ0p9ODNrYhlK4CgSamr9LWXaA1ow 3g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2rhwydapdw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:43 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZgwL087983;
	Wed, 3 Apr 2019 17:35:42 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2rm8f67xu5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZZq8001238;
	Wed, 3 Apr 2019 17:35:35 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:35 -0700
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
Subject: [RFC PATCH v9 04/13] xpfo, x86: Add support for XPFO for x86-64
Date: Wed,  3 Apr 2019 11:34:05 -0600
Message-Id: <c15e7d09dfe3dfdb9947d39ed0ddd6573ff86dbf.1554248002.git.khalid.aziz@oracle.com>
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

This patch adds support for XPFO for x86-64. It uses the generic
infrastructure in place for XPFO and adds the architecture specific
bits to enable XPFO on x86-64.

CC: x86@kernel.org
Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 .../admin-guide/kernel-parameters.txt         |  10 +-
 arch/x86/Kconfig                              |   1 +
 arch/x86/include/asm/pgtable.h                |  26 ++++
 arch/x86/mm/Makefile                          |   2 +
 arch/x86/mm/pageattr.c                        |  23 +---
 arch/x86/mm/xpfo.c                            | 123 ++++++++++++++++++
 include/linux/xpfo.h                          |   2 +
 7 files changed, 162 insertions(+), 25 deletions(-)
 create mode 100644 arch/x86/mm/xpfo.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 9b36da94760e..e65e3bc1efe0 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2997,11 +2997,11 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
-	noxpfo		[XPFO] Disable eXclusive Page Frame Ownership (XPFO)
-			when CONFIG_XPFO is on. Physical pages mapped into
-			user applications will also be mapped in the
-			kernel's address space as if CONFIG_XPFO was not
-			enabled.
+	noxpfo		[XPFO,X86-64] Disable eXclusive Page Frame
+			Ownership (XPFO) when CONFIG_XPFO is on. Physical
+			pages mapped into user applications will also be
+			mapped in the kernel's address space as if
+			CONFIG_XPFO was not enabled.
 
 	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
 			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..122786604252 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -209,6 +209,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_SUPPORTS_XPFO		if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..5c0e1581fa56 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1437,6 +1437,32 @@ static inline bool arch_has_pfn_modify_check(void)
 	return boot_cpu_has_bug(X86_BUG_L1TF);
 }
 
+/*
+ * The current flushing context - we pass it instead of 5 arguments:
+ */
+struct cpa_data {
+	unsigned long	*vaddr;
+	pgd_t		*pgd;
+	pgprot_t	mask_set;
+	pgprot_t	mask_clr;
+	unsigned long	numpages;
+	unsigned long	curpage;
+	unsigned long	pfn;
+	unsigned int	flags;
+	unsigned int	force_split		: 1,
+			force_static_prot	: 1;
+	struct page	**pages;
+};
+
+
+int
+should_split_large_page(pte_t *kpte, unsigned long address,
+			struct cpa_data *cpa);
+extern spinlock_t cpa_lock;
+int
+__split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
+		   struct page *base);
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..93b0fdaf4a99 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
+
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 14e6119838a6..530b5df0617e 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -28,23 +28,6 @@
 
 #include "mm_internal.h"
 
-/*
- * The current flushing context - we pass it instead of 5 arguments:
- */
-struct cpa_data {
-	unsigned long	*vaddr;
-	pgd_t		*pgd;
-	pgprot_t	mask_set;
-	pgprot_t	mask_clr;
-	unsigned long	numpages;
-	unsigned long	curpage;
-	unsigned long	pfn;
-	unsigned int	flags;
-	unsigned int	force_split		: 1,
-			force_static_prot	: 1;
-	struct page	**pages;
-};
-
 enum cpa_warn {
 	CPA_CONFLICT,
 	CPA_PROTECT,
@@ -59,7 +42,7 @@ static const int cpa_warn_level = CPA_PROTECT;
  * entries change the page attribute in parallel to some other cpu
  * splitting a large page entry along with changing the attribute.
  */
-static DEFINE_SPINLOCK(cpa_lock);
+DEFINE_SPINLOCK(cpa_lock);
 
 #define CPA_FLUSHTLB 1
 #define CPA_ARRAY 2
@@ -876,7 +859,7 @@ static int __should_split_large_page(pte_t *kpte, unsigned long address,
 	return 0;
 }
 
-static int should_split_large_page(pte_t *kpte, unsigned long address,
+int should_split_large_page(pte_t *kpte, unsigned long address,
 				   struct cpa_data *cpa)
 {
 	int do_split;
@@ -926,7 +909,7 @@ static void split_set_pte(struct cpa_data *cpa, pte_t *pte, unsigned long pfn,
 	set_pte(pte, pfn_pte(pfn, ref_prot));
 }
 
-static int
+int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 		   struct page *base)
 {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
new file mode 100644
index 000000000000..3045bb7e4659
--- /dev/null
+++ b/arch/x86/mm/xpfo.c
@@ -0,0 +1,123 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+
+#include <asm/tlbflush.h>
+
+extern spinlock_t cpa_lock;
+
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	unsigned int level;
+	pgprot_t msk_clr;
+	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
+
+	if (unlikely(!pte)) {
+		WARN(1, "xpfo: invalid address %p\n", kaddr);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		set_pte_atomic(pte, pfn_pte(page_to_pfn(page),
+			       canon_pgprot(prot)));
+		break;
+	case PG_LEVEL_2M:
+	case PG_LEVEL_1G: {
+		struct cpa_data cpa = { };
+		int do_split;
+
+		if (level == PG_LEVEL_2M)
+			msk_clr = pmd_pgprot(*(pmd_t *)pte);
+		else
+			msk_clr = pud_pgprot(*(pud_t *)pte);
+
+		cpa.vaddr = kaddr;
+		cpa.pages = &page;
+		cpa.mask_set = prot;
+		cpa.mask_clr = msk_clr;
+		cpa.numpages = 1;
+		cpa.flags = 0;
+		cpa.curpage = 0;
+		cpa.force_split = 0;
+
+
+		do_split = should_split_large_page(pte, (unsigned long)kaddr,
+						   &cpa);
+		if (do_split) {
+			struct page *base;
+
+			base = alloc_pages(GFP_ATOMIC, 0);
+			if (!base) {
+				WARN(1, "xpfo: failed to split large page\n");
+				break;
+			}
+
+			if (!debug_pagealloc_enabled())
+				spin_lock(&cpa_lock);
+			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr,
+						base) < 0) {
+				__free_page(base);
+				WARN(1, "xpfo: failed to split large page\n");
+			}
+			if (!debug_pagealloc_enabled())
+				spin_unlock(&cpa_lock);
+		}
+
+		break;
+	}
+	case PG_LEVEL_512G:
+		/* fallthrough, splitting infrastructure doesn't
+		 * support 512G pages.
+		 */
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+	}
+
+}
+EXPORT_SYMBOL_GPL(set_kpte);
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	int level;
+	unsigned long size, kaddr;
+
+	kaddr = (unsigned long)page_address(page);
+
+	if (unlikely(!lookup_address(kaddr, &level))) {
+		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr,
+		     level);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		size = PAGE_SIZE;
+		break;
+	case PG_LEVEL_2M:
+		size = PMD_SIZE;
+		break;
+	case PG_LEVEL_1G:
+		size = PUD_SIZE;
+		break;
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+		return;
+	}
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
+EXPORT_SYMBOL_GPL(xpfo_flush_kernel_tlb);
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 93a1b5aceca3..c1d232da7ee0 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -25,6 +25,8 @@ struct page;
 
 #ifdef CONFIG_XPFO
 
+#include <linux/dma-mapping.h>
+
 DECLARE_STATIC_KEY_TRUE(xpfo_inited);
 
 /* Architecture specific implementations */
-- 
2.17.1

