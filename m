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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 385C7C32756
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4232089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oIs58MXE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4232089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561106B027A; Sun,  4 Aug 2019 18:50:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EA296B027B; Sun,  4 Aug 2019 18:50:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365C86B027C; Sun,  4 Aug 2019 18:50:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8BD66B027A
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so52210821pfe.1
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=rEloXxGBMxgt8G7vohGW76+gRw0p522KSdiKvklxVSliSiYVYeEXrbzoXIWquz66Z9
         PQ7RcKfrC8U2TSIW3ZfAnXiLsZG1+CN7oOsrvOkcrkwqdq/mQBqNCgAxwRqhAPE1hysp
         cRtExPq4cDfk+nGShruA7kmXM8OKRBYGbh/JnP7V342hRps386iXVcyPmAHjdIkg1+Cr
         itfcfEGYPXftlOFplD5DBNNpHJGHFLcVpOdgy3yTOES+801MipLrApE9eRLkBNR/jLPc
         QP8XvE/u69B6y5Vz71NcjsE1rSsvUqmMDgGRs6vlariPFbZmzCm/WVQXgcvawjPReW9W
         OZ0Q==
X-Gm-Message-State: APjAAAUKiHzvX/QH+nS8xeO2GxytFjvCMP+JDysLIStTGAFrwOsu3gsy
	PJ2MhCS4K+wFe7pZUUYNJTa1rTHkTogEzJyrlJMcCY0Wx2s7dcQo2bq5nuNEsk9Ne46QkyIfLD5
	bb32w+/dYvpKrVoJS8nVe4UdwTenmP7Py1aHtNteJcA0Ld8WMuFiBKK3OkAjp470Qeg==
X-Received: by 2002:a62:6083:: with SMTP id u125mr69023568pfb.208.1564959001653;
        Sun, 04 Aug 2019 15:50:01 -0700 (PDT)
X-Received: by 2002:a62:6083:: with SMTP id u125mr69023535pfb.208.1564959000921;
        Sun, 04 Aug 2019 15:50:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959000; cv=none;
        d=google.com; s=arc-20160816;
        b=EWHI+//zJ51K8XGmvPreMxSYrHPwGojjbM/3neKCiS8yPPoa05W6e/gWNXRqGLRVi1
         OSWJ6fGo+Z7yU+MkLiitus8Rn7Fg2n2zVkAPaNDmz05jTXqBJfxbg5HZyXHeDzvl0IbU
         j0Ed0+ctm2u7k5L+0jhZWyUVyOu+ipPoLTuf793iBYjy541evkpZuhMebr7qzt+G+iHv
         5EeMVHVh8zcUEnDr57fG1Wr0vSAKxzDAk2Zp4M/FB4ObSkL42Jgp95ESQxyLbcj6IhGm
         hJMGWoA+tmbgBpG5/3udlrVfxjuRITeSP9P8Zqx8ZBPCnXwd8VE+Vu1CxT+DB/0QKAXR
         SESg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=d+Dy7ljKyUjbAqdQreTSntQMrPvdPzVa3L2t19HRGcBJS5x4RfjdzO37b0fAToxqaT
         GgykXvASm+ab3QPQS7JjOVbTPL5UfiX8pIwCYjY5MU29CjX1ily51L3I8rCF8OaHpaHl
         MeA7C9teJC5u0DEtD0wpLcf6lygBMXhGdRtXCHfj8RRuf/75ZQOxeM17P7oK5puSK0pS
         YIVR1YInzhmQ9mxkwZ1WQc60w6h8X688A1APXoc/m/RrTPo98ADbwzEVqNbUPWE5cT5l
         P9JQnFjJ1CQZ45E0soTtIz8AhLyvjiamiQZTchg4IyjIjMzdiXxofbw+TWgQyxMZBwp0
         EUcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oIs58MXE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor97650215plo.62.2019.08.04.15.50.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oIs58MXE;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=oIs58MXEzvjiKDUeW9Xx92JohiWAGomnLQHItXPj3gpTBXaBLirgbU7J3jjvMstF5d
         BR9zwxRQqnHrZHmC+32LB+Dm9++A3dYw7Z2gJLbUoT9k9Up7ZxFGUG2x0WkDD/8qau+X
         8ICuV69VxIrVLbwg5iBoAnxA83TGhAb0DJKf1XP2ErlJJVcbhXrO4o1FNI28ciyGEPgV
         qFlJ/47uB+ONPIryHewnPf7OnXpaPBMbJVHPddHFRguTyQ/cP/UdMYVUDXMppTee+whc
         a4C30SWihk27rz0hGEMgPT9159ZIY9uL4Q4yGaDE4CFFho6QVBfddU7eeA74Zc4mT+ns
         u84Q==
X-Google-Smtp-Source: APXvYqw3vCtbIdRevAqGeALSRYvYtlE73TuMq0puGfIkY6Ze8a3qg+Hme5vTx4BKBMgk8zaLu9jyhw==
X-Received: by 2002:a17:902:2b8a:: with SMTP id l10mr141386929plb.283.1564959000721;
        Sun, 04 Aug 2019 15:50:00 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:00 -0700 (PDT)
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
	Keith Busch <keith.busch@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH v2 26/34] mm/gup_benchmark.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:07 -0700
Message-Id: <20190804224915.28669-27-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

Reviewed-by: Keith Busch <keith.busch@intel.com>

Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: YueHaibing <yuehaibing@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup_benchmark.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 7dd602d7f8db..515ac8eeb6ee 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -79,7 +79,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	for (i = 0; i < nr_pages; i++) {
 		if (!pages[i])
 			break;
-		put_page(pages[i]);
+		put_user_page(pages[i]);
 	}
 	end_time = ktime_get();
 	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
-- 
2.22.0

