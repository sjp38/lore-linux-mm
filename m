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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4870FC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BB35207FC
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H3wKs22G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BB35207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE0B6B02EE; Wed, 18 Sep 2019 13:53:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A786B6B02F0; Wed, 18 Sep 2019 13:53:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 965BF6B02F1; Wed, 18 Sep 2019 13:53:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC306B02EE
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:53:54 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2E1B9180AD809
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:54 +0000 (UTC)
X-FDA: 75948789588.25.cord41_2208dd3653514
X-HE-Tag: cord41_2208dd3653514
X-Filterd-Recvd-Size: 4651
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:53 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id k25so302892oiw.13
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:53:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=H3wKs22GCSuuo47NHL84cjAcqIxVWe5raJSaPJYEEjR4SjLfOrFfKt6MqETcP09nzp
         mQwVOuGJiDyTUO34zz/FxTfyeK93Ym+rSqbDgLoT/Du3oNzP1D0AIlwxjhzYcrzwwKIs
         xtuGXJ2uADX6hCimeVVU5uKTm/0RBb5zaza/2xkqpEofa5+pRdcP/FX/pDjy6nqeQhrz
         wjIwWTS1OwEhcVqKPV+UX49i5jyRIkdBII/ejcvGqW6cFvW/aBaQMvKszzUiDF4oubCx
         FgrHvJ+7pmJW4fOmM+9tKSwU3cS7m7q8ml0xlT15/H7ej/2b2YhZqe7ipz773fsTquBb
         b4Uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=lms0iD44aJi9sZZsh2FmHsm906EZL7/82VV6ocEYBng1d1JZ9qDoBuZF9oTieuDZ+P
         nFo47V5Ibu+gdStDCULLMf7HB8an+YXi/oW+y8FO9zIM49khtPjv4+q/BHRRtZR1rOp6
         Xmnh743sjK+YKmq2+GIWe1MQmZPF5CCAlAm9jLr73ZNiBGR+oEOpJo0Bb9kf6YX5oSGB
         asEspk9/rT1CVi5XquU6w3jZFFFK1PpZoV8psuDMuTBAV9m6SR/OXACSUJIYYpY7UFKb
         vVyqxEEbV0AAe7JHfz5yZIxmj8U6YNmce2/Vdm9FetipK0PhBlMAVz2/3UOoVNINbWO4
         Nr3A==
X-Gm-Message-State: APjAAAXCwMmVB9OfMQgddUtBu8OuK5QpT0t9JFt5M6S14rONkfaPIHBD
	qEimfWRjiWenWgXGHy/W7y0=
X-Google-Smtp-Source: APXvYqx0/em4LyihxJp1UfPCVlfU74a3jjEiza4M/rCWhu2/BqxunUOAE7tRJ9fzvgWCTQRlNSJFbA==
X-Received: by 2002:aca:dcd5:: with SMTP id t204mr3293467oig.138.1568829232972;
        Wed, 18 Sep 2019 10:53:52 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id o184sm1837530oia.28.2019.09.18.10.53.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 10:53:52 -0700 (PDT)
Subject: [PATCH v10 QEMU 2/3] virtio-balloon: Add bit to notify guest of
 unused page reporting
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
Date: Wed, 18 Sep 2019 10:53:50 -0700
Message-ID: <20190918175350.23606.70808.stgit@localhost.localdomain>
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


