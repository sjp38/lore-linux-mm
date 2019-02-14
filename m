Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 509F3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01E0C218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Eq0NRf9C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01E0C218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 390428E000B; Wed, 13 Feb 2019 19:02:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368A28E0005; Wed, 13 Feb 2019 19:02:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11C978E000D; Wed, 13 Feb 2019 19:02:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C52A28E000B
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:58 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f5so2878506pgh.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=lijI2dkmHOz8IBbMljD0kgh/GfNNHRB/Ww5ZCLiDpC8=;
        b=PQpXkCFKv11Pc2WsTE42kzC4WJkmmr+KY2Lk85LInIUxtKrrPKX/z2X2rp6VDM2rYf
         VvHQWr8UHFdTONiUzIsE+XLLL1BCwvv7yCdcpH406VeKZcq6M8hG42Ox6xlHlgKBz9eM
         a8iGPd/Q/jnSZ0u68LAA4Jj556yL2mTPKGZcjc6WgWS1sX/HLc3WYyMh5HkDBVMVJKHN
         G+Pr6Lsh7HJ084rap09+w+CqJMqUMatIL5lPRd6/SkyjA/bjkDWc2nRogBpW/seglBCK
         /WZqObiL08z167YIIWnwFKzBdynwpkw96fcBGf/vOuAn4pxLhLfpgFrZannPjLyrKVAU
         dMpw==
X-Gm-Message-State: AHQUAuZhWYGASrUglVaqFRWHV7+Pa32YqBzVePpBgu8yJbX/UX5epJF8
	17qK/Pw+P+FHzFX7bG92Bn2u6+l/BS6cO1/fZcBwZKWTmhuntRvNliyzTNxpMlipM0w7xMXQXPQ
	Bj5sSQKeuXeF7aMM0ihkkMIzU0gQxRuTnRsXxwPglQre1/yUub+r0U1ek7vflM/Ordg==
X-Received: by 2002:a63:134f:: with SMTP id 15mr824723pgt.19.1550102578416;
        Wed, 13 Feb 2019 16:02:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbRT1ESkPwtpXFfnAPI4TixmN1AbfGxXFmHG3DaSLL/PrUznMDITRhuS9y79sWI+ecDhZtF
X-Received: by 2002:a63:134f:: with SMTP id 15mr824641pgt.19.1550102577486;
        Wed, 13 Feb 2019 16:02:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102577; cv=none;
        d=google.com; s=arc-20160816;
        b=NhhcThI1p//ScKGoOG5tO/V5U6KFPvYUzH8r+nsVyu2T5ikCMajllgSjA3PcEwwJx3
         MST1fLoW5NgdUPU9PBeOnmhaTZMooBKw7m6TuNOHrjnR3Pmdhb7hyUzl+vOOl7ABU+J2
         KztSFWo+Wvd6mQmVI+t4nShdYLBYtuyMEhHFLc3PXHfQw1DyjXu2VSDyz0KrlVOZWb+l
         z0oA7J3VKJIgcQjkFKhVU+9odUVKE3+aJbnES0essO3zc7yLoQFlyd/4cVbJJH6vZeEJ
         g1rLtcZ2f3DyoGjJ1Wq1GKCkKGiUGetrJdmKcheeeNqvDAh/WISOnXk1vlgojseQc9Wx
         Fvvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=lijI2dkmHOz8IBbMljD0kgh/GfNNHRB/Ww5ZCLiDpC8=;
        b=dQJISXBH8g9kyj3gJbtl/6D/ZWRZUsDJNhyoRurmzFX4rpN75fmbQL/KsugGM4VMiV
         RvFOBg8Yo6Z4Fa5I+c2rbnO5UvvP2PEseFDa3/rkqIygfgNWHP4+dAWbEC5v7ECXX7dx
         sN/7uDMefgPHUsQ8ol26RLpwGTggB796bJhvyVSzDeTCE9ytX2fy/tkMd2OSEczfzON/
         b2LjuXnEUUcrUZcqD6TrUYYonWjmatbwFneg7F3Ia5DFlc1hJxdJknvfEc5J66SHCeo2
         BHFe5269tRfNhAM5QxPSEyHjzXOUXGRrK7gVpwTybS7ACrnWBISKL/xSXI9MB2xLsM1v
         WgSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Eq0NRf9C;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u10si678993pgi.515.2019.02.13.16.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:57 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Eq0NRf9C;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNworQ099417;
	Thu, 14 Feb 2019 00:02:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=lijI2dkmHOz8IBbMljD0kgh/GfNNHRB/Ww5ZCLiDpC8=;
 b=Eq0NRf9CvVjMRyqL/pJwd5gMUZxni+bHvlB5+zwob5e+xiwZT4ra0AyBxJ92DivdFLna
 97cYTFa2qe9QQ6wYiXHornwjF1eTBScwRD03REBGbSCxrGe1sHulQ2gDVu4xX3mxM/36
 3SvBa2fAgAWdU0U1FEda7/JATU3IVFLn4IveEsG+K9h5CqxCBFKvEGRJGGdkfDkYamdp
 PsnFndFcwiVrKpuBYeXNhI81MuZO4NIfCeGp/zunHR7sbKkLh0NDGuO1bP7hoZRAZp8q
 tczxkn156C41JsFvXIo8bWbOeUspWxI2rXu9qB8VJta8M6C6Ic/459RKF/2UsrhhQ7Ps Gw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qhree55nh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:28 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02R97032757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:27 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E02RfT018893;
	Thu, 14 Feb 2019 00:02:27 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:26 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH v8 13/14] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
Date: Wed, 13 Feb 2019 17:01:36 -0700
Message-Id: <98134cb73e911b2f0b59ffb76243a7777963d218.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
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

This patch could use more optimization. Batching more TLB entry
flushes, as was suggested for earlier version of these patches,
can help reduce these cases. This same code should be implemented
for other architectures as well once finalized.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/x86/include/asm/tlbflush.h |  1 +
 arch/x86/mm/tlb.c               | 38 +++++++++++++++++++++++++++++++++
 arch/x86/mm/xpfo.c              |  2 +-
 3 files changed, 40 insertions(+), 1 deletion(-)

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
index 03b6b4c2238d..c907b643eecb 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -35,6 +35,15 @@
  */
 #define LAST_USER_MM_IBPB	0x1UL
 
+/*
+ * When a full TLB flush is needed to flush stale TLB entries
+ * for pages that have been mapped into userspace and unmapped
+ * from kernel space, this TLB flush will be delayed until the
+ * task is scheduled on that CPU. Keep track of CPUs with
+ * pending full TLB flush forced by xpfo.
+ */
+static cpumask_t pending_xpfo_flush;
+
 /*
  * We get here when we do something requiring a TLB invalidation
  * but could not go invalidate all of the contexts.  We do the
@@ -319,6 +328,15 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		__flush_tlb_all();
 	}
 #endif
+
+	/* If there is a pending TLB flush for this CPU due to XPFO
+	 * flush, do it now.
+	 */
+	if (cpumask_test_and_clear_cpu(cpu, &pending_xpfo_flush)) {
+		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+		__flush_tlb_all();
+	}
+
 	this_cpu_write(cpu_tlbstate.is_lazy, false);
 
 	/*
@@ -801,6 +819,26 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 	}
 }
 
+void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
+{
+	struct cpumask tmp_mask;
+
+	/* Balance as user space task's flush, a bit conservative */
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
+	cpumask_clear_cpu(smp_processor_id(), &tmp_mask);
+	cpumask_or(&pending_xpfo_flush, &pending_xpfo_flush, &tmp_mask);
+}
+
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 {
 	struct flush_tlb_info info = {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index e13b99019c47..d3833532bfdc 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -115,7 +115,7 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 		return;
 	}
 
-	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+	xpfo_flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
 
 /* Convert a user space virtual address to a physical address.
-- 
2.17.1

