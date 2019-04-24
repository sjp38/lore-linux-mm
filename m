Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D83C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:13:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C85F7206A3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:13:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ey1dd/Ky"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C85F7206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 338EE6B0006; Wed, 24 Apr 2019 04:13:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E8116B0007; Wed, 24 Apr 2019 04:13:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D82E6B0008; Wed, 24 Apr 2019 04:13:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB0C36B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:13:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a17so2289366pff.6
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=mFapfBjCjXPunlcrrLE7EkS+sVeYLXcPTMxaRyakd0E=;
        b=ZpK2Wn+oFvLp6KbjBqec5ClpxfVnygEg7mxqgr9ksSWtYUeOEJJwA98Nog7gj90Cbg
         Jv13Y6Lqb8TVIoL2cbh5VathzrQPO6p5BMBm/vWFVmdPejBQxGaJbTktVF4IxHcJRGHi
         L/ul0iausIxk23HTW7cTzfebmHSdukMr203lKe8ncjxfKX1kzH31H7iQzhUoBbocnu+b
         k/dudWFcsXQmX2SveFI0W5hfTrrZEH0NutVg1gLQ4wJ0LuNhjkwgcN9eDqZm/OTfS2nE
         KNp/971Ecc/mNtNYUOUPe5LLLR8FS4Y8ygICG1jf5UR1+Kam3l/WLAkV9tYW6lRN6ZAC
         Sg/A==
X-Gm-Message-State: APjAAAUYGvxniMST9wVhj8Z6br5s4Q/uwhEpUH9oPHuv+Iz/MZbc3Fbc
	qKWWTaN043IH4l/JJVGfu8nsSBdsLq6g6mp6OTjPFz7SKnlHj7YJZULiAHKXX6xLp4kWfeArGc8
	yyScQyM27EoGs9ZrbFDbN3g6qD7EkQAlflLtoO7KhEl3elAZ7Ca2tuQhOJfUOT2duuQ==
X-Received: by 2002:a65:448b:: with SMTP id l11mr29180123pgq.185.1556093592481;
        Wed, 24 Apr 2019 01:13:12 -0700 (PDT)
X-Received: by 2002:a65:448b:: with SMTP id l11mr29180068pgq.185.1556093591623;
        Wed, 24 Apr 2019 01:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556093591; cv=none;
        d=google.com; s=arc-20160816;
        b=Yf5snERdwK13w7+4vJy9lqIV/8/ALNNsJWesoCKw6suux+Veyfi8HzcnM6V5c6pHXX
         rfIKawgqiwxktB4EldnhLOMTQJQrdVWkVjUHoV/zw/wcwdeNt9KINhDdcTKwBHkvRtu/
         LJEhaSW5UG5lvrQ+lARjezWs5TPRWdjmp9DDtPzAIayWuybLBxdujDPa5t/GCLhv6OlK
         OFMbxVA3ofKZErYLfBnpQ7UMBSGq9kyWJrzV1ImeaoFEbjKN6FuJbrtoyAyvVdfV/8S8
         kft4GqFR2rMgg1RX+XxDx8hnuDnB27m4sBArC+auUni7sOYfX59tSrO6K4LJyoXEaquk
         dbKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=mFapfBjCjXPunlcrrLE7EkS+sVeYLXcPTMxaRyakd0E=;
        b=Qam0MuLtjGE/p2N6GDVZBOXZsoyV5YS0RizZapwQf/g3XlrxLMhX/bXYZmO9XJsyur
         0W9iokOOALb5sZfb2zIex4uvdaOCbAwARrsW5hcUimfBd1HZ2PHydhFiILd3A3SlNuNT
         ys3h0NylMseZ+dt9sYWEJG2A/0wh/ZB/UW8phwIdC98E4swxB5kUhuHdevZQgIhdQbSG
         /hdc7quzu93iVAVWx/F4BEm8MT7oSPZXM0WhKeCXP7qftsz6yhHoDe2jle8SnP44zjAA
         SwCVsVbCIj4ETvu5V6YZCm1Hm9EaIsbqXVioCrM1gX7hbfDBVoLI4zZ9ilaSkurX2EAM
         vI7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ey1dd/Ky";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d15sor9341633pgm.30.2019.04.24.01.13.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 01:13:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ey1dd/Ky";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=mFapfBjCjXPunlcrrLE7EkS+sVeYLXcPTMxaRyakd0E=;
        b=ey1dd/KydeXWY3ifE7YuvgYbTnQOO1FvXxbOt34ma7RacsRd8uoCh2Up45Bh4w/6ob
         g6CxuLQQ3xvZ09osI0UM/tUwIEqWLusZ22aAVbWIq9PIustCu/zU9jTJvCaj4K7Kg+mj
         XaZ0j5DukYi63ivI9T8tG4w8vbdZ0HZv7frn1+UTmjYEspa+nwZJERmVSAWoNC+swziR
         FGttS65uvGDtXFa+3znikhT5ZBDu2d8raTZXn7R7T8npTD7RjNzUmgwwdIaxHl+QwGMy
         MOBLRdJzvRZQGmm2Fipw1L7qmvvK404h9XXBunT39zTdqYvuDwsAhVCdWccR27t027/R
         o5rA==
X-Google-Smtp-Source: APXvYqwCXytzqkfoa9ClhueHKRjpsDeM8TuegScZIHJPxMMlzOXVkduFKLyYPKOIc0rSaDEFdbo6qQ==
X-Received: by 2002:a63:1654:: with SMTP id 20mr29985401pgw.166.1556093591208;
        Wed, 24 Apr 2019 01:13:11 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id 90sm2354926pfr.55.2019.04.24.01.13.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 01:13:10 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: don't disable irq again when count pgrefill for memcg
Date: Wed, 24 Apr 2019 16:11:34 +0800
Message-Id: <1556093494-30798-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can use __count_memcg_events directly because this callsite is alreay
protected by spin_lock_irq.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347c9b3..18d48e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2035,7 +2035,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_vm_events(PGREFILL, nr_scanned);
-	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
+	__count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
 
 	spin_unlock_irq(&pgdat->lru_lock);
 
-- 
1.8.3.1

