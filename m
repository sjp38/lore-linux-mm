Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D25F7C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF7B21907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oBnQ2jVN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF7B21907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3277F6B02E8; Wed, 18 Sep 2019 13:53:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B0186B02E9; Wed, 18 Sep 2019 13:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19E056B02EA; Wed, 18 Sep 2019 13:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id E68BF6B02E8
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:53:09 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9CA5E180AD80A
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:09 +0000 (UTC)
X-FDA: 75948787698.15.sink83_1b864687ce54b
X-HE-Tag: sink83_1b864687ce54b
X-Filterd-Recvd-Size: 6075
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:08 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id w6so313224oie.11
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:53:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=TbxSoczAuzQWlH6idgeC1LPIVw+1Ea/1DcsLl7A3ATs=;
        b=oBnQ2jVNymUtlpzhKot6hsQqUxgEcS2+Wppxl37IJ5vWnUDzpQOVCbjCzXqi+pMD/B
         9/d5e/KjwjUvfuhB/YZawGYKq2YCSIv5eiiFoWMxEDTohEh/HqnCIK8BCUlXJQK+bcWx
         lTIHd2cAGkLXBhY4o3cYdtKnC/+U8jZcEvat3yVtMyG4HTqtLHu0j/vxvpbYsqn8D0Pd
         3F6w6jGYi9FX9W/9bPjzaGszHWkOrQbUc2vLLQaVBG04zvI41UU8cuCUYyxR9HCoMc36
         /M8rqm7rT+FGb20S7RPlbNWi0rZFo91eQCBIHFdH6HZZC3cWeNY2l7PXp0NSneQAiXj4
         gcBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=TbxSoczAuzQWlH6idgeC1LPIVw+1Ea/1DcsLl7A3ATs=;
        b=lM+OG7TDcP7oSI94hP+6a0oTTSU60T9lkkplH3Qet3fvop06NdP+PrkZtZXztPfRm0
         ffdnaybotnpbP0+mtYLX70MgnXDWQZKr4LgasjuxYxV6jjfEaxvR++a0oxfmYQlsTWdQ
         S4H2q7pSl8DDsjQFhDX46wYNGkRn5JKAPpyofkvUoHHhzZUlUyKRkd/O5qCW5Lz6fd1j
         5vvQMTAGRfYlsqlvHEsz+tHmdwYbdYHko2fbHRnvZ9GOCTIJKPfFxl+CJmw/OqEJnYlo
         NCirmJ88v65ZIJntWMv197ExwenYwKbNrYzNxtiZyfAgaB7AnqlSDZTyn6WJIExJFXVo
         8z9A==
X-Gm-Message-State: APjAAAV4pPEPhnFIm9o2tUrLPYSjAB6caWRNzioF+sqkcRRY3ocVEpuy
	oOqiReekntt+YYWUPkSdrB8=
X-Google-Smtp-Source: APXvYqyphG7ufZuHFK93raK3ouPQlCP9yyxW6Shrp2cdGc2jcqnuHjGAcaUeE5X6UXUakwcIPv1r5w==
X-Received: by 2002:aca:c088:: with SMTP id q130mr3257073oif.54.1568829188183;
        Wed, 18 Sep 2019 10:53:08 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id u12sm1838437oiv.29.2019.09.18.10.53.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 10:53:07 -0700 (PDT)
Subject: [PATCH v10 5/6] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org, vbabka@suse.cz,
 akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 18 Sep 2019 10:53:05 -0700
Message-ID: <20190918175305.23474.34783.stgit@localhost.localdomain>
In-Reply-To: <20190918175109.23474.67039.stgit@localhost.localdomain>
References: <20190918175109.23474.67039.stgit@localhost.localdomain>
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

Reviewed-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/virtio_balloon.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..501a8d0ebf86 100644
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
+		 * Let the hypervisor know that we are expecting a
+		 * specific value to be written back in unused pages.
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
+	/* Tell the host whether we care about poisoned pages. */
+	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
+	    !page_poisoning_enabled())
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
 
 	__virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);


