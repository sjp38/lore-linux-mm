Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34C54C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDF2E2084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:38:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XFfZZnwA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDF2E2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896656B0003; Thu,  1 Aug 2019 18:38:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8460A6B0005; Thu,  1 Aug 2019 18:38:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 736C06B0006; Thu,  1 Aug 2019 18:38:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1726B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:38:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e33so4077432pgm.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:38:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=Bdfvu4HHxBfVLWSgMdnzADn8MZtstBiHccMQlRBkiPiPw+QugFxT/UyA2JItcCu/cr
         TvQkSk8h593h/0wFZXQw+RrkW85OrRHwiofXWHOv38AJc49B6gl19uxytSpk3azsgVh6
         yAReq1bx4SxxcX7pnWSFhUchgegMwu7yEnCeqI4vrONQXn2TkKmQJZ2H+iwATRSoGhA0
         JrnaDQFuTxLB3krSS3LNV7nN77O39rItiBPX15nP5l7BjKnhnFER16jLD+OF+GvWZjFW
         YA47k+NBGifcfF4YUYuM+6YB3HOBp51dbTldynDV+Z2tw3fAm4U7yWpPrzQ4DNFTgOPU
         PfGg==
X-Gm-Message-State: APjAAAU9yPWA4r5LFDOCAmNAJK+UUAFl3mlcnGF2DDaJ0aUHX4PUhb5Z
	46/BOFuDo1UchEfyJn8/MwfE3g3frSBrfYYFGBRg5tgi5SdN/JisLjbB43KiFwvHBvqxK1DbLpq
	C/JvUfBW0KjClcRGTw4xr2c/iGGiaElY+ehMnVc+5q1wF6a61t8a2ZWWzhqmvApKGhQ==
X-Received: by 2002:a17:902:106:: with SMTP id 6mr130627023plb.64.1564699105880;
        Thu, 01 Aug 2019 15:38:25 -0700 (PDT)
X-Received: by 2002:a17:902:106:: with SMTP id 6mr130626984plb.64.1564699105071;
        Thu, 01 Aug 2019 15:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564699105; cv=none;
        d=google.com; s=arc-20160816;
        b=Jtg4D0A4JW3h9PsfF4WLLNbg0T+y/vbKSgCs7DsqvSFPB9FWoHwGwn6f7hV+1r/4vq
         muQrnkdHaljPAaddN2XMldQmZPilQRCiEyQywx4DamSpAn+++Pvn1eJyuRrUISEwAvsv
         fgxLmNjpBP0pVML4iEPYVLuqwIHSXKnA7rxtmB77aMw/fE4UvQtXy+ynPonJtLzcHdK5
         081nErSL81k/qjxW+dz4wWKvHyrNs3lj2bL9znwAvZNHbqbuvmUGV0pXqyPLR7X2Vof1
         XmpHOjJ6Vpyb4fbwNnCxzIWf3sIa8infKtw1Ci8DVXt9vcjROm/1Er1HCldVqQA9YBCh
         E2rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=G3w+hv0vxuckGo91bRN3dwgNfbdoLPbBrj01RrWmE0D31FCwD1zs9vvG0i37y7Qp3T
         tYULzow69IJXmEj1ugdTrlNq6aD9MOur4/07dY1a6Xg58Rfv2VF9YUlSk6Oh5aNZkEp7
         wVWhuktQYMh2VgqANzCdoTCG9c50srhvR7YMv3dt8CHgLr9WaPf5ytepUDUhddt6yM/z
         MmaVLbr8YxHx4BG7j9qSOqROfktOmCevyMm8F/BiiBihqauxmIdTPrEOZF4R7aLYySDZ
         CWO4f3U5rORdSUNSw9gsHhkQi3RL7RmCkzgXVcLYd3Bma9WsRh0uajTon+aunk00mcN5
         m/tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XFfZZnwA;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a26sor7613673pgw.21.2019.08.01.15.38.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:38:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XFfZZnwA;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=XFfZZnwAZZwn1mNo4698+qwwq8EWUR8tD+MEvMVS1YxxOJ+XaCbvSDrhXzU0UpPFXt
         RI/tHQXreDa0C0u5/FRzOf7Ug4Gp+Dfi0A/iJfMkpLXdYHW985Tq1ipt6OfuszPSmJrc
         aMEZqE1BEwMU5oPUjvvBzFEX5vwAXakovlY1Jw7sLoIPPOa3ZYA5Gy2T0TfiutLvftMN
         8pfMqm7nhNgrxb+HGgE41icZettMyX9/2/v5b4NXkh7jXBXDn/TvBwD2TX2cgIEOEkeu
         hGXc/K0dQgRhXWUSlw/lE2KpV4Xfw33Jv1WT5XpLWQsyrWaXreinbBozR89Df1egnto3
         yDQg==
X-Google-Smtp-Source: APXvYqzw8ShusbndySzoosJElpXX2Y+WlAECKmosIb2kCuPU1zdsy0LGNncMH17fmwy0VtCJ4X3n/w==
X-Received: by 2002:a65:6284:: with SMTP id f4mr64617613pgv.416.1564699104593;
        Thu, 01 Aug 2019 15:38:24 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id a3sm72677006pfc.70.2019.08.01.15.38.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:38:24 -0700 (PDT)
Subject: [PATCH v3 5/6] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:36:14 -0700
Message-ID: <20190801223614.22190.40937.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
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
 1 file changed, 13 insertions(+), 6 deletions(-)

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

