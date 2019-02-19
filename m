Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A46EC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4076A21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4076A21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D95628E0008; Tue, 19 Feb 2019 15:05:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6B728E0002; Tue, 19 Feb 2019 15:05:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5BBD8E0008; Tue, 19 Feb 2019 15:05:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2EF8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:05:11 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b187so620485qkf.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:05:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=d3L8LEk8AB5D2JhmIyE9exlLcnknyD9XBU5141tFhtg=;
        b=ZPWqLWhIT+IN2zn1urX4b8MkeEj0V9qvXUfgCOqc4l89ablYCfVEjwEEK55krRKuZe
         23t7XjzCRAT1N/32yV+Wk0/jW3YQpMXwnuB0d/Bxqf2t7sZN2FCTAqTVGtz/tHr8nkL6
         X5jVRHVBRTstSNOshjjeCx+/mvLbvY7eRrdVsf9Hd2PufhyTZ07dXwnP2hhVzgzw/vM1
         hYgjVud7mfr9Z2F3ly5N/2p9b4h5T/onWS1FW+F3OpsGRTG7Uesc3u5bKjTYr7MpBrW4
         d0f2SsUtJzJgUUOhPv0zxi3nvQla7CSzBqgwIWkxfIOw0vEFShaoHv3/NOFP3bxfwv7G
         SICg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZJiRxfuf3s0Qb2QdlI4jedotKmvWfvQ3ftu+TjkHdHJS+Apx6K
	EXVvkD2sJe3epRwefWQbc0ZAhBUKQdStWmbNuPH8swOy3hv6YaGE7N8X3Y6DjpEh553tgq1T77l
	fpPNCj8MfUHkgGxdBcQmtBD+E7DAF8w2G5i1sTnVxb8Tc96CdQ4LWaZJ9uec886ihGA==
X-Received: by 2002:a0c:b626:: with SMTP id f38mr22923248qve.166.1550606711340;
        Tue, 19 Feb 2019 12:05:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamSLLCTOYTovvsjQtsm2kJ0cte4BRI4zSwo1a6s09HBrE/iphhFvSf5IS/TqwWpPFFgppN
X-Received: by 2002:a0c:b626:: with SMTP id f38mr22923167qve.166.1550606710339;
        Tue, 19 Feb 2019 12:05:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606710; cv=none;
        d=google.com; s=arc-20160816;
        b=ultoW2sAyCrsPbyTgAJnTCDs7TX5XYZ6Mpw84FZuCqAgwWGnT4Y7U7GXvtneXcXqMT
         lXAW2wh5aIkdackllU0jZhqOhEuN6OzrOUr/8XCWgRn4Qo3HwaXdOhxYeXcxOV3yblgu
         5ojT43MfVWYldee45+pmdYHtQ4CV9dPsn1CkNQD9zzZOjFmRnpB5fx1e3un9reKjn12J
         7GYgGMqWDuUG0TlMciEOmMF8eFcrdV0rUP2t/9YxhIzRZP4I2PICP3cIlXVlj57WYdOa
         fUo0woIvrVlCyIXE7VSqru5aNz/6daWoownJodN/qpapB/+qxrRiRhj5UqgTm2Z8/LsJ
         Y4Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=d3L8LEk8AB5D2JhmIyE9exlLcnknyD9XBU5141tFhtg=;
        b=CateUk9GBW2UxpFJ0Kn00l1c937ZcOEggx1Y5tk1MxDEzvW2xYpKtdCZpL+zK9JxMy
         ho4TpJp1QHhm6D6eiyceW0uZXFNl6Su2xXY2N2yGfB97IstG6fCSPD0Ri+tXHwcRxC8c
         yBMEeNpVQLzZBYBsfXPckbTtzzqi/mZ/z56vsNWGlanvr+PdJpV1fd5hYON5YZ3vBMCi
         Po/NOIZkwMCCMxbjh/cD6DwpMefFaU3lHzVP4Qs+PeLy8ZS/Wai6Y3NgAYabWRWQatNX
         erGk1PmG/5bNpe30lN2i06qgjU7MDFKYdsYogqZw8ilf0xjBCDslXE+32V7pc844Itsb
         YIfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r46si2248581qta.43.2019.02.19.12.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:05:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB5ADC1047E2;
	Tue, 19 Feb 2019 20:05:08 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 32198600C8;
	Tue, 19 Feb 2019 20:04:57 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
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
Subject: [PATCH v5 4/9] mm/mmu_notifier: contextual information for event enums
Date: Tue, 19 Feb 2019 15:04:25 -0500
Message-Id: <20190219200430.11130-5-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 19 Feb 2019 20:05:09 +0000 (UTC)
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

This patch introduce a set of enums that can be associated with each of
the events triggering a mmu notifier. Latter patches take advantages of
those enum values.

    - UNMAP: munmap() or mremap()
    - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
    - PROTECTION_VMA: change in access protections for the range
    - PROTECTION_PAGE: change in access protections for page in the range
    - SOFT_DIRTY: soft dirtyness tracking

Being able to identify munmap() and mremap() from other reasons why the
page table is cleared is important to allow user of mmu notifier to
update their own internal tracking structure accordingly (on munmap or
mremap it is not longer needed to track range of virtual address as it
becomes invalid).

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
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
 include/linux/mmu_notifier.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index c8672c366f67..2386e71ac1b8 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -10,6 +10,36 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/**
+ * enum mmu_notifier_event - reason for the mmu notifier callback
+ * @MMU_NOTIFY_UNMAP: either munmap() that unmap the range or a mremap() that
+ * move the range
+ *
+ * @MMU_NOTIFY_CLEAR: clear page table entry (many reasons for this like
+ * madvise() or replacing a page by another one, ...).
+ *
+ * @MMU_NOTIFY_PROTECTION_VMA: update is due to protection change for the range
+ * ie using the vma access permission (vm_page_prot) to update the whole range
+ * is enough no need to inspect changes to the CPU page table (mprotect()
+ * syscall)
+ *
+ * @MMU_NOTIFY_PROTECTION_PAGE: update is due to change in read/write flag for
+ * pages in the range so to mirror those changes the user must inspect the CPU
+ * page table (from the end callback).
+ *
+ * @MMU_NOTIFY_SOFT_DIRTY: soft dirty accounting (still same page and same
+ * access flags). User should soft dirty the page in the end callback to make
+ * sure that anyone relying on soft dirtyness catch pages that might be written
+ * through non CPU mappings.
+ */
+enum mmu_notifier_event {
+	MMU_NOTIFY_UNMAP = 0,
+	MMU_NOTIFY_CLEAR,
+	MMU_NOTIFY_PROTECTION_VMA,
+	MMU_NOTIFY_PROTECTION_PAGE,
+	MMU_NOTIFY_SOFT_DIRTY,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
-- 
2.17.2

