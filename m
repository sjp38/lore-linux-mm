Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA3B9C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A64CA2173B
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:26:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ecBEnwAa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A64CA2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7586B026A; Sat,  7 Sep 2019 13:26:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AE256B026B; Sat,  7 Sep 2019 13:26:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EB706B026C; Sat,  7 Sep 2019 13:26:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8A76B026A
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 13:26:07 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DC33F82437D2
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:26:06 +0000 (UTC)
X-FDA: 75908802732.24.sail72_18379105dd133
X-HE-Tag: sail72_18379105dd133
X-Filterd-Recvd-Size: 6086
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:26:06 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id h4so7547883oih.8
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 10:26:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=AHQp5tHq/YPoexLkCIK7ZDm0IJf6l4a1w2EjvR3aV6g=;
        b=ecBEnwAa8jcMm3IeC8TnBic2IinopWGcdT+gykKq8NN/pNR/UsFniW4E6oZ4LvNXJ+
         0ftCG8IxxKLzYezZvy3li5JCrUPcS+E9lHb+WgrXsLFwwchEoydNBBzlWqyG8cynU1L7
         nl8DE1tAfOZ6CdK2q+uf/OirvdrfNAmR8TGHZvB+DC6f/f3HySEmRUqEM/yBc9sJ1z5p
         mM4klXYndf/6IWVBtaTtXYSktQRC54sBy8s2djTgAxvWxzQa3CEI0XqpNho+lPEf9M1n
         /RpDq0HSOomk55lg3gjG5JihpeUBs672XU4jUHcmv+sGTj8Znrr57lBBzvXWiRji5QJZ
         M0/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=AHQp5tHq/YPoexLkCIK7ZDm0IJf6l4a1w2EjvR3aV6g=;
        b=WZapDW5j7I38X72lwf+A9GZj+hPqGCjObZEqCPGONOr2emzx+jD/Lyc8HgE7LF3nWG
         sF9G4DO2CwSN/eJ8vc6ZIez2P1BrcqHq6ejcKDCx9WZCTU74NOOTrYXfdGX2gXYEdAKt
         IkQWLLJ2h8WGCjPvsVPk0j5MBpdkxzhMiv1uFdAVrDgjpso5sWoKWEDWYx4vBxCqVa9X
         FXa+j9Gk0yU0Rp3jh+/pZLnFhMzviK+6YOhc9Zx5f27aM+PaB1yieTgxWbs5UOibt/Jo
         VhvV6nyVsg1OPMQVmkXrGUh4pRoiV95cfrGmjAU5yWzQ/BeBUSO1C/hNvnnWKjOKduCD
         Y26w==
X-Gm-Message-State: APjAAAWS5fWV/q/2poKKzS13BfcRWkf/eAlOaM4gaMSR/zRJXhBJPnUq
	380x90v0ukAtfi9r4Cu9d9o=
X-Google-Smtp-Source: APXvYqx37YQNiv2UtvALkUbv8/xd5ft3XRlho7zJo2uonh25aEKOd4lYhlhEds/sSnzEvGkPn61A0A==
X-Received: by 2002:aca:fccb:: with SMTP id a194mr1637514oii.52.1567877165507;
        Sat, 07 Sep 2019 10:26:05 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 19sm3109533oin.36.2019.09.07.10.26.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Sep 2019 10:26:05 -0700 (PDT)
Subject: [PATCH v9 7/8] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 alexander.h.duyck@linux.intel.com, kirill.shutemov@linux.intel.com
Date: Sat, 07 Sep 2019 10:26:01 -0700
Message-ID: <20190907172601.10910.95355.stgit@localhost.localdomain>
In-Reply-To: <20190907172225.10910.34302.stgit@localhost.localdomain>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
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


