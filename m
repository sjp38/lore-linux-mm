Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81710C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49E252075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:14:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49E252075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED2728E0007; Tue, 12 Feb 2019 10:14:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5B658E0001; Tue, 12 Feb 2019 10:14:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4AFD8E0007; Tue, 12 Feb 2019 10:14:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 852F68E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:14:08 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id k16-v6so929838lji.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:14:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2iA42bvrhkhrqeIgwCNrjkP4IG0UzUSmJ+TcZfgtzNU=;
        b=rRerAikcH8pFKAmRTNcjhbm88dOse84daA6K+KWeyJFGGXgYQdE0jf3t9CDiyJ+pcr
         orYOMol3p26mr4Z0IkzY/Hs/3IghPRNUbigss7se8HiGsT9r7QKOMvEWJbj6yfDnmiqQ
         PFUhANUz6O124g01WO9qdR3Uou6vO21UdojeTxSoGl8VS1ry/guFpBcqVdiWL/cCW3WP
         Hcd8fT7xdRUnxa2Op2GW+MJqjQ2tfJdU/08N+oZvBB0k9OkV9DA5DG5z1Shl7erTEFaC
         4Bm/32ikboZd62I5ybsTIuF0Er0M9ZzVtjRW34qaHwfZCOdtzAsa8zy85KppkJrrTtcl
         XwOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuY6s/qmd3XkTka99ItZAF8Z4O2X1ZmZttjqpFhekDo6L5PMQ9TA
	AXR2LfbQ2JCaiszO8EKmxcTSvHcKFy015klG7fTGfMbotOlyNouZJ0PQsNdKbXd6HYQDsgH+bMn
	LXp0+ZdouhAtjB9bcST47v3GcnBqECronOfhR2NX8taohH1AmgOW14Pr1Hqh8GrXL5Q==
X-Received: by 2002:a2e:c41:: with SMTP id o1-v6mr2638088ljd.152.1549984447872;
        Tue, 12 Feb 2019 07:14:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iachb2xnLq3QG4oZzKS/yleABfekIMTaX6aqU3pGvQISefMknGXPuwuE0R6gB0+TR7RPBp2
X-Received: by 2002:a2e:c41:: with SMTP id o1-v6mr2638041ljd.152.1549984446791;
        Tue, 12 Feb 2019 07:14:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984446; cv=none;
        d=google.com; s=arc-20160816;
        b=HpYWiynMaX0CjuPA+cEXZs6bnuDkqFHIdLTH2Xg4VhWrRQKxiaqPSiASjtIxNHMdFk
         XCflHd4qE+9k1NqjYuHs+HHB9M6SONppaJRRo/ojPRrp2u+Wx500k9KYXlGwrHwwbuEw
         7zAshqWkpYbst9OeTzExDRUPI9FD+Q+nAAXkKxN7bM5SKQhr8ko8d9bWUeyuC3NF+CxI
         c69MRHyF1hY+dxpW35fYoyBLZVoFvZsXeAwM7CKWYx/zW5E/o6vAFa6KoMRn3abR2aO0
         EBGchAiS3SPmBX/wNzo0ZjKb5YX3HE4X2G6vCdfuJZw9wsLd/0no/+oO/l1mHWMRCBO4
         GUrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=2iA42bvrhkhrqeIgwCNrjkP4IG0UzUSmJ+TcZfgtzNU=;
        b=GAH28fBmo81Ayr7BucaXMVRBaFO6hEiKIVFK3S4S0rEeeLWNObJY0SGYM4jbkx/wzr
         kJbHMP9dMEGcMFF+WipARhCRuD0CWLoiCMrtcS5IIjSI9xqTDM9w6DCws9r4aPmk8FD+
         ZzwTEccrtKtyW2uAarOb9RluyADipgEi1U0pOJz5g9T34vkCGh1H0zKQMawwOEweKbjR
         t6ZJTnezTF2t1NjW8YLutrR4O/8pkZXvT+idp3k+N6RjBj8ZYzAmU53DlClj+J142Qp4
         RyvC4WH/If6sjS/0ga9/envSemqgiFQRqXaCEYJaQvUg/wv90NGK58H1yc7SzIuYY7ZW
         ZZLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t25si3981104lfk.111.2019.02.12.07.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:14:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gtZl8-0001Yz-D6; Tue, 12 Feb 2019 18:14:06 +0300
Subject: [PATCH 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 12 Feb 2019 18:14:05 +0300
Message-ID: <154998444590.18704.9387109537711017589.stgit@localhost.localdomain>
In-Reply-To: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We know, which LRU is not active.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84542004a277..8d7d55e71511 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2040,12 +2040,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 		}
 	}
 
-	if (!is_active_lru(lru)) {
-		__count_vm_events(PGDEACTIVATE, nr_moved);
-		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
-				   nr_moved);
-	}
-
 	return nr_moved;
 }
 
@@ -2137,6 +2131,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+
+	__count_vm_events(PGDEACTIVATE, nr_deactivate);
+	__count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE, nr_deactivate);
+
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 

