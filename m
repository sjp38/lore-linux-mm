Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C04AC468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1A5120859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="me0zKeiD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1A5120859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CDBD6B026C; Mon, 10 Jun 2019 04:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57E6F6B026D; Mon, 10 Jun 2019 04:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446A96B026E; Mon, 10 Jun 2019 04:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7906B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:42:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so5353719plo.6
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:42:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=CA9s1JZao9GMJxYOskNf8OTGgZ6sg87fecgDdY4NEfw=;
        b=qnmolNbzcm2Y03vhiefKk4FrxnCyWfGj+BjyAIoSgkxSPSvk8sxLELXUYuCpp9Z8PU
         YCcTquEnyNQRahGb/3nvcbMytM11atEcrSeArUZh6XclU1naKPhTcczIx4vYYXgaXAcn
         any1GmqSee2loJPzPEleFv1llLNtpa0DHexL3LVqxYmUB9FKDcLQUj9Lekwg4RJbVnk9
         yMQ9KMmALMEYdnCl+Ex0mGZebe0ChKnMd9p8uynO9RyeLmm5Vn/q9X5NwJ924PYdJok1
         M4j/wyPzWbpETyiBMd8Xf7pjyqeXBpu2W/htkHYjCH6h8jHW0CA7qTcmY7/FpKLIdvzz
         zAMw==
X-Gm-Message-State: APjAAAWMaX2Jxwu/nib2+3wewuw3Mrff/UtqSfwD7KmvyoFyqpOxmprP
	Cgbgpa3LF5xWvK//sM09IbGexEyEPY6VzpFlbepG6uv8jwXH+gYdW3mYmAKJJ8J8zrN+WrjauBM
	mr6AnA/A7uRZe8c+/UntiZMsfkTfFkbzZG9Y5T81JON831UXYKoAWBxnrYXwPyO+pKQ==
X-Received: by 2002:aa7:8711:: with SMTP id b17mr15744023pfo.234.1560156166641;
        Mon, 10 Jun 2019 01:42:46 -0700 (PDT)
X-Received: by 2002:aa7:8711:: with SMTP id b17mr15743964pfo.234.1560156165639;
        Mon, 10 Jun 2019 01:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560156165; cv=none;
        d=google.com; s=arc-20160816;
        b=I6Ko7EszGBXP0l+uFPdynGvlYAcca3ROWmMcsmA82T/D93FA3Nrx+eFP9XQlOydXAM
         fc+tyVFPZtXF3WCzbFvMbVjCxrQN47d7IDnKVwu8mmMIMjQ+crMengjAIwJiG22KYD66
         h1sPF6rp6MXg5mW9uaqT1LHmAFKHjeDEBTQnCAIiV8N2V64e93MXhi7/EKIu7yRxgdS9
         KAJMFcW1vrGOJqijBcjH6iUONL8966wyce7LD3Oygd7GM5eKrE7grjlYYTkLX0oBewjE
         1AZfrx7zvno/YVx6OgMkL3eVfojwEmJxuht/cSxwtNp7+IckTr+ymCmqbOx+idKFBKZB
         kRuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=CA9s1JZao9GMJxYOskNf8OTGgZ6sg87fecgDdY4NEfw=;
        b=XGCFLdBYezB72sIbvPRr2WipCjiM77n2tbndzQdU8tsCsfNaXt99Xw5FJtPGgfAuDo
         pUijPDzj6aqN+qQWDuBqrUINYh9r+xc4zGnleeVVGDGvsRBZJB5ieUKEBXhYWyxU/oCO
         tspYZ+fL7BgZ4sddCAx4HfMOtmSBrCi9v/Zm31fSp9VEKFwU+Fn5IOvv6eo16rTH/6yD
         qgyIbyYkPAc4Nex+/pCL6b6cyjYCrQZIrZJ/hJsB4O03EIMAesOfhXMkmrRKV0aGVkvi
         NoLhyP0ibBi03Z41VT0rzVLVM91ICp8QAHzczo3epq7VXQltxGCL53txJvhYXWkfa7oQ
         k/rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=me0zKeiD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u19sor10996401plq.53.2019.06.10.01.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 01:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=me0zKeiD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=CA9s1JZao9GMJxYOskNf8OTGgZ6sg87fecgDdY4NEfw=;
        b=me0zKeiDQaQCA/+n6uUXKLfD+uZQsfOdmcBOUmSJjQk/9q23mX/Rtgql2QJCll/uey
         d/znrlnMXTAEK988oPo7T162iaSkeBEEH4OeHdkIl/SXVfrmt6HLzrJqNakVVL7gEZmf
         cPtlWh7LrtPN+ph82adV/JsR53fYGXJYYwLvJjt+RJOLxNmnXLPOrn9Bp8Klzn+9h+vP
         3c3zkzLMPBAq5GKnqqohEE7DPKEpkt4bV2sbPqvDNYiaQl4P6xsfzsEqEoRaCYPHmKjT
         u9yGkxYauzhnC610zvRm/ptGKStvnNcXe4z6MCYIbz1y+2C29ZK6NoxeqHDxmWfLwm3N
         AP0w==
X-Google-Smtp-Source: APXvYqw/szXVi7ZQlMrIxz5kRQyRKlRRvBFsHeKUxOYxonhzAXx0I7fw5afZ9VRqhbzo+udPV+iyxw==
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr68270585pld.286.1560156165301;
        Mon, 10 Jun 2019 01:42:45 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id q7sm8938339pfb.32.2019.06.10.01.42.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:42:44 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	anton.vorontsov@linaro.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: call vmpressure_prio() in kswapd reclaim path
Date: Mon, 10 Jun 2019 16:42:27 +0800
Message-Id: <1560156147-12314-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Once the reclaim scanning depth goes too deep, it always mean we are
under memory pressure now.
This behavior should be captured by vmpressure_prio(), which should run
every time when the vmscan's reclaiming priority (scanning depth)
changes.
It's possible the scanning depth goes deep in kswapd reclaim path,
so vmpressure_prio() should be called in this path.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b79f584..1fbd3be 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3609,8 +3609,11 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		if (nr_boost_reclaim && !nr_reclaimed)
 			break;
 
-		if (raise_priority || !nr_reclaimed)
+		if (raise_priority || !nr_reclaimed) {
+			vmpressure_prio(sc.gfp_mask, sc.target_mem_cgroup,
+					sc.priority);
 			sc.priority--;
+		}
 	} while (sc.priority >= 1);
 
 	if (!sc.nr_reclaimed)
-- 
1.8.3.1

