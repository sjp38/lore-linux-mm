Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD2CFC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72E6A20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72E6A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3EA8E0017; Wed,  6 Mar 2019 10:51:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 471318E0015; Wed,  6 Mar 2019 10:51:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3875C8E0017; Wed,  6 Mar 2019 10:51:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 112538E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:35 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id s8so11783930qth.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=/6x7h3dclR7FQQEq1XIxiCiHOLJMfARu3lc5hJL2REw=;
        b=IfY144sKC4rXzPrU8ILfxUJTE/wfIHmAGihp+T6yyD6Jx/FRuavR6HeTeP1NU6yiEC
         ect7gbQaMIU5MZPtn7xYN2gmf+ARQC6jBVsL711BrsTeY3FeyT1DwHHaLTAU5bf6XH3g
         kLm9q6NhDXhCAnCvc1GpPY68K2voB8h4UHFCfU7FXu4rCHxKH/e1tB8U4TudrensQsA5
         xuv4PJG63GhPhgEFcDj+2yT+ta61F3yeUvx0FvTu7tx1HsVciY0jgWfEfy5+viAE8pBP
         AO/y04o4eyYX1Lq2PfYq0cYSkzDAmV+WQ9rHbtvj4oNyBf34ky3Q2YR3VgA0p/r9Uq08
         qjPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSvt8UKkbSxzZ8MMZdKv3qLhqb5nhg6dB4lfLqBVQTHFLJQcOt
	ALYaxyWTWrjVPNfBwd3gx9RIt23fvEWx9eK2NpEeoOORjseK/rZppDwJgEfW0v8zHw2wcH1mRrE
	bW3sGLeUfdPU8Ua2YDY5T3tbjKBk096dCm8/wWUIqWHKEAQQfoHV+a+NxdFo+24bVsA==
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr6705870qvc.235.1551887494834;
        Wed, 06 Mar 2019 07:51:34 -0800 (PST)
X-Google-Smtp-Source: APXvYqx15peAHrw8ogrF+GPwWAq0NOYcEUA5fAvyYYb5yGr5LrI1Dd896IVvQpfI3gfggLn3wEBn
X-Received: by 2002:a0c:ae78:: with SMTP id z53mr6705799qvc.235.1551887493643;
        Wed, 06 Mar 2019 07:51:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887493; cv=none;
        d=google.com; s=arc-20160816;
        b=DHKg1X5+HzxpjB6LWR2+EEyyV0o5RY+u4Nh7Q0LcdkKhFIe5BiFo48Z7j+W45MseL1
         +G4BQh6qUcUsiDziyiWGqdptpeR4js/4UEQ9DCBLCF+2/TYGuT9GaQeRDZ76Flvt9VrB
         q0FbwuF2L8/tA0jzbq2aiSbtKHgfe47FCxRg3UWJHGDLp9FWj5blVTLKQFCficxY5/at
         XDd+bwJp5+peVQEnWc0KX8OIS3/Ns0L4MHDFFPyTTZxuD/hTRfpr3BgoUPymImhipIGj
         5XDDg2NoTi4nc6fe6DZRh9BOP/f8Ohj2iPfcWyOFp39U/YrUMUwWpopHRPfMB4O0Pjt8
         WA6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=/6x7h3dclR7FQQEq1XIxiCiHOLJMfARu3lc5hJL2REw=;
        b=Gg6/oemDfz+fdxROCkbM6XAUlQD/tqOrtht2sGugD1pLEuIKosA8ArMPjhvPF/F+7F
         nmH263xb3TWXdkRYiRxT8+6Ptep//V4oCCFO1BDQUxiw44PSjKO2JzeneRa7wPuPEexg
         Bt5TnbPsE/vDcNz6zf6mqtDbLo1PzPiM9lbjkYs57hWdbfG5P+Zwfy032LMheu57mgTK
         fMZSJdxJ49OXO8hU83j2dP+lqDnL6asYBCv6iDWd+XgKlV7cnEhfc40EKWw07AYFQY9U
         fyxtm/zd/T+4Cp0oqmLwD4eIr33HCZD6cSuxHtYfNuBpIOmDCcyCrjWvp/xlJIOPH7oj
         t3Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si1168704qtc.181.2019.03.06.07.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:33 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B4A3DE6A88;
	Wed,  6 Mar 2019 15:51:32 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3078A1001DCE;
	Wed,  6 Mar 2019 15:51:31 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v9 6/6] KVM: Adding tracepoints for guest free page hinting
Date: Wed,  6 Mar 2019 10:50:48 -0500
Message-Id: <20190306155048.12868-7-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Mar 2019 15:51:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables to track the pages freed by the guest and
the pages isolated by the page hinting code through kernel
tracepoints.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 include/trace/events/kmem.h | 62 +++++++++++++++++++++++++++++++++++++
 virt/kvm/page_hinting.c     | 12 +++++++
 2 files changed, 74 insertions(+)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eb57e3037deb..0bef31484cf8 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -315,6 +315,68 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->change_ownership)
 );
 
+TRACE_EVENT(guest_free_page,
+	    TP_PROTO(unsigned long pfn, unsigned int order),
+
+	TP_ARGS(pfn, order),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned int, order)
+	),
+
+	TP_fast_assign(
+		__entry->pfn            = pfn;
+		__entry->order          = order;
+	),
+
+	TP_printk("pfn=%lu order=%d",
+		  __entry->pfn,
+		  __entry->order)
+);
+
+TRACE_EVENT(guest_isolated_page,
+	    TP_PROTO(unsigned long pfn, unsigned int order),
+
+	TP_ARGS(pfn, order),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned int, order)
+	),
+
+	TP_fast_assign(
+		__entry->pfn            = pfn;
+		__entry->order          = order;
+	),
+
+	TP_printk("pfn=%lu order=%u",
+		  __entry->pfn,
+		  __entry->order)
+);
+
+TRACE_EVENT(guest_captured_page,
+	    TP_PROTO(unsigned long pfn, unsigned int order, int idx),
+
+	TP_ARGS(pfn, order, idx),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned int, order)
+		__field(int, idx)
+	),
+
+	TP_fast_assign(
+		__entry->pfn		= pfn;
+		__entry->order		= order;
+		__entry->idx		= idx;
+	),
+
+	TP_printk("pfn=%lu order=%u array_index=%d",
+		  __entry->pfn,
+		  __entry->order,
+		  __entry->idx)
+);
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
index 5980682e0b86..dc72f1947751 100644
--- a/virt/kvm/page_hinting.c
+++ b/virt/kvm/page_hinting.c
@@ -4,6 +4,7 @@
 #include <linux/kvm_host.h>
 #include <linux/kernel.h>
 #include <linux/sort.h>
+#include <trace/events/kmem.h>
 
 /*
  * struct guest_free_pages- holds array of guest freed PFN's along with an
@@ -178,6 +179,8 @@ static void guest_free_page_hinting(void)
 
 				ret = __isolate_free_page(page, buddy_order);
 				if (ret) {
+					trace_guest_isolated_page(pfn,
+								  buddy_order);
 					isolated_pages_obj[hyp_idx].pfn = pfn;
 					isolated_pages_obj[hyp_idx].order =
 								buddy_order;
@@ -198,6 +201,8 @@ static void guest_free_page_hinting(void)
 					unsigned long buddy_pfn =
 						page_to_pfn(buddy_page);
 
+					trace_guest_isolated_page(buddy_pfn,
+								  buddy_order);
 					isolated_pages_obj[hyp_idx].pfn =
 								buddy_pfn;
 					isolated_pages_obj[hyp_idx].order =
@@ -255,9 +260,12 @@ void guest_free_page_enqueue(struct page *page, int order)
 	local_irq_save(flags);
 	hinting_obj = this_cpu_ptr(&free_pages_obj);
 	l_idx = hinting_obj->free_pages_idx;
+	trace_guest_free_page(page_to_pfn(page), order);
 	if (l_idx != MAX_FGPT_ENTRIES) {
 		if (PageBuddy(page) && page_private(page) >=
 		    FREE_PAGE_HINTING_MIN_ORDER) {
+			trace_guest_captured_page(page_to_pfn(page), order,
+						  l_idx);
 			hinting_obj->free_page_arr[l_idx] = page_to_pfn(page);
 			hinting_obj->free_pages_idx += 1;
 		} else {
@@ -268,7 +276,11 @@ void guest_free_page_enqueue(struct page *page, int order)
 			    !if_exist(buddy_page)) {
 				unsigned long buddy_pfn =
 					page_to_pfn(buddy_page);
+				unsigned int buddy_order =
+					page_private(buddy_page);
 
+				trace_guest_captured_page(buddy_pfn,
+							  buddy_order, l_idx);
 				hinting_obj->free_page_arr[l_idx] =
 							buddy_pfn;
 				hinting_obj->free_pages_idx += 1;
-- 
2.17.2

