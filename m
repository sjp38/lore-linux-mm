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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB383C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A72612080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SN9JCWjR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A72612080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E7F86B027B; Thu,  1 Aug 2019 22:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2735C6B027C; Thu,  1 Aug 2019 22:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09D326B027D; Thu,  1 Aug 2019 22:20:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6F1F6B027B
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:53 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so40750609pld.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o8Q8kE8hzW/DwKrVVZh1taN77rkNxpuim/5zYvIGd0I=;
        b=X3P0XIyftkvskZZG1kEyi3q5wLo0gMbKGu2wcsTy6JVC52fUKeNUWwmvbkco0scb8r
         ph24fqeWpFyfPmGho7E9j5lPC/reOitja7spC1MBHrHvKcu2NfijIvilLV1cs9xlFtCD
         FEpQ6AzKNwT8W0E+fUb3SfK3eFABWqUmyWcbQYzg9NMm+JEPl4X19DxXGsNikw4ygSb+
         qX8/tTGer+JnVBIT48P0tttQS8KgiV2p7+BtWW3o45R0i8hwC4YgDWIBvUPmIogkTETR
         UYmHLKN2kgvMxKSH6w0y3dpskGMK0CJC1qPNq3RTXJBiP1Xd6MNi9/S2AYNft2bbDJKZ
         W5aw==
X-Gm-Message-State: APjAAAXt2iB38wpjB7u4sijQxpIPfofJvzN/e8cvVbKuoTsMZEzH3d5M
	2csx27nZTWnJ3zx6u/gdu+OXxzBL30xzzVjT0qX5scI9vlKdnjC58oGHQTY/5kBVtCj2F9C+f5g
	hALyHFWA0LcsSg2TyVgTk3f+S0XM2YjpUPsURbEsixXTiOofgz+cTjtXV5TXGj3/sIw==
X-Received: by 2002:a63:6c4:: with SMTP id 187mr114362377pgg.401.1564712453430;
        Thu, 01 Aug 2019 19:20:53 -0700 (PDT)
X-Received: by 2002:a63:6c4:: with SMTP id 187mr114362343pgg.401.1564712452709;
        Thu, 01 Aug 2019 19:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712452; cv=none;
        d=google.com; s=arc-20160816;
        b=oI64TPt/7NPbO1sxjf4AwqMWPIumXNbdvF41QfWOW+f+AD6zZHxaG0tNpoaXABR5zO
         bAVqRQ/iLRQJTQitXgeeWkPP/MDrtAAaqkqItClHDVELATWijswvzkBV7exhf6tTT0FD
         lFZYrQz7Gz27nplowuEPyLiJt/dpltB/KSnNJKw8qLZHyNLjNt0mXvUCBwHkiZGn5H9X
         iL/HpRXVfSlx72FJbpP55tYeJnAS7Gaf5nJgxQN7ChXpUxvtzts9MGXxi7fJuFAreoYM
         VSLWcZjma/u7WIkqOC4IKtxmFG5WxEtk1R0HJ7uX03tjgCslT3GqpxJq7BlrphMEtD16
         IuIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o8Q8kE8hzW/DwKrVVZh1taN77rkNxpuim/5zYvIGd0I=;
        b=CNpv0+BK+aDdYzUssByZ59ssQHq3ykxJwk9o3u2Boj5y/tMRyF4b02IGlHTeTeOPFb
         kBq5JRlZz3/ANY0tDyNJca4sofnF5uzEaojMcq5TOmHzDtBMotAGX3P/nNa7Ugb8Jri+
         DXaOB9dF+z/iyZDimi6XmzP04cn79vi+vmtBp+xxQ9HxAISscHTXM1RVCxYEC8HLWvfP
         PxFba0tMMLhAyopb9I45sbd1PhaHq9ddPHD5BL7vafWCDRYAXzJcBOGc+pe9HrMg7UaX
         rhSmHnG15H7TXs9892GkaHQ8qKpp2FA/JnBR1RRpdwwh4x7JAyXfdVlJXdOmo8DoBQAc
         oZNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SN9JCWjR;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor88629086plr.53.2019.08.01.19.20.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SN9JCWjR;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o8Q8kE8hzW/DwKrVVZh1taN77rkNxpuim/5zYvIGd0I=;
        b=SN9JCWjRa62SDUJKkHaVdcwHX85kw/BYyJx1Oz6MKq1tPWuA+R+kvOX6gTDvC/TGzM
         WuYG+JBQhglp5JUL5bE3kcONL91y/gVNfG1/TEEmXEUkwsc3IV9ZwlZo4fZZ39RQbUrI
         einldN97i3VjPzZmNrk7Gi70UVvHdYeVSXiOY7z0rmJg1OD2RJX0hB2kTyBbOVlbD4F/
         wFv0bPm5s1TrbkD6/tFvn6bnIJfGHM4gcvzjJiA5o2aPM4xOIDqOY4iccbO2F7+VYayI
         O0zTQo6na3+rAYAFM80xDRcL3DANvgDbjQbLbpyWsZCgQEzyIKagAyXZm1uNkiwXdu5u
         s1Rw==
X-Google-Smtp-Source: APXvYqz1YTjVZYS+LesWuf1AG7NOEG7XNcFlAKVjP+75gMoI5m//7o/WseaBl+rAw+Wa9I/u7wQNfg==
X-Received: by 2002:a17:902:740a:: with SMTP id g10mr129917590pll.82.1564712452476;
        Thu, 01 Aug 2019 19:20:52 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:51 -0700 (PDT)
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
	Dan Carpenter <dan.carpenter@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Keith Busch <keith.busch@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH 26/34] mm/gup_benchmark.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:57 -0700
Message-Id: <20190802022005.5117-27-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

