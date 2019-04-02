Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE6EC10F0C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C924206B6
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TDXlWMkb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C924206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901356B026E; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 885F66B026F; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B8916B0272; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFE4D6B026E
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:25:46 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id f1so3623611ljf.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:25:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=/43d8GqinLiNnRiU8qrBiLiEat+yAFwsrPKMABYDevc=;
        b=e8x4dsjIET7BdLmTjNpQnXHu8cWBwZL0oZfZ2ItXlw5a84eCtCvHdwpZCNBMjx8wlw
         uyjAN/2/bfXfJbTGPF2z8qsV29r0ER/Os8eN2pAbrEidzEkRaDtDXk/eSWqgtld8dRj6
         i6JvLJqjfTK2ZLLiAyqWeXI9+1j02H1i8VQrav4hICpqeu+D6n4bZRRvP4eQ6p/VJ8LI
         8/0ywc11eyjhMXzw5ERaqwN+OwR2d83tRIRNuK18QyOU+4KO8nwt9526x8yy3lqpGQYu
         xCzGKHLIO75Hni6mposSh7d49r+cWC0e1w3rzqkn0gIfkmz0VrPQxdfwglqgPYJfcj89
         PGMA==
X-Gm-Message-State: APjAAAVm5YteOk69rFuyycXrnMHegIp5bfWpjRodEyC9lsG2kski16sp
	Fnl/Jrzv1D1rtykbBhg3d7LIiU7kmOq4PwE7I/tvqfUNd41BrwjQy0UHtlhsQOirlZ1MGl411Yy
	80D1R0tczBagyzia/iNy5mzebqGqQ5ibUMuLbwvTX4HLTjvOc8FTx0zg2CAhSx608UQ==
X-Received: by 2002:a19:a40b:: with SMTP id q11mr36769123lfc.33.1554222346289;
        Tue, 02 Apr 2019 09:25:46 -0700 (PDT)
X-Received: by 2002:a19:a40b:: with SMTP id q11mr36769069lfc.33.1554222345157;
        Tue, 02 Apr 2019 09:25:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554222345; cv=none;
        d=google.com; s=arc-20160816;
        b=cTax2grN39DAw42fTImkyehzAC9KktzUIsx//3Lh+OwRu+hqcywMDfrqnSnmJdMnPI
         dO2JU6LtedzZHF/VxTeiQC3dx5xOt4w2xM3hU2iiN+KEicNN8ZP3n8BpFOWrrt8ZMBZR
         Rvg0pGVI8v3IVXs6IgjErG5vQIyDVyJxwoFJHCT6Bdtf9K90iNm58XFV56ak6WmDRDgW
         dVNtoRi/akG+IpSawxgEvKt3jlhLct+iCLTsazggJBwJs5WHLHNR6vQrv7ZjwPUPjexe
         ydPohpz+aOtLvu3GZSb7fpB6nJ3p4n3Vz3eJPXGmZZiQukBryt3EiBGp6Cez9VNrfO3F
         c+Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=/43d8GqinLiNnRiU8qrBiLiEat+yAFwsrPKMABYDevc=;
        b=hYiQPign7QNNAMZfgAJV5N3Q5XWRATVmDvo+10hBdUv15qeuCzf8vaI8w7hEnf1RLn
         7yaMj/oZ5rfnFtLfke01jQ70XnSVEA0piU5ImUq0nHVjRos7QbI92BndqCLWskXkDSZ4
         AMGLt81qU85TaJ6v9ZBXvFABJp4mF6/DhLK8kIgNhcCupdFzD5evR9EgqN40d/mysGCV
         6uSqBKMulim8yoPr65w3VW+Em8hxF7056NsPPXgyFar8FFflBSEjvKsbQNWkg4laH8OK
         C54SOM0K61iuGNBJ2uU9pzBtDfjF5mUV7aDjFVkndhBPi1vxMhZhHACKZDgGrc+VuJ6T
         TywA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDXlWMkb;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d20sor7878873ljj.14.2019.04.02.09.25.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:25:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDXlWMkb;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=/43d8GqinLiNnRiU8qrBiLiEat+yAFwsrPKMABYDevc=;
        b=TDXlWMkbRngOofXyLknkSFqq9wkR++G+6DvTLmmdDO+HXRUFoMoUOZqL5elKEF4DLJ
         2hJ9NMhDS5BZaADGyhimfmz+wdGrblxvyOnh2IcRwIVGhlBEUXwJnm9MPP29bHh6bSj5
         Ckirz2hXMCwU/hXkeov7lt4A1NOCARq5oSx2F1J+JWdR87ligTFQ1iHlJBZqGu41GpZp
         WB4QNZBi5MvthY1oB+iHdJ5EFf79848mZg/MR3QhJIqY9v86UF5HLUlp1VKQogqSTMKQ
         yTkExUBK982uutRzMqY9hDIhlZQx689/iJkoyodPsTs0JD+0op2gz8gxjFlFmpyOhPOR
         wgYg==
X-Google-Smtp-Source: APXvYqyLRe0aN9PWEEKn5LA512XPiJ9kvIak6KXspZJFqlvg//a5sxtanZRLBVNFe4LTIPNVLQh3WQ==
X-Received: by 2002:a2e:8582:: with SMTP id b2mr24365587lji.24.1554222344792;
        Tue, 02 Apr 2019 09:25:44 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id 13sm2550377lfy.2.2019.04.02.09.25.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:25:44 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RESEND PATCH 3/3] mm/vmap: add DEBUG_AUGMENT_LOWEST_MATCH_CHECK macro
Date: Tue,  2 Apr 2019 18:25:31 +0200
Message-Id: <20190402162531.10888-4-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190402162531.10888-1-urezki@gmail.com>
References: <20190402162531.10888-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This macro adds some debug code to check that vmap allocations
are happened in ascending order.

By default this option is set to 0 and not active. It requires
recompilation of the kernel to activate it. Set to 1, compile
the kernel.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1449a8c43aa2..dffc45e645e7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -323,6 +323,7 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 /*** Global kva allocator ***/
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
+#define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
 #define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
@@ -844,6 +845,44 @@ __find_vmap_lowest_match(unsigned long size,
 	return NULL;
 }
 
+#if DEBUG_AUGMENT_LOWEST_MATCH_CHECK
+#include <linux/random.h>
+
+static struct vmap_area *
+__find_vmap_lowest_linear_match(unsigned long size,
+	unsigned long align, unsigned long vstart)
+{
+	struct vmap_area *va;
+
+	list_for_each_entry(va, &free_vmap_area_list, list) {
+		if (!is_within_this_va(va, size, align, vstart))
+			continue;
+
+		return va;
+	}
+
+	return NULL;
+}
+
+static void
+__find_vmap_lowest_match_check(unsigned long size)
+{
+	struct vmap_area *va_1, *va_2;
+	unsigned long vstart;
+	unsigned int rnd;
+
+	get_random_bytes(&rnd, sizeof(rnd));
+	vstart = VMALLOC_START + rnd;
+
+	va_1 = __find_vmap_lowest_match(size, 1, vstart);
+	va_2 = __find_vmap_lowest_linear_match(size, 1, vstart);
+
+	if (va_1 != va_2)
+		pr_emerg("not lowest: t: 0x%p, l: 0x%p, v: 0x%lx\n",
+			va_1, va_2, vstart);
+}
+#endif
+
 enum alloc_fit_type {
 	NOTHING_FIT = 0,
 	FL_FIT_TYPE = 1,	/* full fit */
@@ -985,6 +1024,10 @@ __alloc_vmap_area(unsigned long size, unsigned long align,
 	if (ret)
 		return vend;
 
+#if DEBUG_AUGMENT_LOWEST_MATCH_CHECK
+	__find_vmap_lowest_match_check(size);
+#endif
+
 	return nva_start_addr;
 }
 
-- 
2.11.0

