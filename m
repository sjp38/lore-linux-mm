Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CB0DC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3881206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Vj53rEyo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3881206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04A016B0274; Wed,  3 Apr 2019 13:37:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F14B76B0275; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8E766B0276; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id A32F66B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id k188so3832911yba.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=JykUAtBTCqWOFSJWEypPAtam2nSMNUtg95DLyHs89DM=;
        b=sON+MWGtS3+MF9Wnym3qCw++0vGXWdqUHZunNlyZsHwVz5Frm/93kZfK3Fdmq8PXtp
         rgGABCZVY80FOrK6eo4s4zlocm+EXk99Ngp0QokoxIDB+vf3NqE+sR5EPK6f6/BYHBf6
         UNfCjfWCaEac9krISx5Fc2Yi1ZcxvYoByvAMsDjoGLav7vandueIts7qkL7iW4246/IT
         HA13wSlHrT0Sn+XQFmN4LchglMVh5UP7K73wrNTcmA0YYyVHpz1m0ORnpk5QIByzidXg
         opdW5CN3++c2Nqobzwu7facp50iR/8rzm2UKVfSzCUpgHxZ4Hq63BRvIKnWxbBWE5NHA
         jxxA==
X-Gm-Message-State: APjAAAXNZk8uhMeLmp/FVgH/yTQ0p3rwrfVlmoWsQIz3KVMK8qf2iYZK
	MhqcaG9KPriAa4+6GPRmoPQ1XNHdvl+iVBv9GhSlH5Ay8OYJH+fPOnih23qb8/bQYdW3v5Jah+U
	chR+Yf5OxlKL3UmiPEE26PS4feUS9aNo6D5f+aqH1tD2TEReT4L+VA1oXcDMVB5hv4w==
X-Received: by 2002:a25:98c5:: with SMTP id m5mr1144430ybo.143.1554313028410;
        Wed, 03 Apr 2019 10:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn2rY1CnRrqXNH7+px0JnDH+3BG9rpOyMHETeuLlLL8bGu8msUxpsAsFLuEeIHLH3CATNg
X-Received: by 2002:a25:98c5:: with SMTP id m5mr1144345ybo.143.1554313027446;
        Wed, 03 Apr 2019 10:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313027; cv=none;
        d=google.com; s=arc-20160816;
        b=t8aZnRRc/7GBVjhT1mSqbg4CIsa9Hjz6lSQ9HUsXpcO/11nv06wthbriCVhbZuLeLJ
         LGF/VyQDECoJYhTUrNPyoBOBFndAmcGnqBDb2IYZowD9qeR6QPTdWYN7yWSBV9u8TwLI
         BdWIDRoBElc6vPfgwUdASPRcFfBv5JJXNTobUQpYjKA0t3tSAlAfoLQlX3uTSOnrF35F
         ByABLgrVzdjZnuT6vyPySZ6NnxeDofI85LYP7CoRZ4lqe7RxMZ1o2VBcYfQTCVOJHjaO
         hlJqSfQY3XD2oVrl8QSt2he+XCm4AIrpxLcZiKJl9OsOhPrSkxQoOrQ+lPmF0tmI3/En
         ay1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=JykUAtBTCqWOFSJWEypPAtam2nSMNUtg95DLyHs89DM=;
        b=I/QPNVE3Jgc+oAoBptXajEVDkbIDQ2T3UO79eKdbEuD/qBLg4Sj3bcFT4qRPBkjkFW
         IRiGS2N6A9MvYNIX5XBZwsbSTOJlGDvD9VvgMgz9kYPdlKYApUBzdjlMxF8dcwkuG2/+
         LrSc4lK36uCjQ0QRgsMIdW4J5L6+g4NvRS9eLz5Bu9eQJExKwlVqyzXehL+CE/Xs+jtz
         BnEBuOXz4PhFJz+KMyc23dyKINBkztGWSyChTBmJHznXnReDGHUWf4XzZG+1wuK6w7/v
         6kaKvAn6X8RBWdXZJU/MJu48baG61OorgE8mDvLHuOZQ5g2HpbQ6GGqKi27PLjaA3pcu
         s2dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Vj53rEyo;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 189si10434595ybw.173.2019.04.03.10.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Vj53rEyo;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNnQl166346;
	Wed, 3 Apr 2019 17:36:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=JykUAtBTCqWOFSJWEypPAtam2nSMNUtg95DLyHs89DM=;
 b=Vj53rEyoOJe9xDAKjiGECNCgQg2SQKri1UPS9G1XShke/cdscozdvEvpv/G+VVLu4xxe
 3SEbsqyIaW0o9SzqBtcLR0z3jd6uCgOAdHg8hHH3RSEs4k7HdloEX4pHYaiYW0QoLA+6
 sGuCFspAZ48Kv3DH7G+yVs8xRa321vSYhjjav8gxNROgbj7DobNvcpuMRE+EXBKgkL86
 iQ+gzC2L6MkXDpuv5qrhgjcwIZGWMOm6D7ENZBV3qENHikAMqMeGUy50jXwKJ0oTW/ta
 snZKmgrGzzf181FHwbn6/EV1yUlcAyeNPNqJPhsxLDSYR+PQ2Cf03aLdSjJUunjnHHWy QQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rhyvtahp1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:13 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZL7i152627;
	Wed, 3 Apr 2019 17:36:12 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2rm9mj6gx1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:12 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HaBO4028950;
	Wed, 3 Apr 2019 17:36:11 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:36:11 -0700
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
Subject: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
Date: Wed,  3 Apr 2019 11:34:13 -0600
Message-Id: <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

XPFO flushes kernel space TLB entries for pages that are now mapped
in userspace on not only the current CPU but also all other CPUs
synchronously. Processes on each core allocating pages causes a
flood of IPI messages to all other cores to flush TLB entries.
Many of these messages are to flush the entire TLB on the core if
the number of entries being flushed from local core exceeds
tlb_single_page_flush_ceiling. The cost of TLB flush caused by
unmapping pages from physmap goes up dramatically on machines with
high core count.

This patch flushes relevant TLB entries for current process or
entire TLB depending upon number of entries for the current CPU
and posts a pending TLB flush on all other CPUs when a page is
unmapped from kernel space and mapped in userspace. Each core
checks the pending TLB flush flag for itself on every context
switch, flushes its TLB if the flag is set and clears it.
This patch potentially aggregates multiple TLB flushes into one.
This has very significant impact especially on machines with large
core counts. To illustrate this, kernel was compiled with -j on
two classes of machines - a server with high core count and large
amount of memory, and a desktop class machine with more modest
specs. System time from "make -j" from vanilla 4.20 kernel, 4.20
with XPFO patches before applying this patch and after applying
this patch are below:

Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
make -j60 all

4.20                            950.966s
4.20+XPFO                       25073.169s      26.366x
4.20+XPFO+Deferred flush        1372.874s        1.44x

Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
make -j4 all

4.20                            607.671s
4.20+XPFO                       1588.646s       2.614x
4.20+XPFO+Deferred flush        803.989s        1.32x

This same code should be implemented for other architectures as
well once finalized.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 arch/x86/include/asm/tlbflush.h |  1 +
 arch/x86/mm/tlb.c               | 52 +++++++++++++++++++++++++++++++++
 arch/x86/mm/xpfo.c              |  2 +-
 3 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index f4204bf377fc..92d23629d01d 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -561,6 +561,7 @@ extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned int stride_shift,
 				bool freed_tables);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
+extern void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
 static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 {
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 999d6d8f0bef..cc806a01a0eb 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -37,6 +37,20 @@
  */
 #define LAST_USER_MM_IBPB	0x1UL
 
+/*
+ * A TLB flush may be needed to flush stale TLB entries
+ * for pages that have been mapped into userspace and unmapped
+ * from kernel space. This TLB flush needs to be propagated to
+ * all CPUs. Asynchronous flush requests to all CPUs can cause
+ * significant performance imapct. Queue a pending flush for
+ * a CPU instead. Multiple of these requests can then be handled
+ * by a CPU at a less disruptive time, like context switch, in
+ * one go and reduce performance impact significantly. Following
+ * data structure is used to keep track of CPUs with pending full
+ * TLB flush forced by xpfo.
+ */
+static cpumask_t pending_xpfo_flush;
+
 /*
  * We get here when we do something requiring a TLB invalidation
  * but could not go invalidate all of the contexts.  We do the
@@ -321,6 +335,16 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		__flush_tlb_all();
 	}
 #endif
+
+	/*
+	 * If there is a pending TLB flush for this CPU due to XPFO
+	 * flush, do it now.
+	 */
+	if (cpumask_test_and_clear_cpu(cpu, &pending_xpfo_flush)) {
+		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+		__flush_tlb_all();
+	}
+
 	this_cpu_write(cpu_tlbstate.is_lazy, false);
 
 	/*
@@ -803,6 +827,34 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 	}
 }
 
+void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
+{
+	struct cpumask tmp_mask;
+
+	/*
+	 * Balance as user space task's flush, a bit conservative.
+	 * Do a local flush immediately and post a pending flush on all
+	 * other CPUs. Local flush can be a range flush or full flush
+	 * depending upon the number of entries to be flushed. Remote
+	 * flushes will be done by individual processors at the time of
+	 * context switch and this allows multiple flush requests from
+	 * other CPUs to be batched together.
+	 */
+	if (end == TLB_FLUSH_ALL ||
+	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
+		do_flush_tlb_all(NULL);
+	} else {
+		struct flush_tlb_info info;
+
+		info.start = start;
+		info.end = end;
+		do_kernel_range_flush(&info);
+	}
+	cpumask_setall(&tmp_mask);
+	__cpumask_clear_cpu(smp_processor_id(), &tmp_mask);
+	cpumask_or(&pending_xpfo_flush, &pending_xpfo_flush, &tmp_mask);
+}
+
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 {
 	struct flush_tlb_info info = {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index b42513347865..638eee5b1f09 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -118,7 +118,7 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 		return;
 	}
 
-	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+	xpfo_flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
 EXPORT_SYMBOL_GPL(xpfo_flush_kernel_tlb);
 
-- 
2.17.1

