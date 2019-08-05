Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E57EC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 268682147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pKuvlg2h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 268682147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72FF36B000A; Mon,  5 Aug 2019 18:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B8C26B000C; Mon,  5 Aug 2019 18:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A5646B000D; Mon,  5 Aug 2019 18:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 269316B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:20:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so54436372pfk.12
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:20:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=O+7IhG+fEN+Si+GcSaRXqoxVYIcXJgUDESWiJ69rTK0DI+ezO19IxiUxx1uedqKCxS
         PVgdJRGTEtgWC2T9tEAebNWKsfEKTVcYnMrphEALI2KwrEjv+C7FEBkiYZmj2BgUw6nq
         DhbKlal/WW+Hy0LqHaTI9609aef5yKXS3pPqtRkWannpmfuDiaWbK1q4sHXBZfFTiuQi
         R04IHZIeBWWRfqlAl6WpizySSi+T9qnYQtN1K0G0Hu5SutwxLO1ZEp1wY8/jqEtuNOJ8
         zX0MK6O69MB2vbfDXHWM3g7rTSiwcR+5b4+tY1jAjsZzirA14WQ3n6rjGB/Yfz7QbVPn
         KQXQ==
X-Gm-Message-State: APjAAAXamdhpdNTDjb7TL/Ix/fToO5o1dY3yW8zxnBPktD4jUIG2h11l
	/ODW+trGwtPOkZsMM9oRkn4e13Q7VT5L8DI4usPeV8p2zlqOevq8wCEvXrt0OZ6rIAlnWyvOg0i
	wW3/X/Cr1O8GUDoX4VMAn/C6/CyNzrIVwm/uKbgAoHTXK0ekxDshuQiHhZbgTjmey8g==
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr6557pjp.98.1565043624769;
        Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr6518pjp.98.1565043623885;
        Mon, 05 Aug 2019 15:20:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565043623; cv=none;
        d=google.com; s=arc-20160816;
        b=FtHp1KP4VIDi77IO9tA2KwIGMnv7R0MUoQu0cN4EX0n8mkL4M576ri618spUeYz+IW
         4WSHiIhsQJjMvLP9flo6/HPPmSECM1puDDRzosAVCJ2YNlP329e/OmAzAbPKgVOvox52
         vszMi3wKjfkn9KyJgj1eR7Fy0QsLBKIjN94u2nUSLq1MjKSEbaeTEMJG1CbCtIQ65jY4
         PGynS/ZzaT8un7RSBVh9uaEmcXkz2Z13U6a6aDwJ8gD+K5tZHPZkjgwWm/Dz9Pt9kik8
         HcwnYtVm5q8kDP2fDLXsStkSr0AtwC3KqEZPf+xiKU9UFmSEO5D+oZNYvlE0WHc567P0
         nb6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=zwg2XTdYg53+MNr/EqzNhpSxOns39woGoMDGv7U2MxmiLyrpy42l5ZvZW9Q7LDpNjE
         0IPAbq5ZbgeXnE3t5WllO/M+HAJQ21UEitdpxmjt6irf9UZCluHinCEojBE3Dns7SnYw
         dQboYqAQt7bA4JZ3H5CHHhzCYjUydhhW/OwsaafgCO+JVx5I8EJnfOH5UExQ/EqIZjdJ
         BuWR1bbAVRCzHSrcpsKVL0EQLuVqE3mLS33PFFHXKghxgrYscM1/QwWzLU8INQshdVxv
         1pwhtIZNzEbzsdypMX8PHByU/vAtfZDzTHlWm6S/cFgSmK3s/H0uHuI92i07w8bh5ChL
         EImA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pKuvlg2h;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w24sor101312231plq.4.2019.08.05.15.20.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 15:20:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pKuvlg2h;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=pKuvlg2hwoarkpfTNR6KpixqG4Wg34fPCZG//9C6ep56sknR9I6vumm0Lj3xNQ1iy7
         An0z5XnlgimFQqRa05txx12NevWhyV2Lb7x7p2vHSDc/vJyL1UMYh04P9z/8PeBlcmof
         KbVsF4kxEcmAWh81dDR0kLUU+u0G+IpIho0ZKDYJ6YObrCosO+58QStFqlNQi3Rqxkwj
         mXW60Rl4Ow9n9Sdcj6VEbxH9m4Ri+EM2o4zS9fB6QgzhPUmrUTRomPfxUofSeQEGClbH
         C3e21QDeVMlfxyNkwOcnJ77HHrUIJvK4WErEgQY92HF4We5BbAHaiz5aLeeZQO3yjwBd
         vyIA==
X-Google-Smtp-Source: APXvYqym5DWO2ynioA/LXqxbhVbEGp7NF1n1NiggZv5NF8aTVSRSKOlyn+2cbWlflhCbI+qCdy/2Cw==
X-Received: by 2002:a17:902:6b0c:: with SMTP id o12mr24420plk.113.1565043623671;
        Mon, 05 Aug 2019 15:20:23 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 185sm85744057pfd.125.2019.08.05.15.20.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 15:20:23 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	David Rientjes <rientjes@google.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH 2/3] mm/mempolicy.c: convert put_page() to put_user_page*()
Date: Mon,  5 Aug 2019 15:20:18 -0700
Message-Id: <20190805222019.28592-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190805222019.28592-1-jhubbard@nvidia.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
MIME-Version: 1.0
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

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f75b37..76a8e935e2e6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -832,7 +832,7 @@ static int lookup_node(struct mm_struct *mm, unsigned long addr)
 	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
 	if (err >= 0) {
 		err = page_to_nid(p);
-		put_page(p);
+		put_user_page(p);
 	}
 	if (locked)
 		up_read(&mm->mmap_sem);
-- 
2.22.0

