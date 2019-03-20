Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E47BDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4EDB2184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4EDB2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AC466B0003; Wed, 20 Mar 2019 07:19:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231E56B0006; Wed, 20 Mar 2019 07:19:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC126B0007; Wed, 20 Mar 2019 07:19:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 998B56B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:19:32 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v67so484430lje.15
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=y9/bU0VeAuaARw6IpyDYVFlnwwQb3Ao7Hj5MNFfZtQA=;
        b=Ze7z+KmqBBK9kVsLOPr9DJG1gum5lnl2GqUr2SRUL9ZbHJOrEfyHit7wAFhLSVxnai
         YYsxUtEKCg2do0FbCBVktBiNufJu3rxJgQuwWOwmwtPEb75Gv980nxKLxkBDLXJ5CpiM
         h90iH2pmrW6qeOCW3+DP6i/u1F1aQ+4Qa0RPsE5XuGcB1gssQJcPtysg5y7tP0q/w4bH
         /IsHk+GLvtvurfLJyqrElALtNkC2uecy2raQJyZv0/yUfnTm10YZv7ErlciwFwA9xOlC
         ZSI67R4J4ayhC1iN4a1h61qelW6+BI8Z9/BBCwBiB0zoVarkk0IhbGZSRmjTruNfHoth
         uGMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUUl6tDp3H/T05DznYUx841c8wshJ4d0LZ3WTpF1vC3ZQEQyrBj
	0AREg3G3hTzHvD+2S2hnL1b27gREYNJohwPND42SJZbzp1rIuzVk8IXHQHQztsZJ9Rf9Xnfwvr4
	15sI4HNGrN+iz5xTAah/R2lvhUqc373ZuBY/2s6RZ46s7ONg3IRWOaR0jF90zoCgfDg==
X-Received: by 2002:a19:7b11:: with SMTP id w17mr15645189lfc.161.1553080771783;
        Wed, 20 Mar 2019 04:19:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmKy79O4YBfl7J+/HtzeTG8O6XB8RmzQMQ7DDs3VU0iZ/IklWSVXHzNbTH8L3f0UeyDs7o
X-Received: by 2002:a19:7b11:: with SMTP id w17mr15645147lfc.161.1553080770699;
        Wed, 20 Mar 2019 04:19:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553080770; cv=none;
        d=google.com; s=arc-20160816;
        b=lZ+9v5sA+sNrNl2oNHawhD6zNlrE2/6ukL+mTWFYpSoZ3E/+bktRZokTD+TPqDj1Gp
         SiVDsGUy6ISmVB2A+MxDAlR4k/R1IiHd8p14ci2ek+0Y9trdnNuEfSMZFK8vOqoqZqzX
         PqJmhx+klpboAnaCiCQxlZaS8dSTkOqyg462lkjWS3GbUV25YwnqDmBdc9syVb+ah0k6
         DzCbu4NBPYgjYcj4zF5poUYQTUJu4vZ5Hpg1jQ3BF8L7WUEX+a0Z6UkLkS7nGLl+yHp1
         b8EMgVPiWs0LNwNLTYmjj8tC86aNCas0r6ryz2EDmhB1a6Nx8RATlc+agNef/joEFAjI
         lh8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject;
        bh=y9/bU0VeAuaARw6IpyDYVFlnwwQb3Ao7Hj5MNFfZtQA=;
        b=wUt1t5XG2JV/05BR8tQry8YQoAc6EqmQduwqsXC2Xg7MiZIYK+w60ZFmlf6PfubZTX
         4z811j+iBFK3GMBsDkWVxfjGre7jDBLIELl21FSS14PvJwXNBzm++qWYdLjnQKOreVTV
         UcWQbIggsQqx5rpx4iGt/cWJSpCu94SckoWE6kBYfaIfRUjplkwqm65yAFXOOIOM6a3P
         rRAlwGvJkmUmDuBlRyHF1Cn/qYaElEE/6+OtcN61l4CYwLA7jpzJ1aON1XJcubhRWXvT
         AD1DK/GQ7OC5lFmbupg7NOmSAVcmYIlf95/bFsLhL7D3S9ncBlD93A2Lg4P6cm0QEzXP
         iw5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v5si1188723ljh.90.2019.03.20.04.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 04:19:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h6ZFo-0007T1-GM; Wed, 20 Mar 2019 14:19:28 +0300
Subject: [PATCH] mm/list_lru: Simplify __list_lru_walk_one()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com,
 bigeasy@linutronix.de, adobriyan@gmail.com, linux-mm@kvack.org
Date: Wed, 20 Mar 2019 14:19:27 +0300
Message-ID: <155308075272.10600.3895589023886665456.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

1)Spinlock must be locked in any case, so assert_spin_locked()
  are moved above the switch;

2)Replace assert_spin_locked() with lockdep_assert_held(),
  since it is enabled in debug kernel only and it does
  not affect on runtime in other cases;

3)Reorder switch cases to make duplicate comment not needed.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/list_lru.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0730bf8ff39f..5f9fc84f1046 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -232,33 +232,26 @@ __list_lru_walk_one(struct list_lru_node *nlru, int memcg_idx,
 		--*nr_to_walk;
 
 		ret = isolate(item, l, &nlru->lock, cb_arg);
+		lockdep_assert_held(&nlru->lock);
 		switch (ret) {
 		case LRU_REMOVED_RETRY:
-			assert_spin_locked(&nlru->lock);
-			/* fall through */
 		case LRU_REMOVED:
 			isolated++;
 			nlru->nr_items--;
+			if (ret == LRU_REMOVED)
+				break;
+			/* fall through */
+		case LRU_RETRY:
 			/*
-			 * If the lru lock has been dropped, our list
-			 * traversal is now invalid and so we have to
-			 * restart from scratch.
+			 * The lru lock has been dropped, our list traversal is
+			 * now invalid and so we have to restart from scratch.
 			 */
-			if (ret == LRU_REMOVED_RETRY)
-				goto restart;
-			break;
+			goto restart;
 		case LRU_ROTATE:
 			list_move_tail(item, &l->list);
 			break;
 		case LRU_SKIP:
 			break;
-		case LRU_RETRY:
-			/*
-			 * The lru lock has been dropped, our list traversal is
-			 * now invalid and so we have to restart from scratch.
-			 */
-			assert_spin_locked(&nlru->lock);
-			goto restart;
 		default:
 			BUG();
 		}

