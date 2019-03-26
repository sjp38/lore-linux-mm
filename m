Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D69C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21912205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21912205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364166B0296; Tue, 26 Mar 2019 12:48:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 312ED6B0297; Tue, 26 Mar 2019 12:48:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 205A56B0298; Tue, 26 Mar 2019 12:48:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF4826B0296
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:25 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d131so12036366qkc.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=252zMKy7F4cZQRAlSYsRJSdfyv+AZ8onT930rac77Bs=;
        b=BSQLxBebrEI6HOcr8HXq0QsAP6nsHYU8TgHBu25NEb565Oi9XtC24USPwEyDklcbyr
         fcfRS5/JDD9QVIXGBDwnicmvzRVLGreD9SweNB0IRWn/FzHGCTOx/2Xq4ui/0tAGUyGg
         eioLJG8h9+fI7aycsfJ8h+4+eDSMaIEDIdBpuVwNqRS/B7TMHR8OUeor89NzkGWtTRAS
         854L5sQPo66o/25+UIpofDj/2asE3WYp3Vgl7cxbpjFKpcr0SoFIisESEYZFcm2ZBysk
         PDViCFf8eOO5ZHeLIKJI67xd6e5Kfj5MWfGEqXbjzG6wee8+zBWeUAAmbOmRMRjD/5gv
         5WLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXB/DX+u9caEWCuX/ts7QnX3jdGsrEPjjIlIPf9UwfIL/hZjsET
	Qp6/PtQY7eaCtEqLG6i5jYZrOWn+YgAUcdlqIL4N7nR1qe/eQm59Vro8egV/5fsNANvVfK5Q70j
	ybIkbqJLYiB8kLsSqIOBg39Yd09AlZJJ2ECIp3oeqGOBtC5clZP+cRAWi9PYr7B4nzA==
X-Received: by 2002:ae9:eb4e:: with SMTP id b75mr25583247qkg.121.1553618905751;
        Tue, 26 Mar 2019 09:48:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGaHnOycR9RHVbznvvUh2H4Re8kQ6ACceKyxBKHAsHqZ0HPUWwj4AEeGb2ZGYxY92/Bo/W
X-Received: by 2002:ae9:eb4e:: with SMTP id b75mr25583194qkg.121.1553618905155;
        Tue, 26 Mar 2019 09:48:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618905; cv=none;
        d=google.com; s=arc-20160816;
        b=gycXpCHtWtronHa6abd79UocJ5qPn+e2OPGr583i9IQMS6wojaqt6oTBBuPl0J74LE
         pKzIqWHIsPDTWjQEKk3/DXfs6SxbtBWi7IsN90WpyttiFjS29V9BPI8ZDRN3c722XumO
         ybd4TKzBUIQHUggpFDnECl49N3JIbK3On/IAx1c2srqp7hi2KIgL6pTmINcXZyWmM39p
         CeysV5wcidRyArhDRKQnyYMS4w2qt8pUZo0NIzy1f2nNM8IKTmM3uCVVSh6W33AYtFkp
         ye+K8GZEUuj77QkM7BNulZvBP8uPUyW2XrFbD5dKQIlTDmc9Oupg71MNUeU45S45o2r5
         NDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=252zMKy7F4cZQRAlSYsRJSdfyv+AZ8onT930rac77Bs=;
        b=piTE9E4WDZG9laRLfI/WlWHUOEWqbuHaGsOjDPx2bDXAkGs8qTIjY4gM2gjbRxGwRg
         BcBQ0h0g4KvdtoD/bE7UsXjFVNQMIedITRlUR/TcTDtr4phcVsl68Wxt8kcrHIxU+0X5
         X0dwmd0hel3DLUC1VM6UdFtb7eo8C0NgWaIU0CzQQ19aExJ7xgch6Nfswk3bxrA9Tb64
         rJJ2mNe3J/tP9D+ME4qx5HV6lYvMjIk/Q2Go+S5Nd9jg7f/mlyshga1N5j9g68L1FjEB
         yTbXKysE09qoEkGCE59MbvZCpOXD3nzNgcPlgOxQPluKY7kUSuyEohk3sGsWKzv1D+UZ
         RMxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n12si1363820qtc.99.2019.03.26.09.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 268F483F3D;
	Tue, 26 Mar 2019 16:48:24 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B266717595;
	Tue, 26 Mar 2019 16:48:21 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why mmu notifier is happening v2
Date: Tue, 26 Mar 2019 12:47:46 -0400
Message-Id: <20190326164747.24405-8-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 26 Mar 2019 16:48:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

CPU page table update can happens for many reasons, not only as a result
of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
as a result of kernel activities (memory compression, reclaim, migration,
...).

Users of mmu notifier API track changes to the CPU page table and take
specific action for them. While current API only provide range of virtual
address affected by the change, not why the changes is happening

This patch is just passing down the new informations by adding it to the
mmu_notifier_range structure.

Changes since v1:
    - Initialize flags field from mmu_notifier_range_init() arguments

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mmu_notifier.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 62f94cd85455..0379956fff23 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -58,10 +58,12 @@ struct mmu_notifier_mm {
 #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
 
 struct mmu_notifier_range {
+	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
 	unsigned flags;
+	enum mmu_notifier_event event;
 };
 
 struct mmu_notifier_ops {
@@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 					   unsigned long start,
 					   unsigned long end)
 {
+	range->vma = vma;
+	range->event = event;
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
-	range->flags = 0;
+	range->flags = flags;
 }
 
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-- 
2.20.1

