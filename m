Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E65C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A36921734
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A36921734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04EC36B0007; Mon, 18 Mar 2019 05:28:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEEB86B0008; Mon, 18 Mar 2019 05:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDFB46B000A; Mon, 18 Mar 2019 05:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 785FF6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:28:12 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 28so514311ljv.14
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:28:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ZQqLxxNSiNaN6i8+GsS7rp+8ipVxb8cl6tZ4lbzG+3o=;
        b=kDlK5vYSAQyOLojOvZCBW1Ieet6vLLHxCx1jniiiin/1LeASLwotrppUr8kMl9BpSu
         j7NFnf8m/S1JJGGVrO11xZRxU5tGYBJ+4N0DS1oE++brnxF2dX62e9XiKVsr/bB87/+7
         vEzODED4PsEl03tu5bvnLjZIVdW8viU6muNCgsiv4G5ekYRFzkGCHNoFRj7M6G0CPXxM
         rEdypzj+SQ+F+pY6qZI6YStGYMCRqTHEcatP3Ll1fPjsHIhARK2alBCJRKm1K0WzCPyH
         zzHOelkxwLh25x7m8m6sUZCV92XGrW9Ndc4j0Gv6z4w1SnTJbfgAeOs7fpD0QRuQLd7F
         sBLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWFi7z0wssQfuFksZvlw9NnrZ5D6XjwBv3ViuXLF8VvgZpe3/Eg
	2Tv81ArAs3Ju+eTGy8LpGS6KBCKlLoW97gSLv0BQJhPVkmWYleLuihuPaXBW7zONfsHB1uRwDyu
	c/JdkMwifMR3G9BmZThGmUJCWhO8XblREH2pyMgEVbFAJ48H7Ke1007aEMrEiZaf9uQ==
X-Received: by 2002:a19:968c:: with SMTP id y134mr1801174lfd.140.1552901291826;
        Mon, 18 Mar 2019 02:28:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOP83ImYmUSgX0a0JibEabExnl6C24czZwMQsl9okgEbJAiaI8VI+GpjsnT2xhEM7FEBla
X-Received: by 2002:a19:968c:: with SMTP id y134mr1801135lfd.140.1552901290894;
        Mon, 18 Mar 2019 02:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552901290; cv=none;
        d=google.com; s=arc-20160816;
        b=hUGBMt4JMg/wPOTHbFqTYqMwCjOE8O2O15wU13vrXQ19EGzl0j6ntNu9c363qTYXzk
         vpYt3gKTvfd3dptmSuTz8O0Xuv97W84j+0Vcgm1yCBl8Q9cnKCWrJWh8LKnG8S3qj0ud
         J+nXf9ZVKUfxAQs3Bp5PZG+PqshIDhGwAiQ84mAKXhxF8UGFGxLBmbrcfSXsMTfv1Zi4
         Rzg1tbXUUwsIiPeucqEwHyRXLYlTS1bxTttDPnNbT4MyCeShk8k8skyD9KPfIo9k08GK
         oR8VbL43UdF7mzkAnJY33TAgJ10f9hG5ogCi+Ng2wH43lXAt0MAmnUFSvRnMVTFsFw2n
         Mylw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=ZQqLxxNSiNaN6i8+GsS7rp+8ipVxb8cl6tZ4lbzG+3o=;
        b=U7pKx3fO1mbh5wPGdm+MrYzOAwQBmPPXGbF/j3jx7x4NKuzxkDiHjjmBztOpzTSHGW
         OYLKhcc06nmxqkBE/ePUIcwHZQH9sAkzpj4R1vIOFAHJHdfnO72ZRyygjeq5Sba+D6a4
         PHFQmn4W0SwdiB9yY3+oh4w7Qa8tD2cyFpDyKYiDxQPa/vqsTpnwR8SYKJLJIGjdRLJl
         Af2KFN5X/mVJXrQx5qEpELsDtldwf2LzgA/cNjoAmGI6vFBfvlGB6UVfA9hsNfL6R2m1
         C3jR/2FuZ1LcXQsOY101C8iOdrjS9M+PHxfOx/DxME+8fvMFRjNELSuCz3l63Mzjsco+
         V2MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d187si7467545lfg.54.2019.03.18.02.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 02:28:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h5oYv-00055C-LZ; Mon, 18 Mar 2019 12:28:05 +0300
Subject: [PATCH REBASED 2/4] mm: Move nr_deactivate accounting to
 shrink_active_list()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Mar 2019 12:28:05 +0300
Message-ID: <155290128498.31489.18250485448913338607.stgit@localhost.localdomain>
In-Reply-To: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
References: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We know which LRU is not active.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/vmscan.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e610737b36df..d2adabe4457d 100644
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
 

