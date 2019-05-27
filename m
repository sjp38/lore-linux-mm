Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4314CC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 034122146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 034122146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E48F6B0277; Mon, 27 May 2019 07:12:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BA8E6B0278; Mon, 27 May 2019 07:12:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D2106B0279; Mon, 27 May 2019 07:12:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5499A6B0277
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:29 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r78so5294096oie.8
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rSz3Zt/+BgR8xImgIVcrGb75Z6CG2oL9X/qCww6Ms78=;
        b=LWFvAHGIEFqO+eQj5kQegO7/aUtypqZkhDFQEAIPq4jTvaQMjoghD4vwRAfpAePK0N
         dVnTSdFxtFqwouOdw288swo+bICsYDGoOQbmuT1RWxfGubT4y5NoS3xcEFNK8QbSGX5d
         RbqkI2bpAd6xIlqzqIcinnOm6g4OAnyMkl39x7q0RCXTrRr3W+MQPLTI3PMGC0vXTtPS
         xVueelxZ0NcjhrVQ2s33SSyg9Bwtxqg46xG+E2Rzjn0eMqAoB2l5luvwIOIUT2UdRnon
         An1J4SNwnwAFd+Q3Y1iez1/lsnOnDMu3sIG5pwjq9n2juMsbFby/b9f8xVM1nM4ItV1x
         3Zaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvkMG9OI8mHDYton55D0GsBKkVaYe1rcHWfzPREjRkFviUVVtp
	UUWdbvu4qkb0mYYonQpSIGcgiohAUT0xfsCaKNdCpH72WZ+JRrzd6N9XZduTiNBcxX4TF7cT9I+
	lDHixkoFRBkcw6GggqNJFu4mMrHf7H94nUfFSlf686Ygbz4VRmyE4mfQtmif2KojyRw==
X-Received: by 2002:a9d:4a84:: with SMTP id i4mr63084695otf.148.1558955549026;
        Mon, 27 May 2019 04:12:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd0VggAnr1sNOn5GivhFAOLL36tU0v2/losBta6ePJXwevt9S9/JdR3qA3mH0e+bjiYNfB
X-Received: by 2002:a9d:4a84:: with SMTP id i4mr63084660otf.148.1558955548452;
        Mon, 27 May 2019 04:12:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955548; cv=none;
        d=google.com; s=arc-20160816;
        b=d1T4rZBHxHJVNWyckUG7z3cU7HXP9YNukY3aeNWunhhFaZ8/j+ZShQ6zOKjGAd3SKs
         DBE63DQoTHrEOqm7yHCqF/4xVq424tP/WnaMEtgxYe38Jp+nXllbZauyXaHgICESLJHR
         Hva7dMjJYaoj1VTGfPsAzz/QzEpZQrrM7JTdLQ0ZP6CUPgNqKyHPVl2yW4Q3wXmAJ1Cc
         boJjO7PE98I1FnoecoILvWnexVXDV3pdTf2zq0bzMJ69ZHBgb0V6nCpOYF1x6vr+lwI0
         phwQTTeOwY4W/GvC6vo0xm9FANhXAbKeDF9Fwxx/pFsd86eMEYHY6IcvLX+jyq2/dSwj
         8nmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=rSz3Zt/+BgR8xImgIVcrGb75Z6CG2oL9X/qCww6Ms78=;
        b=wq/pjT0CS1GHUIOYWazBOLzrjEgpr3+N11trFEu6LE23UdlLokElxA1hd6Y8Xvrn3X
         MobBmqdXIwojf8fI+6MjTJCOzmJh8jHxdXqKcjvQ8GfPhHzvNibCVSqlM9W/g9IAYRCs
         5jpkhSOOZqIeVgJlFh/U3Vwb1zI7RwR1pFg2IZc+5tFSrNQng+6aYOX5gQGqyX96H3z3
         KyQysqSGRj5BQUYOJJz3mYs4KGqRARzP+cezG87A0rgpGTeg5Hr9MvdcD2H3bgCjr1/k
         mi/YEUHXGC/lvhPhcMt6oQ2hfmWUjJE7HXZEFm0x9h0jT7YBSlGSG7J7lJuHTvzp76d/
         A5rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g3si5894480otn.127.2019.05.27.04.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AADC387621;
	Mon, 27 May 2019 11:12:27 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B59CC2AA83;
	Mon, 27 May 2019 11:12:23 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Yu Zhao <yuzhao@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory() implementation
Date: Mon, 27 May 2019 13:11:45 +0200
Message-Id: <20190527111152.16324-5-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 27 May 2019 11:12:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A proper arch_remove_memory() implementation is on its way, which also
cleanly removes page tables in arch_add_memory() in case something goes
wrong.

As we want to use arch_remove_memory() in case something goes wrong
during memory hotplug after arch_add_memory() finished, let's add
a temporary hack that is sufficient enough until we get a proper
implementation that cleans up page table entries.

We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
patches.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jun Yao <yaojun8558363@gmail.com>
Cc: Yu Zhao <yuzhao@google.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a1bfc4413982..e569a543c384 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   restrictions);
 }
+#ifdef CONFIG_MEMORY_HOTREMOVE
+void arch_remove_memory(int nid, u64 start, u64 size,
+			struct vmem_altmap *altmap)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	/*
+	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
+	 * adding fails). Until then, this function should only be used
+	 * during memory hotplug (adding memory), not for memory
+	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
+	 * unlocked yet.
+	 */
+	zone = page_zone(pfn_to_page(start_pfn));
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
+}
+#endif
 #endif
-- 
2.20.1

