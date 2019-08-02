Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D220C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2622620840
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fX9VH11/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2622620840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 028C46B000D; Thu,  1 Aug 2019 22:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1D1B6B000E; Thu,  1 Aug 2019 22:20:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D20E06B0010; Thu,  1 Aug 2019 22:20:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF206B000D
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so42973534pgq.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8SOviSW3O4erJ4o/T7vOdTDRu8uyyXM9kIDmKsHyj7c=;
        b=KuK+nAMsLrslVITijdrQmymXnA6Ree1uuNwkZO1UhQ8JbVJ1wNYuQk336HxG35Jur2
         Wa5a0xgbxIdB/rp8n5lsgnLTQmAeiUx00+W79em/4IawNA55VHYNHmcJTd0yFSL+yNpB
         OdFWYoJ6JThnHGu008SX4HZPPxQqTM5hJOSlNn1iaicfVJ5yo/vpUyDrku2Dr2kHKUty
         EhjZM2GKNwoJZqj9elW1ntihU+yYxZks7inA0A7iFmh96nMHpaIaiH+CiuZ0j1a3cYD6
         i1BM8aAnwRw38IeSu/dz7Aug5ODAqUVHW7B+clG/rvMN1MbiQsY25lWhQy4X0oFsEx//
         /u9w==
X-Gm-Message-State: APjAAAWEjsB9eC0WbBMtNuo76GPcYNaDMj5q9uTOgPEacC4mzILlgiVG
	hKdio/AP+e5wWZnq6eIDHBq+ueVtNRZvvhhHXva8yQ01O3I49NtNWniAe+cv5lnYh8eOf2J8EH4
	psyTBb6hwrTx6Mpa8zUpJmORrqig0BpjqsU6IMF4W6KyQfZAswEwm3JTXqe05X3fDaA==
X-Received: by 2002:a62:16:: with SMTP id 22mr58942706pfa.151.1564712419292;
        Thu, 01 Aug 2019 19:20:19 -0700 (PDT)
X-Received: by 2002:a62:16:: with SMTP id 22mr58942654pfa.151.1564712418300;
        Thu, 01 Aug 2019 19:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712418; cv=none;
        d=google.com; s=arc-20160816;
        b=Xg1uHTyq86PSDe1DKefU2spCKeg/RqgQ6+wslFnwvjUMPbW86tW261Pp9ZrmtrYJ6v
         nWN0B8PyiQPQolmveKr/He4IwVkvINFIpt7m0aVc7owwWlb52uy4OXQXgNehmuhNPXCo
         ykurYSeWYutPStryvdObSVimfqjpNMLzhKUWjPECLZAEzwiiNFHKdZ5U5GlW0ZzNyLLx
         n3uHMmQiOxnemDgCSwkBHxAc+LRZcWKZn5R8kI+IC9JzdB4Aiom9ODgCLDYLZ++XJXgz
         fQl0rm89Atv+MeWEetRtddlBUh6DwsG/dITX1hV9zwECSTr+f2IqGR7US0E3neZ/xXtH
         u8Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8SOviSW3O4erJ4o/T7vOdTDRu8uyyXM9kIDmKsHyj7c=;
        b=iozDrWm95Pj6M1EF17iYRfcO6BrxFdTAyHGyo8vN/M+FbLl1jT/2YiD42xSjGehiBM
         PpjQsqAnXYMQlmQlY+fK6pala6k22OQSBolQB9lvP0suRkYIUtP2Skphm1ucDmIA4FQp
         K5GijabOE9RGuJTFdOo6bz4aorCJfmPUac/GggeL6wK4RcBphY2zX/oKeo/yBCfLhJRz
         WTmaP3qESJ9RDpSYb+TodJhwcT9GY0cyTREj+3FCvcrIfHW6AnlEX9o64japtYGtN5ed
         CombG7CRoc8Gff3yFZN1id8R+vry8zJB8khJU9LDfektedRcBgAgr6ezaFN7agurhCU9
         tWvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fX9VH11/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f41sor8414293pjg.15.2019.08.01.19.20.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fX9VH11/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8SOviSW3O4erJ4o/T7vOdTDRu8uyyXM9kIDmKsHyj7c=;
        b=fX9VH11/xtmCZY5ktyfRXv+8oFT24qnzRAke9R5fEGSeD2IzOy84ZG8im/eaEUg8Lt
         YkXZtAgFC41AXSsr/ysnzaRAFRybM7sVVSGjTeMscCtwe6TgKQtIwxVTNVhX+CyOlaHj
         zyT65gbiAfpxTAt1YaJp886/lI6PgypiCjw7omXplGhR0qwXivcLAeNmtsNmtXQS2+4w
         xqKa+JcZGRrR5eWJB589WBbm/hXzKEauxkOa/UURNDAyCoi6UPYtZRE7atesr45WwiIq
         ErXdMxUJmMSia9/QMT7Nme9zP4x0BmIDxW3018QpZobBFVGv7P1VjjU6MaObsA2EybjP
         VU2g==
X-Google-Smtp-Source: APXvYqy6SxWBaLdRR2vg6Lx/woJAETS/7eDG5dTzML6C7DLLIiEKJ1wWpgVv8K7hxMNjNoQ+Y+s8Dw==
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr1836391pjo.97.1564712418017;
        Thu, 01 Aug 2019 19:20:18 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:17 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Joerg Roedel <joro@8bytes.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Subject: [PATCH 04/34] x86/kvm: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:35 -0700
Message-Id: <20190802022005.5117-5-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Joerg Roedel <joro@8bytes.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Radim Krčmář" <rkrcmar@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 arch/x86/kvm/svm.c  | 4 ++--
 virt/kvm/kvm_main.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 7eafc6907861..ff93c923ed36 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -1827,7 +1827,7 @@ static struct page **sev_pin_memory(struct kvm *kvm, unsigned long uaddr,
 
 err:
 	if (npinned > 0)
-		release_pages(pages, npinned);
+		put_user_pages(pages, npinned);
 
 	kvfree(pages);
 	return NULL;
@@ -1838,7 +1838,7 @@ static void sev_unpin_memory(struct kvm *kvm, struct page **pages,
 {
 	struct kvm_sev_info *sev = &to_kvm_svm(kvm)->sev_info;
 
-	release_pages(pages, npages);
+	put_user_pages(pages, npages);
 	kvfree(pages);
 	sev->pages_locked -= npages;
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 887f3b0c2b60..4b6a596ea8e9 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1499,7 +1499,7 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 
 		if (__get_user_pages_fast(addr, 1, 1, &wpage) == 1) {
 			*writable = true;
-			put_page(page);
+			put_user_page(page);
 			page = wpage;
 		}
 	}
@@ -1831,7 +1831,7 @@ EXPORT_SYMBOL_GPL(kvm_release_page_clean);
 void kvm_release_pfn_clean(kvm_pfn_t pfn)
 {
 	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn))
-		put_page(pfn_to_page(pfn));
+		put_user_page(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_release_pfn_clean);
 
-- 
2.22.0

