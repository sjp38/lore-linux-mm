Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B47BCC31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F79D21473
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F79D21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32ED98E0004; Sun, 16 Jun 2019 04:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E39C8E0001; Sun, 16 Jun 2019 04:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10C548E0004; Sun, 16 Jun 2019 04:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA7C78E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4so3218550wrt.13
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2sgxUU390W2PtuQ88MMXWGwjdnv5ZXrQD67uDLz3qgg=;
        b=mytxanDarCPzxtLre3bVFL9aRplBOMCtrhG8xhJb1CDqb/AfI/7xtx8sCgYbodIZtS
         aUKUxhL0vWRw1rG9LnTucE1PeE0y+hC2iBjDNR9mqu9nP/6Y+dsur3OIsRR0IVEMoiHJ
         2mu+SqhdnjZhPBBs3Opw0QncE1orXowEe9+iblFryIThAHhUaoPsRdHiPs1v+3ix38R5
         PAQoudKu1HpxBvqxYMqwhQcEFbZqzYfIf8WQlvv76OVvALqBp28fr0r4papNT5OY2++7
         Cy2EDUzgrjupVNbF/9Qh75vdOt6Pv4mmwc4ydbw1lazQLAG2y8WmVuAkUEufNP2c5gq+
         yUQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUl+9RMzElJfThrA30iIjX4RAkvXc9XltEFplVkCM1Ap7KjSP0B
	wcxQko0hj+AEbhal5XaxV9fi3dEgIZmmNaWXJNhWoC7JGzVn11NL0tqWybvRA2Y1kMap7GQBy2S
	e5vUOXw5RPHmH8g/jmq2Gkd3jhSI/obUlTyPAS14IEZGucpGqWZSHgz7lnDODSJGY5A==
X-Received: by 2002:adf:ce82:: with SMTP id r2mr9934089wrn.223.1560675523327;
        Sun, 16 Jun 2019 01:58:43 -0700 (PDT)
X-Received: by 2002:adf:ce82:: with SMTP id r2mr9934031wrn.223.1560675522521;
        Sun, 16 Jun 2019 01:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675522; cv=none;
        d=google.com; s=arc-20160816;
        b=j8W0QJs66Q7CRm/RE+2/kNUW1Dp3DiIZSY+t6g4p/jgjjFbhd/8IVv3evC+hrWlZ/h
         fDy2wZeFk7IPSA/HV7ljGktC3Om30F+FI64vntOCjEcBMJSD7ceokS66AkzVB2CQ3q3q
         BaHAkIqJW9mSDgQWzCiKcyl55esalA0SHKc05XSyTJYb8BA8T4r459uotxk9t0WitM8l
         vWRvxsvpHntA+EVqOED9tu04NTbrjEm+DTDmSaCNFvJTNHce1qQgDFKBor2R11LOXlOL
         yAZGR+8Y+z6cUeRQbvxFi6D2wtzD571I/VcMNqwK2G+GOVr4seX7jFDatrMQVyc4nOcB
         7PDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2sgxUU390W2PtuQ88MMXWGwjdnv5ZXrQD67uDLz3qgg=;
        b=guNHBzXlhFJv34knZnI2Qh9BlDZjhwMtOO48SJgXjYKfBjwo6sCZCIM2PIh4Iv02jt
         a2SuzItUOhHi6SWpuVuZrIfKAH69r2tfSYSD3/xnqLX3sr3D06ei7E0vWOxiFSQUlSM9
         6P5HIhOzgKzZALrSuflDo+yzg8fQeVBysZ1cht0LK3waU+ylmVeaHcAGuHSAR7DYaH4L
         k/RCt84yd1c2PAsTupc6/lriifH1Faji5Dhh7HcT85S1F4IE2Cukau/8G2Clz1qfR2tf
         rN0rG81apAVPFk6V2kISPPwYh8DYcAl0rbh0WYRcoxw/DmwreK7vTEZACAE9f4BWUVV/
         W9BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor3174605wrm.51.2019.06.16.01.58.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwX2256HeSx7fk/qLqgGOiy/mrmlvd+nYfLi1zyyw8W3Dtaz40qJJqmoIRaEQdsdMHYjWP9JQ==
X-Received: by 2002:adf:f610:: with SMTP id t16mr9367740wrp.3.1560675522190;
        Sun, 16 Jun 2019 01:58:42 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id h90sm18578838wrh.15.2019.06.16.01.58.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:41 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 3/5] mm: include uio.h to madvise.c
Date: Sun, 16 Jun 2019 10:58:33 +0200
Message-Id: <20190616085835.953-4-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190616085835.953-1-oleksandr@redhat.com>
References: <20190616085835.953-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I couldn't compile it w/o this header.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/madvise.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index 70aeb54f3e1c..9755340da157 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -25,6 +25,7 @@
 #include <linux/swapops.h>
 #include <linux/shmem_fs.h>
 #include <linux/mmu_notifier.h>
+#include <linux/uio.h>
 
 #include <asm/tlb.h>
 
-- 
2.22.0

