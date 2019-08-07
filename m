Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B673C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:42:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6E7E21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:42:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r8JTp1EZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6E7E21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A8366B000C; Wed,  7 Aug 2019 18:42:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 959726B000D; Wed,  7 Aug 2019 18:42:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 848416B000E; Wed,  7 Aug 2019 18:42:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1EC6B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:42:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 21so57678402pfu.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:42:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ee1mc4VxnFFfQeQcZzbu/0JmrNIJIkJCiHbNbTiM9tQ=;
        b=ss/Sg0LliuNo+XuL4DF5OuMHoPv8C4PwawYXNE6L5eL6d+fQnDN2rAoH+zA6RnLQ/O
         WDJgXES3RMpox92vHvrQoosung7DqO09W+KrNehxYoBeycOpr27udQ76kJj9WhFiBbMh
         RkUeoxT0v1PRdxCsp1U4Waa1dHZhSTejtrPt/umDNU+3slH6GosJ3OeYkpzxf9QFQO2J
         UXI4YCXc8kiTk32XUF7sqWDmomr7ITqqAOsb0O/ENLtZganSeMRfygruwR9WgKL3kgqj
         CAe9D0dwwZVTyWmDDADtbKCQQul2Ds57Yyf7T/IZDDGaTYRUa092Efeu+R1haBGnVU9u
         Xdpw==
X-Gm-Message-State: APjAAAVNmk14/1ZUYTEbNLmzsUVn9tVO6bpzzaPBN2aKrT6/eMpyBzvb
	V6EO7JyXN+rpgA+Ncjv4hnmG4GlJp/H1IQ4MX0Law+HWjl9IDqyKBB7yc+8MB/27VDnXkHmKlbI
	IbGK6Eg7YwO4xRiTw6qzIjSWbxKDHLWxwUgVj/1sLYbmspUme0B35rJt1ti04DDpOgg==
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr733387pjd.122.1565217735991;
        Wed, 07 Aug 2019 15:42:15 -0700 (PDT)
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr733303pjd.122.1565217734680;
        Wed, 07 Aug 2019 15:42:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217734; cv=none;
        d=google.com; s=arc-20160816;
        b=Ko0c4MkB+/kziJrNLYYUvcxj3jmFKMkmjB2gTfNtd3kfYtiohhwbR+ef2C/aCmENpG
         kcvW4pwC/o5ZgA/yk/jCOcMOL+CooJvsBOqxZrd88XLPyN/twZfJTVUuRwoAupJCov3D
         D9ldQ+28eluxrhzlPz4jzSwOORhuT0Mhzl6U/pZsAzPc9WanNqRi8RBp2SukgO5/0wI9
         aYhbKZiPQIKnqbqPWelfwc4E7/v5Y+GIvXnQHKBISZA9b4SQgaIiyigK/zSgx741HIIS
         TBr1PHxDDWNybKOaWy8KRIwXRPdfw1cIGSVmVcRAsc0H07cwj8uWr/QHeK3ZC0caJK0n
         KAMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=ee1mc4VxnFFfQeQcZzbu/0JmrNIJIkJCiHbNbTiM9tQ=;
        b=yX0JvaFePawG4CwJKnjkelKMi0J+fYQIsONWu5SEZKwHmz8ifvB0E5uQTwwgr7pLbI
         6DezLLREAIYcPaFvg9sYiXA7DEyXkjxDCtTTNeVWkKZpJb9X6oa2uoAETvtVqxAW3ZDa
         GPCK/fW/Mkq8CNixBx/RG0Rjdd9G8CTuzbCa3JPPTrdAt3dhMAln1srvpwIZGKXoEW+W
         QwPYf12aqVxgq3kwG2eqopXrv0Ig5nfpO7ElRbuv92m5uwXBKhggGNkLcglATQjRT9di
         CjM/qaD1akWgTLJTHw9O/V6qia8gIgt33xAf9u8Bslt+h4hGvbC4ZBrK4zDZxzERrgsi
         oPuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8JTp1EZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m93sor521959pje.1.2019.08.07.15.42.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:42:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8JTp1EZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ee1mc4VxnFFfQeQcZzbu/0JmrNIJIkJCiHbNbTiM9tQ=;
        b=r8JTp1EZK6OewkxZ8F+auXR18QN902AIqN0vePsif429O7Lq1avQFEozAWWPhbBC9B
         Q9LrzH1hVnA8Tuytm9wyTDaPe2zY89WCnOGZ+pmOgCSFL0FfcUlG86M+YIKKRTuLggiL
         6a3p5U1HW3Ics5uUYZHYDvdHKCG8SGNS9YoTjADP6wdCGmzP4vQe8EwOTA78fFKT/Yrm
         IQe3D3oxce6LDsVEss9rrkHamPvBurz9AguWf5yuxH/xJjMpuTsoRGPGsIoVB6ZG5jWU
         gR4O33MmIUVJ/jUHWmGeBwFfXD56gNpy593tW446eui/cfRgMlcJc88tGxIODG0qgKia
         BHrA==
X-Google-Smtp-Source: APXvYqzDgU1Eu3TfqN8qYWP+6kqzZlo0qvhlv0y+xOqs55iUCb5VENOWMnPojOI+y+v9CnUzrfywew==
X-Received: by 2002:a17:90a:8a17:: with SMTP id w23mr681830pjn.139.1565217734198;
        Wed, 07 Aug 2019 15:42:14 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id v184sm90677862pfb.82.2019.08.07.15.42.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:42:13 -0700 (PDT)
Subject: [PATCH v4 5/6] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:42:13 -0700
Message-ID: <20190807224213.6891.38062.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
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
 drivers/virtio/virtio_balloon.c |   19 +++++++++++++------
 mm/page_reporting.c             |    8 ++++----
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..2c19457ab573 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
-	__u32 poison_val;
 	int err;
 
 	if (!vdev->config->get) {
@@ -909,11 +908,19 @@ static int virtballoon_probe(struct virtio_device *vdev)
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
+		__u32 poison_val = 0;
+
+#if !defined(CONFIG_PAGE_POISONING_NO_SANITY)
+		/*
+		 * Let hypervisor know that we are expecting a specific
+		 * value to be written back in unused pages.
+		 */
+		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
+#endif
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
 	}
 	/*
 	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
diff --git a/mm/page_reporting.c b/mm/page_reporting.c
index ae26dd77bce9..68dccfc7d629 100644
--- a/mm/page_reporting.c
+++ b/mm/page_reporting.c
@@ -250,7 +250,7 @@ void __page_reporting_free_stats(struct zone *zone)
 
 void page_reporting_shutdown(struct page_reporting_dev_info *phdev)
 {
-	mutex_lock(page_reporting_mutex);
+	mutex_lock(&page_reporting_mutex);
 
 	if (rcu_access_pointer(ph_dev_info) == phdev) {
 		/* Disable page reporting notification */
@@ -266,7 +266,7 @@ void page_reporting_shutdown(struct page_reporting_dev_info *phdev)
 		phdev->sg = NULL;
 	}
 
-	mutex_unlock(page_reporting_mutex);
+	mutex_unlock(&page_reporting_mutex);
 }
 EXPORT_SYMBOL_GPL(page_reporting_shutdown);
 
@@ -275,7 +275,7 @@ int page_reporting_startup(struct page_reporting_dev_info *phdev)
 	struct zone *zone;
 	int err = 0;
 
-	mutex_lock(page_reporting_mutex);
+	mutex_lock(&page_reporting_mutex);
 
 	/* nothing to do if already in use */
 	if (rcu_access_pointer(ph_dev_info)) {
@@ -305,7 +305,7 @@ int page_reporting_startup(struct page_reporting_dev_info *phdev)
 	/* enable page reporting notification */
 	static_key_slow_inc(&page_reporting_notify_enabled);
 err_out:
-	mutex_unlock(page_reporting_mutex);
+	mutex_unlock(&page_reporting_mutex);
 
 	return err;
 }

