Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8850C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC4D52077B
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:11:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g/vi+t15"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC4D52077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C5D96B000C; Wed,  4 Sep 2019 11:11:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5760A6B000D; Wed,  4 Sep 2019 11:11:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48BA56B026A; Wed,  4 Sep 2019 11:11:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id 263C96B000C
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:11:53 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AFC6F180AD804
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:11:52 +0000 (UTC)
X-FDA: 75897578064.26.lake21_84bda43b22e43
X-HE-Tag: lake21_84bda43b22e43
X-Filterd-Recvd-Size: 4567
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:11:52 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id d3so9733316plr.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 08:11:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=g/vi+t15qU05IbfH7f9reEH9yxdol9aOOQ4XHr0/aA7/TFCQM1b5/WOo9ApO+j4UO8
         6zHTfLJrCRgc/PRbLuwmwt7AgO8Li2zVeayIjrPHGLVtuvmfLy05Ebxskv/jEsFKXreT
         PU1YxQJFu1KtTW4aXpFBLy2Wp/SlTrcpGKFwkcSPe/yVdbP54eXYeeB/yNM1sO1CF0Ft
         X3i42sxpn6OhzdN5Oi17iH+Pxv2Yyzw228YDIeRYnaggU+hm0GIV4Od0cj3QoN0ozyM5
         7Ne4cZIs5v8tbBvJd6IdKBXcTKOqHiDarRP+9/o6pofrBQholFrcv7aIxP7g5tq4bdag
         JR1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=VitjQQFQG7H0A5JYqbYhHy/YWDiYO6QESupJyX3H62U=;
        b=fWRVPN60eQ+8FxQjdqUg9QCboXLn6c6gXBd4SuIUiWR22E+4aEj9hF/BM5LrOrdQ76
         xrz2W7dmmpRI2J0IgrBsL+HG3MQcQydWcRmnUR+ia1iNWwRllq7nDEC+2yVvG50LlRAp
         UqgdspW5CxFnhr9xbZdAwx9fULe+kUpQPCGHseInxV1e4iBTuNvmYzfMiAt2KefWrr0A
         fKOsad6M9bnrKhNFxRvDw99ofjRMtgH1oEVrZZ0iPRLkVH4sUmVtWhZiTHfNhXXARHF3
         SYFa2f9kZYq38wCViYDjrVGzVXF+o63QWWxAfdwLhORjD79OotGASx+HZHHfCX6ESoEP
         mlkA==
X-Gm-Message-State: APjAAAXLJKwigQpQXkU1q5MQU3E7Tcsp7wuTaspTLhyQIdwtoiW6ujUv
	XBaeFxnAwwdFMGgX3zpaH0s=
X-Google-Smtp-Source: APXvYqxMHRJHJTYla/YgyQdu59bO6u5k5GGEbaAYb15QMGK3Ubb3XU1FJ5AaU/7ayJ0tPcue3siLXA==
X-Received: by 2002:a17:902:7085:: with SMTP id z5mr41400977plk.102.1567609911224;
        Wed, 04 Sep 2019 08:11:51 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 69sm25681682pfb.145.2019.09.04.08.11.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 08:11:50 -0700 (PDT)
Subject: [PATCH v7 QEMU 2/3] virtio-balloon: Add bit to notify guest of
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
Date: Wed, 04 Sep 2019 08:11:50 -0700
Message-ID: <20190904151150.14270.41018.stgit@localhost.localdomain>
In-Reply-To: <20190904150920.13848.32271.stgit@localhost.localdomain>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
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


