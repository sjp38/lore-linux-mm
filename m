Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09355C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5244205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5244205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E23C6B028D; Tue, 26 Mar 2019 12:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8910D6B0290; Tue, 26 Mar 2019 12:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70F136B0291; Tue, 26 Mar 2019 12:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4416B028D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x58so14159794qtc.1
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qd+j517MeUYcwakOP+kXZkhhiv8aT+TIOX0bOZ6xYI0=;
        b=kxZD11mOb4iRe6Py1bMZMcKOBl+gTiMflzs7sxcIpoHXagUvK0K4otr/vlIP3lqmgS
         Ii291Cagjrj1a6gRg2o9Jk5uZ+pBRWgFhfsEqMamAbxm8nUNdyvGRpQqRyJiVsl7BpJF
         bfTP8/qma8MqLNRd3zYEZrr2MoAf94PhMa0wNAlDSDd3UqRCecnt5vT0YGMgPd0HTELb
         shkfHDzlCOjXdwXg133yASfWhlziRRWAgYguoHOlY2cGTVU6H6gy3WkhfshBbbfPE7/i
         QGwKdR7ihqKHHyvmTyWj8TzaETFwsKpzlrC7DNR7vM3A+YpvjPoLeHjz0z90bN4nouu3
         5nsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVi11TrePEu1AadhI/QT1zAU4GbNYSGflYlbwQ2dhG4Gy0LYUNV
	sv7v+fx9UKW+WPgrCvkCnaEZWbScC+n/RlGt8ympeHwk+kjm+KC9K1nkhMjLIIIcYOwGnspgsp1
	0z9KKjMhSCBfW5/2JvsE0VMIeihLU98sWlC2UtRmQZWK5dnP0clq7O1lI7MRGHM43oQ==
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr26923791qvc.118.1553618892079;
        Tue, 26 Mar 2019 09:48:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweGED+Fpk4SZn7BTvuU2FSSM3nHji3fcEPiZfHyTjNAe/JGSID5nTY0QXv/Fmkk9RuhhJ2
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr26923743qvc.118.1553618891440;
        Tue, 26 Mar 2019 09:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618891; cv=none;
        d=google.com; s=arc-20160816;
        b=qQxk3IAUgi+DYvKQc5P8kZ5J8DmPbuCQQ4Vef88eGh9coIPCLNMoS1WwNwVOzFgtxC
         uDxKCPJ3lddMOQtM35WkpQ+VFanxjuW5lYb+RMDKt5Q2gfHZgl1gYuwcbu2XpvNbeFSg
         EULSuFiSFIAmWvmjvTCM46heOMWBUcX8CP/WVt7bDZUEESg64Ws5QAzUaRxZwAdcFqGe
         DMDZFZv9YXjtYbFHm74Xm59b7rGo3V71BVQbjPoiudT4LBYRqMBFhCmPfvSmRutzwPOZ
         Dd5u8i8XwhEUDk7hBCNkJ0KmZStFfx2c8W8nqabcRCQgruRVpEAbAAz2cQigP9YXT9OC
         keaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qd+j517MeUYcwakOP+kXZkhhiv8aT+TIOX0bOZ6xYI0=;
        b=Uc1Rl4lUSNnwawnHmkTfsLjmOm/G1a5q0CDKqfmCpLReVUe7Lj5lP7S+jZjOzxBO8N
         7rZy72VD/iX7nvcXqJzTvRcPXBVBzPrtUflcoh3lRnSjhBnNMYkghVvGckJ4i0YC0/Dq
         zhYghU+Nc7yeLshKElEJtbXMrp7fq0Wfg1FFOb8CVTqx+lSf4K8QQzREOUvxSA2Eu+fg
         s1lms/Rv3Cl3ILdZv3p2/HBBx4QqUIebiK9PiqsokydsX8uG2er6wQqvNOJmutbVTF+R
         WXD1hMcuyZ2uIR29Kd9Uy0Z3tySTuB0VEdprbGViAviFyDUZNVqhNVo/QFR4XsSDoOSI
         mM2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a66si3571927qkg.30.2019.03.26.09.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 761CCC04B2F6;
	Tue, 26 Mar 2019 16:48:10 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 53C89176B1;
	Tue, 26 Mar 2019 16:48:08 +0000 (UTC)
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
Subject: [PATCH v6 4/8] mm/mmu_notifier: contextual information for event enums
Date: Tue, 26 Mar 2019 12:47:43 -0400
Message-Id: <20190326164747.24405-5-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 26 Mar 2019 16:48:10 +0000 (UTC)
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
2.20.1

