Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F6E1C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6826216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6826216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5CF36B000E; Mon, 20 May 2019 10:00:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBDAF6B0266; Mon, 20 May 2019 10:00:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B860E6B0010; Mon, 20 May 2019 10:00:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5639A6B000D
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:28 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m2so2424659ljj.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=UT1yo5i/SDXJHxF74x02x37C8rHVZsb1Uhc8HALyM8A=;
        b=B261YOBk90cGiJS6/GoHotqE4hOpkNOFeTC74v47+NkTudtfL0DJ8JpT3++TejnCyR
         63L2R9764bfRJVUudJ6+Wmj2PYoVYM+EHJfq9K3LbW74zyI7VHtCJFs/w8NDMEyhV5mZ
         nQyOGGeqRp9Ye2iOg9nxfZSLssqe7+vdxKT57KvVHZ3ZZS0AfBYN02/9LT5cvDBA+Fwm
         tptnMOSjiJf+Rw4YywVF/hdgnxNGH5ltNUM/IipHIzZ+iteWjkRdcIVLF4PzYMZmK5Fe
         wtoCE4DAEIOdbBRzuy4ePITDNVas61RsS4KrOSpTAAWj2nocU+95LWP5alQiIixHAgfg
         EcpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAX29hr2l98vfZinFHd86Ey9WDIIBOrZdZl1X6IWvVbGMXYZXkGr
	dl4K1ndr0kvlKHGPWgLwYwKCGtYV3j2BTndcqODjR/iEXlnckq0u4iPWt01DNrqx5/5gVkccKtA
	Eo9AA1SRsBcDdKtAsyR0fVR1IfFGju4Hat4dyRdaHDJjpKw73KjKOnqXUBCl/xBE4bg==
X-Received: by 2002:ac2:48a8:: with SMTP id u8mr13965813lfg.141.1558360827731;
        Mon, 20 May 2019 07:00:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrSu5iln8tIfEzGyn4baM8KwLrgDXLIjp8slx8BYhrOtiH9SiL/ibRQeQOaQMBwkCeGHUi
X-Received: by 2002:ac2:48a8:: with SMTP id u8mr13965770lfg.141.1558360826792;
        Mon, 20 May 2019 07:00:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360826; cv=none;
        d=google.com; s=arc-20160816;
        b=r+QWwc1r49JMjKwgxRGZ0WYwSyeqByqcjDlwzD4tsw1JpoSOORhb11EUk+1jxeF42L
         DW5Xn8IY6p4SDheBD8aW2BSIyejN0OnOLDhPSyJ1vOAngcQwenBuO6mNQ7og/dVJZcGk
         fBxXiddFhySZmgy37jcEbPIRcMo/M1jeDJdD9HpTLVnF6vhJUFVyYVtgYiprCVEkllgQ
         FbqiW5IBSGYU9p+YU71HPNIQN4P4IPgOX9AIjRbDbS4rTfckoMuBK/RrKXCD+9LA+HqQ
         BC/VF3fMh2eVIUr7K6lDrj+0R3y2URbPVJEzbxRQfflpFF366iTp7mFi/he14YACnyxl
         Husw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=UT1yo5i/SDXJHxF74x02x37C8rHVZsb1Uhc8HALyM8A=;
        b=MhuHg6JjOrLjAS880eiRUcZdtD+ks3wPMfApXB/u3JtkJAEZsBId/HszdkBMBBs0P8
         3w32nXXJztH1NfdCyGelR5Tu5UwEFuETUggidbq69M/pzBVLf/7Uyih45dZ+3hGqrOeK
         kMBwy7m0+MigKbbxNTaWuOpGvJtmXWv63krUzpfMaFGaJzuiqYTmzvtzR2AqC2VmU2wX
         s3ynCP/P0nVH/TuAodrDZO5HUNR/AU4A3JsFayCnfyPVQtVOVyd7Mm6XtO4HgO7x/xXz
         nZYKVQ2/bvSbMCkbA+8Ud4ZIROGct7qa4Or2Ld+cyZMpAH466i/RUNe1ygKC3Sx4m0SO
         5t0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id u27si13873560lfq.11.2019.05.20.07.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSipz-00083D-HH; Mon, 20 May 2019 17:00:23 +0300
Subject: [PATCH v2 4/7] mm: Export round_hint_to_min()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:23 +0300
Message-ID: <155836082337.2441.15115541609966690918.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mman.h |   14 ++++++++++++++
 mm/mmap.c            |   13 -------------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 4b08e9c9c538..69feb3144c12 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -4,6 +4,7 @@
 
 #include <linux/mm.h>
 #include <linux/percpu_counter.h>
+#include <linux/security.h>
 
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
@@ -73,6 +74,19 @@ static inline void vm_unacct_memory(long pages)
 	vm_acct_memory(-pages);
 }
 
+/*
+ * If a hint addr is less than mmap_min_addr change hint to be as
+ * low as possible but still greater than mmap_min_addr
+ */
+static inline unsigned long round_hint_to_min(unsigned long hint)
+{
+	hint &= PAGE_MASK;
+	if (((void *)hint != NULL) &&
+	    (hint < mmap_min_addr))
+		return PAGE_ALIGN(mmap_min_addr);
+	return hint;
+}
+
 /*
  * Allow architectures to handle additional protection bits
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 99778e724ad1..e4ced5366643 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1318,19 +1318,6 @@ struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *vma)
 	return NULL;
 }
 
-/*
- * If a hint addr is less than mmap_min_addr change hint to be as
- * low as possible but still greater than mmap_min_addr
- */
-static inline unsigned long round_hint_to_min(unsigned long hint)
-{
-	hint &= PAGE_MASK;
-	if (((void *)hint != NULL) &&
-	    (hint < mmap_min_addr))
-		return PAGE_ALIGN(mmap_min_addr);
-	return hint;
-}
-
 static inline int mlock_future_check(struct mm_struct *mm,
 				     unsigned long flags,
 				     unsigned long len)

