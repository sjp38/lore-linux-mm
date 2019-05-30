Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6BE8C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:53:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90D9F261EC
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:53:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PsxZY9cX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90D9F261EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 380AF6B026A; Thu, 30 May 2019 17:53:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332776B026B; Thu, 30 May 2019 17:53:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 247276B026D; Thu, 30 May 2019 17:53:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECC076B026A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:53:45 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q19so2027841otf.0
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:53:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=sJuZdrZ6VMk79b1ZhahuZrudd0+Kp6YlC0eBwgdHqtI=;
        b=Echon3YegnVwSBa9oXnYYDzLexBx/lWm98c9SgpEg6F4PC/ZnvUPbhbKoW1stO6dTy
         XkbE8FyP1Z9r2YKI0a0cLFGFRre7AlzJULnTVWNDvDikM4eLl6xFiFIfl2/xHpjxhzL7
         dJIwu9DvbuAz/0qSRJ5BI/cE5JTNiRF8hXTT7XnZOdfJ2nVh3N7Dy75+Xea7eKecs/iq
         DdtbsZvN/BQChCgd7XM/7hxLd1IByRtmBWJ8N7NuWNyJ61zpjIA5tB+EtXHm+KrrcEtC
         t14OOj5DqkDTj+dDKd0ijhVehIvNe18jD0eyDSg0xisBX6F9FwypJH+iMbqneuvoyiyP
         7T4w==
X-Gm-Message-State: APjAAAUP8SALxcehfTwOXsHAruvtQ1c0J76gnZA8rxBun5Y2IPHtd8YU
	QkYew8EABz1PHSPoT2RFimXioaUuquetgqfzvwkMzIeGGp1uUnAS4b2qqSK3Rtn0X+R1jHTrkYV
	/pzU863k3IbPrtM3BFZ7qP90vWLNHPo6N2MqOIfYQqqIt3neAp6HJCzmkBcOofEk/XA==
X-Received: by 2002:a9d:5511:: with SMTP id l17mr4539863oth.158.1559253225614;
        Thu, 30 May 2019 14:53:45 -0700 (PDT)
X-Received: by 2002:a9d:5511:: with SMTP id l17mr4539821oth.158.1559253224568;
        Thu, 30 May 2019 14:53:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253224; cv=none;
        d=google.com; s=arc-20160816;
        b=bGarTUoQI0hfrUrD1Z5o/XTGApoMwrSfMhdE8GzOCh4Vr78AU03SigpQ45oIEasTmr
         oAb1AFTwPX3aSxBNQNDiidxelKY0q1Xeeo/qVaq17BGw3Zk1/iOjHZ5HPnGTnafxzsnf
         6V1PSsx2xLXD5jKMfUW4TmDSCyA0ZEVt732EAikKKj5B5G3oGAwWbVFmdMI752qRFHF+
         SlhhVjCiamatlB6Q5jq407hjoi9tWHJ7e3i1ya24oZdicuzjXL9Cb4eOQ+uZHpS4aAhW
         upkGQJdPBxv76UyY/pOACsRG7DEDjZLPjY2mYVZoBvVwB7WeyzZpOXsWwUMcoPFaSBi7
         9/4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=sJuZdrZ6VMk79b1ZhahuZrudd0+Kp6YlC0eBwgdHqtI=;
        b=VPhxxEHMg/SBVdB7zn6RteKSQ9NpDnhJjO84mOyBFdA4s1R87ynhIB5gfkOtLzjDhB
         IaODIrHRupiDiD8E4OYloX+nz3QeU82YQITvSlZbrA/a0oTtsnScwCSjwe8yhe5pFOEC
         cNGY3S/WR7GmQYf5YUoJNqXYw8uiEvytBbSKN7E0jrDp3a4JZNjvTASR+ISU4VDA0+Rp
         PqfhJYklFE0WPvST6CJKexbRgnufgNkmhrt39c4ISF+UiyvuuTiDjGQezNjURVx8n+3B
         mMaTLg2TIqrV2dm/khAVJyA84jswVZy6J/uFjMdHJRoaGiZ08e3UbCc32cMuRJc1BFa1
         vAGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PsxZY9cX;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor1961667otb.23.2019.05.30.14.53.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:53:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PsxZY9cX;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=sJuZdrZ6VMk79b1ZhahuZrudd0+Kp6YlC0eBwgdHqtI=;
        b=PsxZY9cXHZU3UHhQbhmWYsY+UJaHm8siNxxjBiful25kOQ+QKikMo6MgAVTCdgUVRf
         HjBxf/inGy+2U2z+5S+aaxGx2eUrk6bqqatAILgaaLwR1X4LkQlo7YDmx157FhcBU5Dh
         SKPTMz5awBl/iOy0G0otyV+PrTYLeu7JgLh7vznhqdFmuP7VyNkvH+QRBD6mjV8dj0ac
         VsIz6MtfFh0yXHkuy6sjpNia/mdmJuFWmSloJd2uK3Gf8a3fao/2BY0tS567OpBezrz+
         nyjzchNz30eSf80CDrDHUso4ILvcPw8/p2r5zT3iwCzx5MLu0IwOQEdUzi8g7aVFn/P6
         dHzg==
X-Google-Smtp-Source: APXvYqxMsojOf0egOxfGWLBhthd5R18VJ7E3zUiMlsMMhMaEmJH88aU+eNQTsegxUV9DbttxV/LJgw==
X-Received: by 2002:a9d:1b6d:: with SMTP id l100mr4256814otl.15.1559253224151;
        Thu, 30 May 2019 14:53:44 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id v89sm1441749otb.14.2019.05.30.14.53.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:53:43 -0700 (PDT)
Subject: [RFC PATCH 01/11] mm: Move MAX_ORDER definition closer to
 pageblock_order
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:53:41 -0700
Message-ID: <20190530215341.13974.19456.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

The definition of MAX_ORDER being contained in mmzone.h is problematic when
wanting to just get access to things like pageblock_order since
pageblock_order is defined on some architectures as being based on
MAX_ORDER and it isn't included in pageblock-flags.h.

Move the definition of MAX_ORDER into pageblock-flags.h so that it is
defined in the same header as pageblock_order. By doing this we don't need
to also include mmzone.h. The definition of MAX_ORDER will still be
accessible to any file that includes mmzone.h as it includes
pageblock-flags.h.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h          |    8 --------
 include/linux/pageblock-flags.h |    8 ++++++++
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..a6bdff538437 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -22,14 +22,6 @@
 #include <linux/page-flags.h>
 #include <asm/page.h>
 
-/* Free memory management - zoned buddy allocator.  */
-#ifndef CONFIG_FORCE_MAX_ZONEORDER
-#define MAX_ORDER 11
-#else
-#define MAX_ORDER CONFIG_FORCE_MAX_ZONEORDER
-#endif
-#define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
-
 /*
  * PAGE_ALLOC_COSTLY_ORDER is the order at which allocations are deemed
  * costly to service.  That is between allocation orders which should
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 06a66327333d..e9e8006ccae1 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -40,6 +40,14 @@ enum pageblock_bits {
 	NR_PAGEBLOCK_BITS
 };
 
+/* Free memory management - zoned buddy allocator.  */
+#ifndef CONFIG_FORCE_MAX_ZONEORDER
+#define MAX_ORDER 11
+#else
+#define MAX_ORDER CONFIG_FORCE_MAX_ZONEORDER
+#endif
+#define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
+
 #ifdef CONFIG_HUGETLB_PAGE
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE

