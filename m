Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BA95C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5076206A5
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u2UtpKj+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5076206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74C976B000A; Fri,  6 Sep 2019 10:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723476B026A; Fri,  6 Sep 2019 10:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63A136B026B; Fri,  6 Sep 2019 10:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 444676B000A
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:54:46 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CE518824CA38
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:54:45 +0000 (UTC)
X-FDA: 75904792530.17.ocean29_63bb0a464fa27
X-HE-Tag: ocean29_63bb0a464fa27
X-Filterd-Recvd-Size: 4559
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:54:45 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id m3so3618020pgv.13
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:54:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=u2UtpKj+SdvdC7zNNCRKGfWXo1ykUbLduiISlK7UKVNWKJFj7hQRsxtRsM+Ng+JDcs
         v7XIQ4GRg8UpI0VLI4x3HWqouyCX8JuhCd7BtITu+IvldqmAvamdMQRLR/oEiIkIDVDP
         VFzD84K523Z9VpGyOqGTX8ekpRwerKs9WPfJYRFvR5/Yc/QO9drW8rNetKJQZCnQNepA
         1bO3dX5jPRDMkcPBCJdcwOBp6JxR6PqiCYzLbc8uX5ds6xPdIum29TV7dqmdR/fHlT16
         ao4s/16BbpHnyyT0U1nuALIAl+ZaBH0Apbb5NbsVqY6TVc44rduuB/3bWDd/yhsJtFEB
         pXjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=Znpq81Gu4yoXYrCMOaR5Fr8UbZB/6Va/e28/2jkBM8FfL4sQb2DQ05ZkR6kqAXKw4C
         5BMIDeupVWDsDU3jc32jEFBnOZhQMJa80leQDgAVnksgF2G4hWwvpjNDtT5Jwxw0l4WL
         02XQJWVs/9QlRsIj5EX9sXOg4iB0U6i9XZIrY44f8ahnC+TaO6TBjCmk+5Ent0NdarkY
         UpMm/BdbSqY0AsySNO7uHwdyNhU6kSyPy5u4rzm0SEGIe+UW73FmQHiMITfTWain3Prm
         u+vp9P3rCggpWcD6jdSMmJeOtLeIFCfSUwn/DS5OTet63hKiZTCuQfhFeN6RuEOlHFm7
         Et0Q==
X-Gm-Message-State: APjAAAWlvwzCWqjvZo7WFDkUNnnQcrwoVsObUsJUBuIh6eXQxYBD3P68
	qJQRrajLoa9ikSEJcLr44cU=
X-Google-Smtp-Source: APXvYqyq7c3ys8bBHJp63ctlkK7wT7XGiRX8LnzlMCbygnwq1ZTX0Wq3ookzg6WHVMz7aVn1zyE+5Q==
X-Received: by 2002:a65:464d:: with SMTP id k13mr1589674pgr.99.1567781684235;
        Fri, 06 Sep 2019 07:54:44 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id k14sm6784077pfi.98.2019.09.06.07.54.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 07:54:43 -0700 (PDT)
Subject: [PATCH v8 QEMU 2/3] virtio-balloon: Add bit to notify guest of
 unused page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, mhocko@kernel.org, alexander.h.duyck@linux.intel.com,
 osalvador@suse.de
Date: Fri, 06 Sep 2019 07:54:43 -0700
Message-ID: <20190906145443.574.8266.stgit@localhost.localdomain>
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add a bit for the page reporting feature provided by virtio-balloon.

This patch should be replaced once the feature is added to the Linux kernel
and the bit is backported into this exported kernel header.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/standard-headers/linux/virtio_balloon.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70de..1c5f6d6f2de6 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12


