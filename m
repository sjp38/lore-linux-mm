Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FEBEC31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F54721473
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F54721473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DDDF8E0006; Sun, 16 Jun 2019 04:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 419E28E0001; Sun, 16 Jun 2019 04:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 309EF8E0006; Sun, 16 Jun 2019 04:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD0078E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:46 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id c6so2742842wrp.11
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hjjZi7hVawe1O5sE3agHwwCxgHKG18ng7v/8qT0V/18=;
        b=Sk5qT5OQ7s/NSNnyb1d9KqKvDCjfSm2GktRY/lsWjREE+VFcAk2PICxoE6fXmJF4TW
         4bW+J76PFpLNi9KI4wBOBgm33n80czOQT6BxBfgwa9el2+KRCjF+U11N322KbMxr0Nsw
         hRs8rH4/zptkBlCklWBZpridqTEzqatCeF/cmCcXtTJGjf6UZF1VgBfokr99TG/sz30r
         hwOyX2dUNdqb8TXSEQyycpd9Sh2V9WHPTdvKaKjiRGTn5bEKJeNUasUQKqwM2BCELxmG
         YJNExiul3OazN37D7DJk/BcqkobncLx0JG4W4KZIKcTlw46IgR8qD5nVmJ02qVdx5MTz
         8s7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9YWfyemQc0cr1zoibJesORYP3l+4Csrp9iQgQQVKxN7+U9DAy
	rWTm5kboCsXnHnVIrgeK8VjdpWDXfbgfHuPM9LSUsH5GDd2c4PHGTswxR2JWWmYwhVaoUsU6wbo
	1SsKmT2WRLVqgdA+3zdFUijs4x/HcJM2jJG5y6DAM/Zv1PQPp9XqMucqtC/hczCP5lg==
X-Received: by 2002:a5d:5607:: with SMTP id l7mr41766102wrv.228.1560675526279;
        Sun, 16 Jun 2019 01:58:46 -0700 (PDT)
X-Received: by 2002:a5d:5607:: with SMTP id l7mr41766049wrv.228.1560675525426;
        Sun, 16 Jun 2019 01:58:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675525; cv=none;
        d=google.com; s=arc-20160816;
        b=QGgji84SD9lYttE0JVCL0lw++1APtNjgArkslrp1g7cXHWB4Ildji7F/qgA9aZ+deu
         uzkFtUoFbM50/b2pKUSm4DL3yNSWzWt0AKlVUFIIcG+kjbhzfJs7Q8YeuPEVa6ve0p9U
         uhyTiG/5E7zy2UADX7Orhi5XtT6JS+lFGLPF9g2u35gHUOAKCN2WdSvad5iPsWiMAjJL
         ftEnZloa5L7/D96L04vWfWURnwEEVdTn6QtofIU0zVny67Qg5X77P6lRKK8s/6Ifj4ny
         GoLX6+9HcTix42aKT6BZ9y2itOOZvSE1CjUrFhTIigse90W00LmXs7tSU5d81NpiCzkz
         77Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hjjZi7hVawe1O5sE3agHwwCxgHKG18ng7v/8qT0V/18=;
        b=eU/ZOWVI8ZKvgMQbgfs/BF6PFt7+PLs2Bf7QI+aPQKaLoELsRG84f3xdXA+VfZ95jG
         HTYATxYnFbG0yuchdJoN4jI0ObQXkzZFmlZUl5ttdXZESZULYoYEXv4FggvNH4LsuP19
         s/BakEAek7pyHqDmktswOGopUUHm6KXZ9HXtSKCA1nTohXPigCa0J5JI//m3IJ66/RUT
         tTRiyu/IVW1dGB2jOdAYOq87YiquZTP0j7Jfid9QqInjOG9hErmTdklWgs5UeUBB1Rum
         6/jYq+ouCzGqXBPQu8Ca2+LXF1jkLeTbh9HepYr0h6R8trny9nlI+M/1Vpjh3Y6a3yyq
         dFYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor1776615wrs.31.2019.06.16.01.58.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwgBJiVgM4KiEAb/iF54vFPB8O+3Ztpe60o0gwS8ulqjH0TmG0LsqfT6UfUPJQvqxzCje57FA==
X-Received: by 2002:a5d:56c1:: with SMTP id m1mr56928115wrw.26.1560675525088;
        Sun, 16 Jun 2019 01:58:45 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id c4sm3173448wrb.68.2019.06.16.01.58.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:44 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 5/5] mm/madvise: allow KSM hints for remote API
Date: Sun, 16 Jun 2019 10:58:35 +0200
Message-Id: <20190616085835.953-6-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190616085835.953-1-oleksandr@redhat.com>
References: <20190616085835.953-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It all began with the fact that KSM works only on memory that is marked
by madvise(). And the only way to get around that is to either:

  * use LD_PRELOAD; or
  * patch the kernel with something like UKSM or PKSM.

(i skip ptrace can of worms here intentionally)

To overcome this restriction, lets employ a new remote madvise API. This
can be used by some small userspace helper daemon that will do auto-KSM
job for us.

I think of two major consumers of remote KSM hints:

  * hosts, that run containers, especially similar ones and especially in
    a trusted environment, sharing the same runtime like Node.js;

  * heavy applications, that can be run in multiple instances, not
    limited to opensource ones like Firefox, but also those that cannot be
    modified since they are binary-only and, maybe, statically linked.

Speaking of statistics, more numbers can be found in the very first
submission, that is related to this one [1]. For my current setup with
two Firefox instances I get 100 to 200 MiB saved for the second instance
depending on the amount of tabs.

1 FF instance with 15 tabs:

   $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
   410

2 FF instances, second one has 12 tabs (all the tabs are different):

   $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
   592

At the very moment I do not have specific numbers for containerised
workload, but those should be comparable in case the containers share
similar/same runtime.

[1] https://lore.kernel.org/patchwork/patch/1012142/

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/madvise.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index 84f899b1b6da..e8f9c49794a3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -991,6 +991,8 @@ process_madvise_behavior_valid(int behavior)
 	switch (behavior) {
 	case MADV_COLD:
 	case MADV_PAGEOUT:
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
 		return true;
 
 	default:
-- 
2.22.0

