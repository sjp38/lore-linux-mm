Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EE39C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:46:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47D3C21849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:46:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47D3C21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A41B06B0006; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F8966B0007; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B70C8E0001; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 523D46B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so22588856edu.19
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=2aJECj3eYGevQmg0uKx5hyTjnYdcvQINQrWdu7rO77g=;
        b=VjYxbgaZikLh3qFEg8o6Cwjwx/YwicnEfRYNWNFGUGT3oszesKwTBsfGUlNPG6J3S8
         RUPrEXX9j5+QJE3FuTJJQs3AnZ6JAmupgWH/r1R/BcD7pDTkUasn01FeOd5AAfTZh+9f
         ZWnBQGphd6O2NMrDWbKzD8EmfgjTVVKmAXQT2IMxNeq9Veiksph8zNurkmkIYQd8vpXr
         LhxpZkG4VT+Gp9h5fO8akrdrLUQ6O+bnEJZT7FQvyIW4BMXAl6vEbAJiA6cA3ywQk2wq
         9MCpna7KxBV3PjIXCNDEp8MEUDKOCNYV/iGXQK0qHlsPDZy4Kw4PqA2Cd13JYxDKyYaG
         BZug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAVjRvmSlpxb/kq+VcylNyWj8NfZGS2c8UpvsnIuSBj8hZ8socHM
	sWjbVuGuDKFEAQr/uVR7/HEeAkr8ik1SfCyh5yZ6ZeiuciM0sWAiKdO5djW8kd3fZMPgJMYEG+U
	FkVNO9e/udbBypSwKA9ochC2vqo/YJM8XHz/AryhWDwnKRqNu9XJ6kp9LDcyyvakmCg==
X-Received: by 2002:aa7:c999:: with SMTP id c25mr47613566edt.134.1563562016814;
        Fri, 19 Jul 2019 11:46:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7xqxx1bSF4IMUjq2dkaqWvfGDZbW9hCIypQvr8bQ2e7FyhS/bIXJ2Chm9kvFWbatXBG/5
X-Received: by 2002:aa7:c999:: with SMTP id c25mr47613492edt.134.1563562015789;
        Fri, 19 Jul 2019 11:46:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563562015; cv=none;
        d=google.com; s=arc-20160816;
        b=013AlNApxuDUdaAHLO8jk7Fousiq4fAums0TuvWOePol6BbNf7H7Dmj9XEpk8GzobE
         6c6xh06Ox2RcHv6eh2RX0nfOiPmiyD0UFhOjYHwFE1v7p7s7VXDavylhCNI3QDDECXdv
         s3O+P9Ey4f7eTyZFVRkD5IRfWj5gOCo94rE+7pY6OMxdKFKKlGBWPeyrkYS/NBzmUukm
         p6EuRurZi5PzSxfhN+dUVi0264rtio1io6eqlKxfCygml08vuzvI4R0Y6TJKenObFRP8
         GLM1p4j2ZnorRlzb24X/uj3Fg/FRCjA1ZD+nldQN4CGcHKWKOx8Rve/NTqQ4UXXHjMVN
         UpJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=2aJECj3eYGevQmg0uKx5hyTjnYdcvQINQrWdu7rO77g=;
        b=ExWWc6KRqs2+OM5+C4A5RMk87D4azD14X15W4cX0YuioWmjIw6y/jHDiwPE+Jk19U3
         Ijw5ZlHjGbFItupwUCq0s12eM2BjYpB7NN6MDAkCNtNdskyrXSUHZCCNUQaa3S6lV2lb
         jfq5JLS+8CigV6YV3+4BRiFc4sFgkPQuvX2yv1ydl9GohScV//+XOJHjsNExeC++6uKt
         xcAzYmqxCSsn3ZrbVufl1O57e4jYm50RdrXn4zW9oH1rqF85mhYTbvdoMnIFwoBEkzrW
         GpFxvTC5MGGAGTf6RqkYiKgJkBgyRm9lgtASIwehWpmkFbM4FQBFxPGS7jG6e652Ifv7
         piTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id s50si91564edb.270.2019.07.19.11.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 19 Jul 2019 11:46:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 7592122E; Fri, 19 Jul 2019 20:46:54 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3 v3] Sync unmappings in vmalloc/ioremap areas
Date: Fri, 19 Jul 2019 20:46:49 +0200
Message-Id: <20190719184652.11391-1-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is a small patch-set to sync unmappings in the
vmalloc/ioremap areas between page-tables in the system.

This is only needed x86-32 with !SHARED_KERNEL_PMD, which is
the case on a PAE kernel with PTI enabled.

On affected systems the missing sync causes old mappings to
persist in some page-tables, causing data corruption and
other undefined behavior.

Please review.

Thanks,

	Joerg

Changes v2 -> v3:

	- Moved the vmalloc_sync_all() call to the lazy vmap
	  purge function as requested by Andy Lutomirski

	- Made sure that the code in vmalloc_sync_all()
	  really iterates over all pgds (pointed out by
	  Thomas Gleixner)

	- Added a couple of comments

Changes v1 -> v2:
 
	- Added correct Fixes-tags to all patches

Joerg Roedel (3):
  x86/mm: Check for pfn instead of page in vmalloc_sync_one()
  x86/mm: Sync also unmappings in vmalloc_sync_all()
  mm/vmalloc: Sync unmappings in vunmap_page_range()

 arch/x86/mm/fault.c | 15 ++++++---------
 mm/vmalloc.c        |  9 +++++++++
 2 files changed, 15 insertions(+), 9 deletions(-)

-- 
2.17.1

