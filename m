Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14016C5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBD02208C4
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ffjKb1Hr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBD02208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1546B0007; Sun, 30 Jun 2019 03:57:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A1758E0003; Sun, 30 Jun 2019 03:57:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 691FC8E0002; Sun, 30 Jun 2019 03:57:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f208.google.com (mail-pg1-f208.google.com [209.85.215.208])
	by kanga.kvack.org (Postfix) with ESMTP id 329A16B0007
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 03:57:46 -0400 (EDT)
Received: by mail-pg1-f208.google.com with SMTP id w5so1227490pgs.5
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:57:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B8cz0p1U2cEXshPnnN86RK5M/poNnk6a+Vr9fHBKncc=;
        b=kjCbVGjdG69Yfcia21gM58ondGjH3dqwlEYY3BWbneiT0lZ9i893I0mPeOc8EyZ6sa
         r2WdDfQXLBq1xphHQqqIbQfG1mG6yIoDyvmq5lcO2coOTrWAqr3j0yvOAhh1M6vW4KLg
         923N/7QIi278jiptxmrRtinHNdVyqHTykaFCrecL841Yh5so/qBd8ZNb2bi3hJzc9Voi
         lbi5LcNkf1hjlDGvVjlB2qB79+EZ1z4YpU7MEFnHo1D75gr//KKbLWDk7WYvEqG/IE6b
         7yrSnPlfaN71txKJoEoVkdr65/ipiaH5Xh8+/nBjcgAUPQfbmlOFMgANEO5+5hzV6kie
         bKWg==
X-Gm-Message-State: APjAAAVbxTtvW4qTkMwKrxSocH20Ubr+uo3BjMzZ9XNqAqtshBtt4edf
	vvAjf5+3zqFsh1ly1mBpa9hscRsTAcHi2prTeCV8nNR6pRu2ONW/k49tKTlN54ezkuovp/k5kKq
	QHHSnVbOl1Bij8uBrgwQ0VPuJ7+/D+8bMiDx4gwsiOKLZibhwAZOMCzUrW/+4GTdfbA==
X-Received: by 2002:a63:610e:: with SMTP id v14mr18083742pgb.221.1561881465714;
        Sun, 30 Jun 2019 00:57:45 -0700 (PDT)
X-Received: by 2002:a63:610e:: with SMTP id v14mr18083708pgb.221.1561881464882;
        Sun, 30 Jun 2019 00:57:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561881464; cv=none;
        d=google.com; s=arc-20160816;
        b=Tw0NsbSqRKJyXOwW/V8OdPStSHHX4bW+CPM5/x2pj54BoIbNVq7DWGeCqPl1f4O06f
         k/mwXo5Ei47m+BZ2rqwD06FPp1exOs6qQMCJt0lcLvlyPNF5PvQ1foZQ6eLNXAm6KkwC
         tg1UPZPetFtAwR9I/VQIvfAPKI9s7RemBWIifgghHI4qaXdD7Llk1vNlnjMGh+BksIal
         SZxjOmhZOZ+/Ybg5OHiMNqg9WQs8pwlaD5GnZSkF+2AVgNLdjsCN26m0yjvItncyaqOh
         YdifytLK6vxuWgb//DviP1il5Y23ZcIvsv5PPG31QHZDjinFDh1W2kCmlR2sOC2NRBl7
         w/Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=B8cz0p1U2cEXshPnnN86RK5M/poNnk6a+Vr9fHBKncc=;
        b=SkXgmrQyRLbH7jKCC5fO4ycaaPu8m3p7ol9I4jCr0kAoTTC1v7YkMLV/zX9/RgMm9/
         k3DSn526crRJTZ6v0aTaJFcifPD6bbAb9gZwQuhxSPLviTV7whRdRcdx9myZM/pkLRj4
         pnQVO4GdYVzlrgZUGoFFgw4DCklCFzWeUcMBFt2zo+wIGqbpR3Sgyl1EMo0eolQ+EUdR
         HMZWJoNZJfC9ISyxYBMa2YlasUxHXfkF9FLGVdOdC59/2+gNMw/Ph11zPLEgnp0ZB4/q
         /vx1O8tp+tPpqsFgUMc8wXmlCR3cJZKsLaQcd2xBoPQee3KX3O4ACFgkIOmVroMOlwA0
         tyfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ffjKb1Hr;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h70sor8593182pje.6.2019.06.30.00.57.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 00:57:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ffjKb1Hr;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=B8cz0p1U2cEXshPnnN86RK5M/poNnk6a+Vr9fHBKncc=;
        b=ffjKb1HrgKUUctGTqK85NRnFp565HiDUpfM/Ri3+MUMkO2+p3U7fWXgil9oYaSsq7+
         R35g5lkpuQa56AWLCtqStNh0+CWkoieCbOcwjqHB+shzdZ14Dh7p+x2K9eiF0vRwQ7/0
         e+2Iah+RphOiCdvZW3mRXYNkcSPWu/GM9e4Li3JycDq2H9mFZyeD0spZ4bFDQhhrbwUu
         gbOQM6AdzjbT5Z0WOLG3lw2aLjNdsCgQTWhi3AS2ddpIooGHuX1bCzdpb2/dAbcfSva7
         nwpLe4mkdhUUzellr9Da72OZFTdBq/aQtmFTBINd1L8BFuPZrxNh8T8sjmx1X0zHFmTb
         LqZg==
X-Google-Smtp-Source: APXvYqxyXVNFtPTqFEC9kbmUTJGkH5SitL5qzTDfmRtyc0PTQLnSfVVEVDv2LlFkGqWo4kQoKHUCGg==
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr24134932pjb.34.1561881464652;
        Sun, 30 Jun 2019 00:57:44 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id w10sm5989637pgs.32.2019.06.30.00.57.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 00:57:44 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 3/5] mm/vmalloc.c: Rename function __find_vmap_area() for readability
Date: Sun, 30 Jun 2019 15:56:48 +0800
Message-Id: <20190630075650.8516-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190630075650.8516-1-lpf.vector@gmail.com>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Rename function __find_vmap_area to __search_va_from_busy_tree to
indicate that it is searching in the *BUSY* tree.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a5065fcb74d3..1beb5bcfb450 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -399,7 +399,7 @@ static void purge_vmap_area_lazy(void);
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 static unsigned long lazy_max_pages(void);
 
-static struct vmap_area *__find_vmap_area(unsigned long addr)
+static struct vmap_area *__search_va_from_busy_tree(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
 
@@ -1313,7 +1313,7 @@ static struct vmap_area *find_vmap_area(unsigned long addr)
 	struct vmap_area *va;
 
 	spin_lock(&vmap_area_lock);
-	va = __find_vmap_area(addr);
+	va = __search_va_from_busy_tree(addr);
 	spin_unlock(&vmap_area_lock);
 
 	return va;
-- 
2.21.0

