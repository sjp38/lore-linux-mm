Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1585AC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D6A2148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D6A2148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E4716B0005; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1948A6B0006; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0851C6B0007; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7A146B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:05:33 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so11326280pfa.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:05:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=3saalRLe1lMsH1MPAaJR7Z0DjicgXTS9JXNa+kOkUUw=;
        b=jYItHEBaOhiV2apE8VmSZAZk56JpYcpGRqKAf4M1AOamij/44IDc5FBP2Bmw8zuop1
         27u60o07le5GeK7XsZys59oU6KYgWqj6qgTrOpJ7z9dIZ2HsR2TZ9RNrXRBZxJfFgAXB
         fRoEMZoXkcSxwKMC34rfBOGoRxNdObPIcg3lc2PVDNmG43dthcES53pFvBeh2bgy1bnT
         yR43F+XlSz5s8fnBcxZyfexmKtAyYq60iNDmqvZSc3Rol2kQeINIW+3QHQPeynnu6Qsz
         buWY/I7IXU3bWg/Fh4d/G+PXrKkRUQp3ahM55XlExvmM8E57kF2KT1vyCNWtV66LOmXM
         buCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWWw9SXGhCekBpuG66pUanPz1Og3BjSPYbUKOLhrlFAx66J+AvJ
	Q+sfLi3kSvhYNvUtvQ19Voozw24omDAY9Xa13O9YHMxIGtPkGLNeuez/YNbeNYDQRbl5JfP7Apv
	WvC6MsCK6DnD+Gf7UwtKXU2guFeadNO0TYRSPqxnmM0/oq0CEqzk6Jq8Fr0KbIgQC4A==
X-Received: by 2002:a63:fa54:: with SMTP id g20mr29240595pgk.242.1556089533383;
        Wed, 24 Apr 2019 00:05:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVVzssuMiLezV7vI8xouIrnIPqlFiOScEy+Ps3/jDKRpMjR9Q9dG+p4V5yj77IMJ97XSbW
X-Received: by 2002:a63:fa54:: with SMTP id g20mr29240504pgk.242.1556089532280;
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556089532; cv=none;
        d=google.com; s=arc-20160816;
        b=L1dIPrKDiEhs64o1egLsnNYrS+tWWIWPJmW+nBpc2bnniXhffk3+sONEa9DMkwA5tI
         HAd5YGkVitCDfjyJ5zXIdNg1SsIg1Q0oCmVk1hc67BLnUactkxkmfYIZHSS7CVBQmrSA
         O0Q1WA7bYSzE+dQNpqqNxfLht+WyEnvKNzToOz1LHG/btQ3HI8Djv5GsboKw9rFhkD+b
         9taDzmr00Vk1nBR6XgfFMT6SCE/Ny9ARHTbPz+HETvWzjKs4FfrqYYG6Fk/sOKER4r5b
         8K1Mtqg3VuJpXuj3l1QHC8HgeqAdbRPzwDhFypeh/NRrqGDrUUyXmBHMT1jWZTJtmJID
         MFBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=3saalRLe1lMsH1MPAaJR7Z0DjicgXTS9JXNa+kOkUUw=;
        b=W5Q4/MZ+mkuaHygHIwvuoK+lstvDWOz3ytdB7vVfHctK01PedvvIUoFzblAwKlBt8x
         WqrXCv0Yj4dyyub7D8Wj2G+wO9JdKqyL0SPAeYpqaFgM+2jH6/OIjFOwUkM+9mVvtXnU
         EbUDmoikhylOWGBnFGeaR1aDWanvE8/9WceVwo8yur7ClUoVfZtoOwaokU9NwTXz7EFH
         ZbLWIKx5aIgjnv0OhZfQm7Oy3oxrYSFdozKVWjnIKhP3UfLAUs+qYmulc1yybF7aw80T
         VTZSxMsKpCqgWTtziZ0Ks0vLxhiKG0OjwnDHKYu7840BXnDL/kjd/+FiuZLPvOSk5q0F
         MDCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id w11si17355788pge.187.2019.04.24.00.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 24 Apr 2019 00:05:28 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 83129B1BAC;
	Wed, 24 Apr 2019 03:05:31 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 0/4] vmw_balloon: compaction and shrinker support
Date: Tue, 23 Apr 2019 16:45:27 -0700
Message-ID: <20190423234531.29371-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VMware balloon enhancements: adding support for memory compaction,
memory shrinker (to prevent OOM) and splitting of refused pages to
prevent recurring inflations.

Patches 1-2: Support for compaction
Patch 3: Support for memory shrinker - disabled by default
Patch 4: Split refused pages to improve performance

v2->v3:
* Fixing wrong argument type (int->size_t) [Michael]
* Fixing a comment (it) [Michael]
* Reinstating the BUG_ON() when page is locked [Michael] 

v1->v2:
* Return number of pages in list enqueue/dequeue interfaces [Michael]
* Removed first two patches which were already merged

Nadav Amit (4):
  mm/balloon_compaction: list interfaces
  vmw_balloon: compaction support
  vmw_balloon: add memory shrinker
  vmw_balloon: split refused pages

 drivers/misc/Kconfig               |   1 +
 drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 144 ++++++---
 4 files changed, 553 insertions(+), 85 deletions(-)

-- 
2.19.1

