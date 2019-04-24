Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1712CC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C88A42084F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C88A42084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76B9A6B0006; Wed, 24 Apr 2019 07:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F4CA6B0007; Wed, 24 Apr 2019 07:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 597296B0008; Wed, 24 Apr 2019 07:12:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABC36B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:12:30 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id q3so2651467wmc.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:12:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g7i4uaKwh7TnZU3pyi6vSF6/UGnHMRj8eJfZ5arzTEI=;
        b=MSBI8a1c5WEhpTuNtIpAu2r/ZyMWa2p8agtVior7yY1KkHQlpzS7TUia52+fcWSmOT
         RjW++2xkKDVUOESUjgIACXLlkh2XJ+3pHzoN/Sv0t3W9RSCblYkkzKh3i3+664AG8O4V
         xzMtWPZAVOP8UceFB95TI/pCFZNaYcyu/gXIcVrERE3b8g1ZjGs4R6T8MpELlO9CGA5s
         ozi/6LUZMCP55KRy9rdmIadYvOMyIUeBVkttVtvJ4vXTz7pPp1lgtgk49VUcOBYQX90A
         QWr7eD8R5GsLZEMBE9yPAwr44WuniqcfleuhrDD7X0T7xS/DOSD2pVMOO+y3WKPWbzEU
         jguQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAWKU87ZGp23z27duCDYV9FM3SqcyTZOQnNQG1gCDNqURPvFUKqS
	Ldt8l9kAvPiNK/GnfFldDuNon09ybnF/ZRqJJ7bQ+y5Wg431fMa2dZftdniCcMNa5j/9wJtj2Ol
	diVw5uKMRWrn+UmkYNi5yuZca9OSHsoBQ4tFJbPrShBet3lfD/4GbmgKoGEQnB7qDQA==
X-Received: by 2002:a1c:2109:: with SMTP id h9mr6261485wmh.68.1556104349525;
        Wed, 24 Apr 2019 04:12:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz64p22WvWpH8sXCGiH1lplwOGvTtx9IG0B6E6vs/gPXeWFryeyx/0IyWTma1Dz1RBYg6Xw
X-Received: by 2002:a1c:2109:: with SMTP id h9mr6261421wmh.68.1556104348360;
        Wed, 24 Apr 2019 04:12:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556104348; cv=none;
        d=google.com; s=arc-20160816;
        b=MmZXtrtS4a6nXP7LOe89AESoaGy7Lmz8xCdzRwuPBX2ZKOImqjqiqpC9UvJ6uT4bdr
         3pSqkfJ2IxccR/qzw78rbvTycVNQdK7Wr5saLx9Z6AsP3KGD8Mya8u7Ws6uGMvNJtRH5
         DZO6QVNx5yELtS6+K0GBaa7L9hHyubILlJ4Znuvfr7R1NkAp5WvpgtnTnQ0KtiJ9LCvy
         OwCQVBwYwZkKHRAggGxwCY4qe8rKfu4N7aFeApM9BtD/lH3xmK9QpIP0CsBkWA9WGCUg
         RaBNlCud6xKZQ4xtCnVTcTJLZzHS0c+VCIKZXs3oUqkh8lsOSqcmFE9Ioq8DtKCuKkfA
         NbbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=g7i4uaKwh7TnZU3pyi6vSF6/UGnHMRj8eJfZ5arzTEI=;
        b=i46jBDoVakDJ1ZO+LfpIzsum3gZXayacX0RCKTus7XRwy1aXNOSwImVF6JZP9LtDyh
         oh3wKyKFZ1py8R9iI4mwmem4Z0oyealQgWXNQYzOx+xLba3FJerej8goZ2PHtdHep1Pv
         ff7O1GPTuqGXdP6MikKEUQGLfrrPbJvygmeJ0IdPGSFY2MtXW07FtkY8fMUucYHUncBA
         o3E/Y1gTHqNo+v98iv+Ai1bIqgFAlZd6xFTdUW7I+tf5Msb4oVbW1rmdk0U6PwdRm/oT
         GE5JRerNE+M2je8UDj92LnCKxHPDd2f9h0eJiS9PpPWMmG7+3f24nfRt17/p6ULG+o9o
         vq2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r12si3037758wrx.173.2019.04.24.04.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 04:12:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJFpC-0006KY-E8; Wed, 24 Apr 2019 13:12:26 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de,
	frederic@kernel.org,
	Christoph Lameter <cl@linux.com>,
	anna-maria@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/4] mm/page_alloc: Split drain_local_pages()
Date: Wed, 24 Apr 2019 13:12:05 +0200
Message-Id: <20190424111208.24459-2-bigeasy@linutronix.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190424111208.24459-1-bigeasy@linutronix.de>
References: <20190424111208.24459-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

Splitting the functionality of drain_local_pages() into a separate
function. This is a preparatory work for introducing the static key
dependend locking mechanism.

No functional change.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/gfp.h |  1 +
 mm/page_alloc.c     | 13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490df..fcad3a07c9b04 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -557,6 +557,7 @@ extern void page_frag_free(void *addr);
 void page_alloc_init(void);
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(struct zone *zone);
+void drain_cpu_pages(unsigned int cpu, struct zone *zone);
 void drain_local_pages(struct zone *zone);
 
 void page_alloc_init_late(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c6ce20aaf80bb..cf120e0700035 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2713,6 +2713,14 @@ static void drain_pages(unsigned int cpu)
 	}
 }
 
+void drain_cpu_pages(unsigned int cpu, struct zone *zone)
+{
+	if (zone)
+		drain_pages_zone(cpu, zone);
+	else
+		drain_pages(cpu);
+}
+
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
  *
@@ -2723,10 +2731,7 @@ void drain_local_pages(struct zone *zone)
 {
 	int cpu = smp_processor_id();
 
-	if (zone)
-		drain_pages_zone(cpu, zone);
-	else
-		drain_pages(cpu);
+	drain_cpu_pages(cpu, zone);
 }
 
 static void drain_local_pages_wq(struct work_struct *work)
-- 
2.20.1

