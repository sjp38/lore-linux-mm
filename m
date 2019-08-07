Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B2E1C32758
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E40A7217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SyrfptYH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E40A7217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 177F26B027D; Tue,  6 Aug 2019 21:34:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1043D6B027E; Tue,  6 Aug 2019 21:34:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE8776B027F; Tue,  6 Aug 2019 21:34:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2CEF6B027D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so56031642pgg.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=LuvQYwZWYPgp1cz98pTX8fdh7Dahsn7yu7WlaOBQ/cLnAQj6Rag3h7Hp+RJYButdmb
         qZCvVb97W53z4LPopLSws31kU0ij97+3dODzfw+V20Q9HTmFhf9nvBSjCs4Pt+n/Qig0
         zAfWQ99fjnua75oiIzcrDtJvPXFHuS/rbYHU+N3QwS+J86/lpnpGA+yM9UZNNMOv5aLi
         51SFWGvE6bAgcRTDPOo3P6IG5LQEySl+qjJUGcBqOkGAz8a4ZD1iJR6YRhdrZ8fPNbHC
         lhBWEj6yOA68vACV2eAAjW12+4g/eTaRA5xQbybPLBT9M9nEpwXH6ZK1cmafNL/zKugx
         EFpQ==
X-Gm-Message-State: APjAAAWIdgAQ2Knru2gzSffegiadYMYunPWrdRybxQhyTqGX5ZvtMDYZ
	gejQK39CQK+966C7RgJzfy5EBbMGNTCcmpqGYxlMbvzsCsH/fFVH9QigqqXSVRBdTdTzm+T7CW4
	967/oEKYA1pdYWGZ5Qb4R5y3LV035XHNbjmIkpz/LtNxVnMED0bBdR4Daug3QSPstbA==
X-Received: by 2002:a17:90a:30aa:: with SMTP id h39mr6040808pjb.32.1565141672331;
        Tue, 06 Aug 2019 18:34:32 -0700 (PDT)
X-Received: by 2002:a17:90a:30aa:: with SMTP id h39mr6040776pjb.32.1565141671697;
        Tue, 06 Aug 2019 18:34:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141671; cv=none;
        d=google.com; s=arc-20160816;
        b=K1sd/KUDK75sLIr5YCw1eGrIsZC85L7jNI75JFk34XKkJDKoKHFbnEk1vrcjsVI4Ft
         0Dg02FDvN7/4SrplyuRwTTEycxOLXBunEXKS5mI9qslDVePsCQ171kC0eALpnZCizG/k
         eSa7RVEmeimkrD7kscXyiG3QiAwy8Y5KN9Bx2QTjEJHNuSZxxt0YiPcrnZBY1C0uR9N8
         pXLlmHCpB7RrGNWJGDG0c4nPbN3NA7L18UjobSMEOYEiqt1zgt53AMVpLimkkzNw+Qam
         bkhb7Z0fwtWDv3lr9cJAWxlCf6O0XDJgu9ZE63fPLRRmjRBJhEnZfQ0yES4oDKtS07G7
         0f9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=yu+AWxvKZt8lWCg1J9AGAca3IKjNdNzRcQxI3LkGxXdM5Pfw9guc5j+2+OW+cMzyHd
         gufyE/dCz/Co0Kgc5OHmvPsYFXWyS/aRZWewQDzvCxFS5oB/nGjMQ0gRgYX24VN/RZK0
         b0dSjzrvKHV5n4PcqWeKNMKXjuOfGPcKwkXgJlwiueuBIS+mXFDKRW7RETs9SHbZcsHY
         x3cmxRquL7B+pjfUk4eeey2mJM2aC3BlsGA7gLnWJTw2Ah1Mg7Nk9GXbCqaFB5VoIsnn
         FmqwFysdZFbAsepRV+D2f3+OulJvcA5/KS8cfv6uo8+uq/os1+t3N5vrMK+ypHm/obIo
         qBTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SyrfptYH;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s138sor44563355pfc.44.2019.08.06.18.34.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SyrfptYH;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=SyrfptYHZmeMKLLq8uTuDSlh448/TZCFpG6Zn4FeLZy9cTZZGFbCJ1UNBJPoCIn+aW
         ygsAzBiAVH0kcipZ4ihTHldNmhfD0znPMjSBKoUKvh0NP49BRvqIlmsIg6DT8KHAwPBe
         4kKUVEJdNXvGigLmpKs15CkjDKUzxh1vmFZZWbslFSuyKlpacG3oD1RXF7xFsxcwBIbL
         0fmLLMJWYpY6/OBVXor4D0pE1ZvktHc8OSEdcNEszsvYRmiqmzBZ8eGFZOKusFOHPIrj
         /e89tRQCCSxcnEZ4JUtQARmnCroQo1zfhGtcxjcGVNa5FV+aQSWzJVN76YDHje0qrdo9
         NXRg==
X-Google-Smtp-Source: APXvYqwmirpRx7sRgblxTdJDdZc3lNLPB7sz+os8JHE4peLsZYES+zILuE4KL76TUaGsLoa8NjKqJA==
X-Received: by 2002:a62:ae02:: with SMTP id q2mr6578356pff.1.1565141671450;
        Tue, 06 Aug 2019 18:34:31 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:30 -0700 (PDT)
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
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH v3 29/41] mm/memory.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:28 -0700
Message-Id: <20190807013340.9706-30-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..8870968496ea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4337,7 +4337,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 						    buf, maddr + offset, bytes);
 			}
 			kunmap(page);
-			put_page(page);
+			put_user_page(page);
 		}
 		len -= bytes;
 		buf += bytes;
-- 
2.22.0

