Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BFD4C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA1EA2082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 14:54:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bPPkGTOw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA1EA2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C1C96B0010; Fri,  6 Sep 2019 10:54:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 771986B0266; Fri,  6 Sep 2019 10:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 687906B0269; Fri,  6 Sep 2019 10:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id 473876B0010
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:54:02 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CEB3F441E
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:54:01 +0000 (UTC)
X-FDA: 75904790682.10.music96_5d555945d4727
X-HE-Tag: music96_5d555945d4727
X-Filterd-Recvd-Size: 5922
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 14:54:01 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id n4so3652223pgv.2
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:54:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=AHQp5tHq/YPoexLkCIK7ZDm0IJf6l4a1w2EjvR3aV6g=;
        b=bPPkGTOwMShliBXTYkGU+Y7gS2k5f6GuxSKDdDImp0r+6cm/SGw3Z9il2cozNyQD4A
         rrkMvw01sUNMbTaCgO5v7bidEsODr7WobPfVj2CFPf+LowvEF739obAgFrhzani+HO0Z
         oUqRc/ypQrZW5Lxjrh3ZWHvNqSYVUwnVnAosL50TJ8FPneWm2NcmF7TMO8Anh0nFWxKX
         lBT8bPCfp4GIbfcPizDQzQcJScX2zMMK5yCNv4i4+ziVXOSB84HVTPXfrk0ErxLhZ/jA
         xYTRQFQXm2n7IADPk928Uk39UhO6FsNvDgDiZglUYhH+fRDAoZyHgmBZjyeECQNZD7At
         CMVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=AHQp5tHq/YPoexLkCIK7ZDm0IJf6l4a1w2EjvR3aV6g=;
        b=cnvM0xvIGgGzTotKCY+PVdd5aRzhEZlD9S43MHC1krdwxEGKdQEn5Ho2LtPddXXj/4
         oyiPUXAgLyty+oeQr5MFurLI2v8xa/ki3OEGHCeymqmOKCaS2kYt6EhHjvKqom7ShQIy
         Zzn2q9BgSJSYoS7zG/Jl5wEkp47pw5hve7F/hSoy6F79VJDaBOlVf48K0ny6gSw+53Pm
         p/e9k7/BhtzCHEMLFgnL3Wbi6zTjopoGwgKwLRb70rU2i9wXrlPDOYTmjrV5/aOPKl8r
         MCtm1XCIkTnDYZp/EB7YQz6ttIoaYJibYlyDd/yFTEzXP5ARxK12g7TSnC9D3Q1s2VVL
         z2Lw==
X-Gm-Message-State: APjAAAUc6YM05rpCBpx3qQyzJQGJ7pbZ65KgErIeiXN6PyjiOFUsxSbp
	k1eCbQkrWAq5Nh7/ZwRbRGA=
X-Google-Smtp-Source: APXvYqyR88QaZW39OsZnSfUJNlZNz+FucCLSQWJ+wyogMMJFeT5wM5gYNUWyTeVyXc2YZ1Dse/fCOQ==
X-Received: by 2002:a62:2603:: with SMTP id m3mr11436590pfm.163.1567781640326;
        Fri, 06 Sep 2019 07:54:00 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id z4sm5219331pgp.80.2019.09.06.07.53.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 07:53:59 -0700 (PDT)
Subject: [PATCH v8 6/7] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Fri, 06 Sep 2019 07:53:58 -0700
Message-ID: <20190906145358.32552.1155.stgit@localhost.localdomain>
In-Reply-To: <20190906145213.32552.30160.stgit@localhost.localdomain>
References: <20190906145213.32552.30160.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Currently the page poisoning setting wasn't being enabled unless free page
hinting was enabled. However we will need the page poisoning tracking logic
as well for unused page reporting. As such pull it out and make it a
separate bit of config in the probe function.

In addition we can actually wrap the code in a check for NO_SANITY. If we
don't care what is actually in the page we can just default to 0 and leave
it there.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/virtio_balloon.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..d2547df7de93 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
-	__u32 poison_val;
 	int err;
 
 	if (!vdev->config->get) {
@@ -909,11 +908,18 @@ static int virtballoon_probe(struct virtio_device *vdev)
 						  VIRTIO_BALLOON_CMD_ID_STOP);
 		spin_lock_init(&vb->free_page_list_lock);
 		INIT_LIST_HEAD(&vb->free_page_list);
-		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
-			memset(&poison_val, PAGE_POISON, sizeof(poison_val));
-			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
-				      poison_val, &poison_val);
-		}
+	}
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
+		__u32 poison_val;
+
+		/*
+		 * Let hypervisor know that we are expecting a specific
+		 * value to be written back in unused pages.
+		 */
+		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
+
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
 	}
 	/*
 	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
@@ -1014,7 +1020,9 @@ static int virtballoon_restore(struct virtio_device *vdev)
 
 static int virtballoon_validate(struct virtio_device *vdev)
 {
-	if (!page_poisoning_enabled())
+	/* Notify host if we care about poison value */
+	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
+	    !page_poisoning_enabled())
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
 
 	__virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);


