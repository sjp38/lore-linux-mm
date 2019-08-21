Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B3B6C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:00:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D07920870
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:00:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k2a5K2EC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D07920870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13FFE6B02DF; Wed, 21 Aug 2019 11:00:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117406B02E0; Wed, 21 Aug 2019 11:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C336B02E1; Wed, 21 Aug 2019 11:00:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id D541B6B02DF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:00:40 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7FDCE180AD806
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:00:40 +0000 (UTC)
X-FDA: 75846746640.29.cry64_5d1968f794560
X-HE-Tag: cry64_5d1968f794560
X-Filterd-Recvd-Size: 4568
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:00:39 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id t14so1457917plr.11
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:00:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=k2a5K2ECmdb6swy6bHd/xAA0MDd7K9ym8QEcuo2Yh8MrxSUDRJfnZxqnDcQyv0BZeB
         WUSY/nSZQqI+F6Y/vkkK+HYEaKGvN6UXSdDpJESF2TUJx/ITqTLIqvlc80XeABcTTJZ5
         znjbFUnyuBjiqOSg/b3a1bnhG+vBZjuk9oOKuKENGYfrcjcnIQZInnQ7woSmsbs2qXb1
         OuXaFOUvpnHlRCm7vwjNeRwd0ycNjxnBwMDZ4igLcN6CZPKg44vCqE2Sf+PcHG3jgFQ0
         hrqzlA5atInMjmpkGw0fz7iDvXvYYVgPB7mnEj9E37BHfHaHAvoDAQSkB9iryiY88Xlj
         Eyyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=pHEy2bq7G8z2JiFPEi/bWskBsXR9BxTz8y/taMwY2UXdP3ZrhmV4yQmDxWHBp5wxE0
         Lkb7Pk1FLwIZ/yfk16p0eqiCKBSxIPecXzTKA2xkb/gvsvc0anao86T/vY8uJkpSvr3+
         x41xD9ezqbLc23QH91PmFYz1t5NawyXyWWW85cAoC3vOfxkpHUMCo1BhmrwU0CDh+9Vc
         H+tso7+zDKXW3o+rxUij7ISgrX3Fhk7qwJyMV/C+SOpGPYv+h87zOj3TQOVM6h7JoefY
         hlhP6rgI2krS16JHNZG9Sj/Ntrg912CDUHwXByr44DU8Ehb6EHm1No0j7/cmhEZxkeQ7
         qnYA==
X-Gm-Message-State: APjAAAXVqRB09c/TWA1JrC2qCmSPZtLWLcvjlcw1EZCFA1wxX0j2w3RL
	Q2GVVkIZ3Y2/h1aZ4e0ckG8=
X-Google-Smtp-Source: APXvYqzoQn+RfX4vjD+nR26xkBjnL4PsFBTP+0Ha9xmMLH5TQ58gGkHGrSHmBFrhAWplNCl7l58xYQ==
X-Received: by 2002:a17:902:343:: with SMTP id 61mr35450878pld.215.1566399638758;
        Wed, 21 Aug 2019 08:00:38 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id e13sm29412309pfl.130.2019.08.21.08.00.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 08:00:38 -0700 (PDT)
Subject: [PATCH v6 QEMU 2/3] virtio-balloon: Add bit to notify guest of
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
Date: Wed, 21 Aug 2019 08:00:37 -0700
Message-ID: <20190821150037.21485.3191.stgit@localhost.localdomain>
In-Reply-To: <20190821145806.20926.22448.stgit@localhost.localdomain>
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000093, version=1.2.4
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


