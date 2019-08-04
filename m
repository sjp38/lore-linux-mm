Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29F5AC19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6AAA21841
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H+TbmcIg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6AAA21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5E16B0008; Sun,  4 Aug 2019 18:49:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 253D16B000A; Sun,  4 Aug 2019 18:49:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CD176B000C; Sun,  4 Aug 2019 18:49:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD5F96B0008
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so44987944pll.14
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=r7W9ji+JNJIbIy0QtUd83uZUB3LiPkrDRQLH1iaeB04vrZwGHMI54uYFm0p55HqELH
         kMf/+ROcLsXZfWMpu4itVIpns/nN1xGTFdUWQofCquhNnbrKOz/E/m2wCdGMeNIB9Fbn
         FigZxrsYtjRZR4jgDCSmkCwQ2a3PTrxMwjloSMbcVvCQbPPE1ccTNxGhR/ACur1RtkyH
         86M0GcG6GtfxLsYLArPvF5CINT9pNZxBCzG0vFaC44eaU7ni/uRPbIby1KvuDlQNsYs4
         byEiOiiFcvEmnmaLTiDz3khXJck3NjDDNNd8dngl5YceGX1h4VWEscWgzv7OhtE1G1ev
         TkRw==
X-Gm-Message-State: APjAAAWX3kHTUIvqwbbs+bEwn7QVkLMNlP3dmZR3la0A/AjXQEFFxQ5f
	ZI7tnzj4aY3r4zs0/+jY0dSuyZtKz96GP9KiRplu02cgrjGl5+TGiCmW0VRpn+NfhV8TUluOAN9
	f4I4iawbqdNJsw9tcWH5kob8mEiKU8EyRLHBYlCxAR4ywzXhXFurGXZlrAQZD/FMgMw==
X-Received: by 2002:a17:902:7088:: with SMTP id z8mr7000241plk.26.1564958966455;
        Sun, 04 Aug 2019 15:49:26 -0700 (PDT)
X-Received: by 2002:a17:902:7088:: with SMTP id z8mr7000217plk.26.1564958965539;
        Sun, 04 Aug 2019 15:49:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958965; cv=none;
        d=google.com; s=arc-20160816;
        b=BqCOsJx33lR6mVwuUNBMVuAVaUqWowlF/Kg0CSVw5bna4TZBYb1JuC0YH9/a66tDi6
         LQ3BKhFGgc4R0M3YhVtSgR47ZBjU06PBVFrw+3Y+LJlniFMsh9CE9PD2voB1TqjBgxHH
         gtagmoah01woJ5/mvdpvK97iiq6OMe19X8WSkVh0qSMQIJ0Q313bU1Wx7sYtg9dorFk9
         YXdZQTohHgNXNMxG5QQ/NNKYYpgpS7Zwr8GW89U8HvVGM5piRSGdt3N6PdWYF3IqonxU
         OrE/FchoFjG6NuAbmCsHoKz53KgvP0JXoujCcSaTS/g6RRie2dOpzXMfET2owsqMmlGQ
         gl+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=YHtKtdWDbEYRtJLNq68ZVefqLYKoNLau9pLW/KtXZbgNBD1YaPdtG4Wa0OgEtwqmSc
         DMyiI5pLBvDGjfG3MdRZjTKTio1j/ZomG44qtuVch3tRZzRsMCU2apb03xsV3gwcLi2n
         2ubuHXN9KFMODpel9pVYoj5RIz2hH+EUeQvH0E4axPDJXyvmcTINnW/n2xxUxK2dYbAI
         MkED3o3ENAOB4dbMLF5kBc4vqH1C1WkZKjdhFbcvUYUWOwnv/62GE18lGheJ6yy95E4W
         tPNexNraqZV8fGIc8Gz7tR4Uq2luAiCDr7e0k9Fa7eaatp7Xf6t5mbqrRVVXOkHnSPNl
         kHBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H+TbmcIg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14sor9605104pgl.40.2019.08.04.15.49.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H+TbmcIg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=H+TbmcIgrwACxFo9hl2l5Xjf1f4GsBt3cThAJffGoVTGjng2zDR+vuW1ELmO9cwqUz
         zWIfVJ0ECGbvkQCKwqluHnqhDjnVY4M3JR5j9zUjgsJ4KIo9Jdd0V01x7wYmYDPTzYc0
         2jx8SovBWIpXNDy6R5BQslstKFd50o4jcCzDRtzpOpp5UZEbCq0wLfyRsWQbHo85Apl6
         6aso8ZPOFALMDQpmQJWkBkmOSbB25/wfG2bt9gcemYDwOVD8vq08Rd+SZJr2wXg0pz6k
         SDHNDSjbHSOs0ynQ5oDFI2egfnr7bliii2ZaEObWVPQlOvI2whQIUmO0CHVVfGDuWZsi
         brew==
X-Google-Smtp-Source: APXvYqwRJ1sJ/rrgIE94buNkF2wqaHOY76PrdCWNDeiwr3VYQjX9Duq5YnDYkLulcSwytNSAtlk/zQ==
X-Received: by 2002:a63:6bc5:: with SMTP id g188mr104077235pgc.225.1564958965247;
        Sun, 04 Aug 2019 15:49:25 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:24 -0700 (PDT)
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
	"H . Peter Anvin" <hpa@zytor.com>
Subject: [PATCH v2 04/34] x86/kvm: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:45 -0700
Message-Id: <20190804224915.28669-5-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
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

