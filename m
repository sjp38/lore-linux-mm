Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA5FBC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E9802177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:02:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E9802177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 385636B026B; Fri, 14 Jun 2019 06:02:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30E1F6B026C; Fri, 14 Jun 2019 06:02:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 136756B026D; Fri, 14 Jun 2019 06:02:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E33116B026B
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:02:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so1673803qtb.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:02:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GGbrHuVMDrkQm8Ggah1IohNNECSG1loyCUoeL7DCwug=;
        b=EkcGeGTclIHwxqVjjDI/pxY1z2gIbq5RZfiCfEqsnml90OXcYc1fCzLwpoSWbkp8yf
         wvMGIbsXnN3DN+W2hqVjyWLIuX1rZznHdPw/3ebgxzaYsHyz/0zrf1CJvlPg3PvfMSEx
         qTTVSE0seWduVclbUQ32yATyvQQCTxmnpLYGKAFZ8nQ43lQyKYdkD41zZLDLLuzCcnab
         f9x1hhI+kg0BN0D/XXaOWXQbAoxio1nFvDQdFwyIXrQOp9+y3dtzUhOYp2+LCpEUt60m
         t1vYXQI0PSJGLHLm/OxApO0XPophzexhJ5aHNmkmbORdQVR3qBLTLQhWEaEUG5HrUNAx
         Bgqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUNHRhjYV3RfVVCq2jy/idnVY72hhSK338ArReLG0xNOhg9udqz
	xXgtgDJHTQdghowt/uTnGvS92F4gLt64id+1qCZdl3u8NUUZljPH3ip6Xv4m7qrTuiGxFVbhJXv
	F63vT5nwoz5uJUoJXBZhW+MACeOgiZBOya+c8uK44P/EOj6jG84JwMo6XKy77pQ297A==
X-Received: by 2002:ac8:28bc:: with SMTP id i57mr47906415qti.288.1560506532712;
        Fri, 14 Jun 2019 03:02:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRa7R3Zk8+8XRJLz3iIzCqHFQyd79IOpesnaiOPL23bBJ1o07ppdddIrOSg510Q9VFpVA7
X-Received: by 2002:ac8:28bc:: with SMTP id i57mr47906250qti.288.1560506530788;
        Fri, 14 Jun 2019 03:02:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560506530; cv=none;
        d=google.com; s=arc-20160816;
        b=HVgnmTIF6X1jWdCGLQhSuruzhJsq6K/I+XvEfhRK3opwzZZXhEE3jtTEhVvRExzH5R
         +qvCQ/i7k9uc49TRVXF4tvlPbmNPWLht6Fr+u7KjE4wHFuGuw4/iFUMnUKBlbC5LcpPG
         UYvQEINoMfkxM/hqy/RpProuJm8uim+74U35Xmdpu8j3PO9ZY/t2Q4eXZZbwoQXWqMdg
         ybpFmG//JEZRXFo/8PtVRW5VVGUkj28JeFpl7DXgxXBu6EkKEaAw971y4qQaiBZbYVK2
         lGrIan+xrF8pQcPoC0G0O8fMfz3ifBkUigIsLG89AV0iFkvhIbmOwNHXCodK1spjhpeU
         qVyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GGbrHuVMDrkQm8Ggah1IohNNECSG1loyCUoeL7DCwug=;
        b=I1QAyTFoPzva8ywhblUClv8pAbq58TRFPn9j/cZy833sJ8zvSCpi0aBQO64HJ9MKTi
         tLkmK3jkUJf1nD1Di1BimrDnqIasbZ5tBeqNL49abVJl/oG3Rm5CnDYOdp8EXDV6vuHM
         eczEeBk3Exzuc4jnT7It5xPOP9uZ4iijHHogatqH3zs0eBUNEBkMF8VcdyFBUSyW/sfL
         FK/xc2pa1blMROKUQ0sJEv2Qed7Vuc0iys2njNOzRfoqxGSZOl7Um1HFRpTwkNlQW7bk
         kqvFp7UX9UFmqohqXgaC2SPhs6VwrrwCm5s3hu6pfZPCHxW+I2wPPvEDagTI0pFyydaC
         gYvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n14si1481869qke.102.2019.06.14.03.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 03:02:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 057EB3087930;
	Fri, 14 Jun 2019 10:02:10 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-252.ams2.redhat.com [10.36.116.252])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 58EA85D9C3;
	Fri, 14 Jun 2019 10:02:04 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>
Subject: [PATCH v1 6/6] drivers/base/memory.c: Get rid of find_memory_block_hinted()
Date: Fri, 14 Jun 2019 12:01:14 +0200
Message-Id: <20190614100114.311-7-david@redhat.com>
In-Reply-To: <20190614100114.311-1-david@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 14 Jun 2019 10:02:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer needed, let's remove it.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 12 +++---------
 include/linux/memory.h |  2 --
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 4f2e2f3b3d78..42e5a7493fe8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -606,14 +606,6 @@ static struct memory_block *find_memory_block_by_id(unsigned long block_id,
 	return to_memory_block(dev);
 }
 
-struct memory_block *find_memory_block_hinted(struct mem_section *section,
-					      struct memory_block *hint)
-{
-	unsigned long block_id = base_memory_block_id(__section_nr(section));
-
-	return find_memory_block_by_id(block_id, hint);
-}
-
 /*
  * For now, we have a linear search to go find the appropriate
  * memory_block corresponding to a particular phys_index. If
@@ -624,7 +616,9 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
  */
 struct memory_block *find_memory_block(struct mem_section *section)
 {
-	return find_memory_block_hinted(section, NULL);
+	unsigned long block_id = base_memory_block_id(__section_nr(section));
+
+	return find_memory_block_by_id(block_id, hint);
 }
 
 static struct attribute *memory_memblk_attrs[] = {
diff --git a/include/linux/memory.h b/include/linux/memory.h
index b3b388775a30..02e633f3ede0 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -116,8 +116,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
-extern struct memory_block *find_memory_block_hinted(struct mem_section *,
-							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
 typedef int (*walk_memory_blocks_func_t)(struct memory_block *, void *);
 extern int walk_memory_blocks(unsigned long start, unsigned long size,
-- 
2.21.0

