Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA2B5C5ACAD
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 664C821743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qHcz60oQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 664C821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05476B0287; Tue,  6 Aug 2019 21:34:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91D006B0288; Tue,  6 Aug 2019 21:34:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7951A6B0289; Tue,  6 Aug 2019 21:34:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2ED6B0287
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:42 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so49429281pld.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=aXIuP5/U3BnsBPDZKKKZ5MsNh7jYOO8qhSB4KuN4Lmk6crwpxT7gFFTUlx03E9eS9j
         DWReu6YtbmOAf5wl+tE7BY2agYPSJmA/73Y38xFAyUmtNM9YteseS1z51S4uMcsXyIRs
         9mqbxk0YKdP9cRVvdR8AqVwy5fOZOQ/kdg8nRmMp5LkRPnbKmCk40X5ADhYD8HNoKgNB
         OzSS5V64LKxpZbkFSfsYavJkGe7dkrRefyelGFv4hLcb7j8vnHuIC6PJN4ah69jD/ttK
         ADV4L3Sf0Nm55wQB+eoq8zEiVbv6pt2yiKMV+U/VA9CoGG73vbWQ21KJ/xLoxxslED/o
         ADEQ==
X-Gm-Message-State: APjAAAXPSRznFsagsAG5BHwwuGQRtNn5wxh753lW4TMWKR7ZJzqKD76G
	1m7QZgoL4b85bSbO8ayInSGaplccCGUrSJbc+SHHIkA0D90Qv/tq6PuFbQECysEfKLeLeD/SOiq
	AOf386WyDLP/IKZuiOj65t6fxW/QG/Rds5+F8vG31l7e9ZzQ2AnKsy99a+YZNtAm5Og==
X-Received: by 2002:a63:6a81:: with SMTP id f123mr5641872pgc.348.1565141681738;
        Tue, 06 Aug 2019 18:34:41 -0700 (PDT)
X-Received: by 2002:a63:6a81:: with SMTP id f123mr5641842pgc.348.1565141681078;
        Tue, 06 Aug 2019 18:34:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141681; cv=none;
        d=google.com; s=arc-20160816;
        b=MRkHK1+0fxnKTaj6D0xcXbecEIoRVvKuJVnzedb1owVbZ0p1/L8PYq/3QLZEbk6J2U
         DR2GmsnKb54y/o9G/9UBy8YAREZggGdFZHYKGDMEnGm8AXE9NgPMakVLIV8OU0koNfp8
         eV0fQ+9BdzI/j6N2McKXUgJwYe5lVTQpakZvOTZEQpNgSkzSJoTEki4gPnH66qavh+/q
         v6KRZgGNFCJJVN20PglOyomKWxiGIcowOqnAAnSJhDcDZAfx6URw30nWbYgaLveK+AR5
         ACDz3Rd4VJz78Nh6LO4MCAy0LcrrtVW6YuYcKaVfvAvv5gQTmT9UEzw8zNnmDqOPLPhT
         3lwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=g5IzlJQHVlGY3bpOBJJ6B5jg6dA8vj8QkeivDejVok2WnlRN6U77Wn0ZH0i02iZzgW
         G9XiWYpyZo71Nk7Z360vGA8jpLh9kZTYLjZr5c2wHHsocHRNRjhw83A8fhQ2d5pRa+I6
         0hlMZV91oASHoSd3VIus01UXFkh+VtW/CzqSNQybHMnwFL/Lj42gKac4ztJftoYTzuj4
         bsK2TZ+El8sdNiVVsRJWq/slwQPYpfjN/22XG7XacthYtSVQrKZ7XR9YO4BKQ4a3Q+p8
         4BKUNxGXwtJJll3ONB9PHjXoV+GwkcyyQUC8ijZFvwPRBqHnXM8M4lQxLy8VwpWutbco
         lsvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qHcz60oQ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a3sor69774307pfo.61.2019.08.06.18.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qHcz60oQ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=qHcz60oQ83bzms/yVUcFaJau5DPrqarhSsDZyTTm0aO7LPLndWEmnFBY1sB89Xkiaw
         Ci5ELNET2QWDN41lDa72vOKuXFO7msQrNQNCW1tufAtPZ+zmR4yxxt0Pj/OC6oGA7iex
         3PC5yUmc2AVOKzZpAx9HhCU3diYcJOxr4dArt0xaN3xcKrvJPt718EmEODcL7rIiZeeH
         s/ExfBknzqo4fU4jgwTtrXK+8yIatr5xd5LIRucVBNPseWxbqe9SNtY40agI2WekCzaT
         jqwlI490o0ssAFzKQmdqp0Jn6NCj4NXSf6medXNB8StHKBNUjeQuhT+5EwaqcfdTeEZ0
         IJRg==
X-Google-Smtp-Source: APXvYqwi1XftPUxFaKwB1e+PTjWB5bVcONCYmxHiCc+kjqKz2w944/jyq9w+bhKvdiZQur9bBkceuw==
X-Received: by 2002:a62:3283:: with SMTP id y125mr6853502pfy.83.1565141680836;
        Tue, 06 Aug 2019 18:34:40 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:40 -0700 (PDT)
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
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH v3 35/41] kernel/events/core.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:34 -0700
Message-Id: <20190807013340.9706-36-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 0463c1151bae..7be52bbbfe87 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6426,7 +6426,7 @@ static u64 perf_virt_to_phys(u64 virt)
 			phys_addr = page_to_phys(p) + virt % PAGE_SIZE;
 
 		if (p)
-			put_page(p);
+			put_user_page(p);
 	}
 
 	return phys_addr;
-- 
2.22.0

