Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87B72C76191
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 18:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E64C520693
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 18:09:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E64C520693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wanadoo.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8524B8E0001; Sun, 21 Jul 2019 14:09:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8040B6B0008; Sun, 21 Jul 2019 14:09:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F1338E0001; Sun, 21 Jul 2019 14:09:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 393F66B0007
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 14:09:39 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j10so15071192wre.18
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:09:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=GKbTgfRGOpzaV9teCKK78LWHOS+8CYZdP9AOSLw9kPw=;
        b=rR6ICJqdlqrKo43Cffa+3eQyPvs4FyVATOCD5pvpLh/u1ynbMOSWD0uGd4jl7MO+Kx
         5UyY6EDrG9YRtK1rsZL2zYTsnLI4KoMHODHFOBPavzaJ1pirxDeVXo2fNjdzlTetuOsB
         7uYMLFLpqaac0hx0QE1QiQ9tnopk1DxfqeH1At8988D3svvORQimNLClGLF+VqYv9jXI
         hkDv7cmM6k4kZShWNHKrkzwJWbr12q/p0Ytl+BF1ckxUUp39hZqPgUHTSfGzMxFq8NoE
         S+9zFpzTYsr4q7QVAnwHDM9CdpRD6n+xRBDHq+PhVzOxpz8m8dall0QaEZnld1JLmspD
         4mUw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
X-Gm-Message-State: APjAAAUrXQOuxO9cSP+59gCOJsmVRXRdpZceobaedlLpxESisk/MMDTg
	912XS4u6+XHgI40bK9VGSEtGjp8LCIBkyR7PZHdV2lZXaxD1o7rP3F54QSShu4yP7NOmKrrIkAJ
	M5nDZO3JejjGuMTFFUC4LgBO5gfLlcjqUG6DGzQATV+FqBHXk4yv4wYdD2O0a5As=
X-Received: by 2002:a05:600c:23cd:: with SMTP id p13mr55049289wmb.86.1563732578697;
        Sun, 21 Jul 2019 11:09:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5etKwdnUGE60OCTTkzqK55rEff6msidCLHpMa4a2U9LqjS65e6qtj+z5rWkrs874CJNP2
X-Received: by 2002:a05:600c:23cd:: with SMTP id p13mr55049270wmb.86.1563732577938;
        Sun, 21 Jul 2019 11:09:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563732577; cv=none;
        d=google.com; s=arc-20160816;
        b=CHTqbJMBS1BDLPxaSX8C4XNTceRhrvqyCp2Aosc6jjlDoQG3QWregc9AwXa4mOArqV
         zZBgKL17dCmRuRHJzO8l99CpanfB8LaKzHJQ6X3NjKyUP2fD+1y3v0ld/F9bFKqt4SBY
         NxHnBwvOQc23BAGi95kgK4FUlPip8kLYRQVB7H/Mk7hA4GJJwiYgy5cGH9HjwJcEm2ry
         OkE7fvhUth0CoNxav0ItxhtrhxgotIEqxSKu+PbKXKitf5+F14Vylr3xELZ9VecQTi5F
         YW36eBH1gZihKblS3n1lKpTab4jgT6lQMg58ytDGzc5gGCVCmmRzKekKIfV/fOSaXjwB
         RMCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=GKbTgfRGOpzaV9teCKK78LWHOS+8CYZdP9AOSLw9kPw=;
        b=tctOlcCseXSNm4S+TXP1nLQsouIu5tLB+6CIHNRCXLcqnvYpwc27pT6MQOu28CNPJD
         FTNE67d8I3o0N/9AEcZkPF1cScT49VG2m3NGnDJmrY1DKltA2C4esX3h1P/gPUNqOZuA
         1jEAwoFJCW7VOxf8A0qeGX5OvRMsk1ksd51+sNNYCJwx7NLb5kVLRRqPpgqo+YecEZPX
         xkCG4hKK9qtKESmnXEAgC4mLrCcUu6RyRfURPemmD/EtpOQhjBOGs0/GL6dk2CKrkkSo
         LflXAN5QjBo0G/npH8iV/tN0RCaGAwCq/PnU7yfqON+W6phM3CgMh2ew7y7qRmiUdZxN
         c+NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
Received: from smtp.smtpout.orange.fr (smtp10.smtpout.orange.fr. [80.12.242.132])
        by mx.google.com with ESMTPS id g9si38176001wrp.347.2019.07.21.11.09.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 11:09:37 -0700 (PDT)
Received-SPF: neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) client-ip=80.12.242.132;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 80.12.242.132 is neither permitted nor denied by best guess record for domain of christophe.jaillet@wanadoo.fr) smtp.mailfrom=christophe.jaillet@wanadoo.fr
Received: from localhost.localdomain ([92.140.204.221])
	by mwinf5d45 with ME
	id fW9Y2000C4n7eLC03W9YaP; Sun, 21 Jul 2019 20:09:37 +0200
X-ME-Helo: localhost.localdomain
X-ME-Auth: Y2hyaXN0b3BoZS5qYWlsbGV0QHdhbmFkb28uZnI=
X-ME-Date: Sun, 21 Jul 2019 20:09:37 +0200
X-ME-IP: 92.140.204.221
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.vnet.ibm.com,
	aryabinin@virtuozzo.com,
	wei.w.wang@intel.com,
	cai@lca.pw
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mm/page_poison: fix a typo in a comment
Date: Sun, 21 Jul 2019 20:09:08 +0200
Message-Id: <20190721180908.6534-1-christophe.jaillet@wanadoo.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

s/posioned/poisoned/

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 mm/page_poison.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_poison.c b/mm/page_poison.c
index 21d4f97cb49b..34b9181ee5d1 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -101,7 +101,7 @@ static void unpoison_page(struct page *page)
 	/*
 	 * Page poisoning when enabled poisons each and every page
 	 * that is freed to buddy. Thus no extra check is done to
-	 * see if a page was posioned.
+	 * see if a page was poisoned.
 	 */
 	check_poison_mem(addr, PAGE_SIZE);
 	kunmap_atomic(addr);
-- 
2.20.1

