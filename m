Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31CB1C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 01:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B768721019
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 01:47:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KMAznR4/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B768721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26AA48E0003; Wed, 13 Mar 2019 21:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21A998E0001; Wed, 13 Mar 2019 21:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 132238E0003; Wed, 13 Mar 2019 21:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C67758E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 21:47:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so4359267pfm.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 18:47:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=/Z3uDMa2/QlCumOU32GtDDc76uVvdXwDV3Ho6CxdykI=;
        b=e5LuueuW5SxMPcf/imn4hakC3Hk1oG/qDP418xmbx2JGFMQ1Gee0vWhAQfBxNrh8qa
         gIGqhIFzZuOHrMpkJuQq9DE5H5D5wYo4wAvdVEzPngMD4dB9gjuDIbFM4Rg8NxHSA9Tb
         bsXBTsE89POMNpI30cxkYpKxR7oNaI42/QvjaE0tAgUFPeckepisSDkUJasGBawXlYpO
         1WJ1WOtv/m41PMedUZt3+eIUGjQjQ3o3tLBXxgGR22JExANKGMGxtB5Ulmyc0pTbwLPI
         BDef+ODTgo7JaticQUgy/6rDFYJs/RDj9E1+ASJ3Upy5JyIFUa/cb/IV0Pg4JEOrYBGQ
         5A9A==
X-Gm-Message-State: APjAAAWDI8tCS0UAcFb3thaNXHWFC8zAtGf+cfOJ8+fhTQnyMvGTizPO
	ibPYPhMotIjTehf1PLPyzY/oPOe9mK8L5C7laNNjC59iWJycY8gVce/ZISPl33+h/GRN27FsSLL
	C5neEPRb/OlCC4iSR4mTUgX1eCoCdng5osD55YJXruslYVRrx2AXVZ8OvRkOPsok8XYiN1eO617
	ItXRreDYSRDZEQNQ+UsVUr//XnkeKn2igI699b3efmgDDKeIteGpOdRS0w3Ht54DNCFN8MJzYcj
	dzCMpyOIAlLfO0sHIHxu1m/Cxd6ZRFmSJisG6EtuwgXLHDuElSgUgklCu2SF907u1X16Q/d2kK7
	exk9yUevMOBXSVFxfk+UaV2YdDZTP8caijCFqh/QV3JzsdlYhWi9VlIkeyBb8W9ncMXnn8BYZCx
	t
X-Received: by 2002:a17:902:a981:: with SMTP id bh1mr49410940plb.88.1552528025262;
        Wed, 13 Mar 2019 18:47:05 -0700 (PDT)
X-Received: by 2002:a17:902:a981:: with SMTP id bh1mr49410878plb.88.1552528024039;
        Wed, 13 Mar 2019 18:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552528024; cv=none;
        d=google.com; s=arc-20160816;
        b=tC1qg8kKIqRg5a/gWpPmiRIRAw9bqfLQchRDzxWIlENfeA0Vfz079gbMYDyMb3otth
         gjoEDqpe9LgACRosqjkARVMrPSN7TtaqRtUVNOzL2BlvlMqwBuDONefTDoTB5PKbGwuP
         fL7xH3LTqLghvILJg6m6NwjAgnxlNUybsRodCXXJiWJI4rQv1cBurfSuhvFe3FS16kcM
         d1lJbOk4ik1Ur3V9tUvntIbdTRNEDxcOnGo4FOeYJ4lFwRqVcPJtartaxCaii2ozV32I
         OdhvCcUznzQh1fm9oVzMYVPbb6YuNaJ/yvXDNQaAnrVntEbcoOQ+zmVeHd6eWeTet+Zk
         2q4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=/Z3uDMa2/QlCumOU32GtDDc76uVvdXwDV3Ho6CxdykI=;
        b=vtOrRmCIcfkUj0OZ+ExO+u73xK2BEJ8AlBDDUYfLr/ohZTqX44lbO+kiHMocynYJHI
         6C3jAGutgCIp8UDCbVnqBV5yK5WhxrKqBeTVDw3TQ7EdDUhfFAJX47K5f/HKmv3uoeC+
         XEfrrzEXIK34NDUy5T6+H9feE2SqnSs5+EQEcZICDgd64y/iaKTF67nmRUFNa8x3XgDv
         nQFtHa7U0zooTqCZKQwivnJAPVVhuljXut5kfQ7thaO7kOyNTNN+JD63yXp//4nsbk51
         QWveEtSaZmfUKIxXiy2jg3yFpchetCWRpbfj5RF4sjay1dZs7d3qAKuX5U5M1eQIuW1/
         D+1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KMAznR4/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gn4sor3751539plb.64.2019.03.13.18.47.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 18:47:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="KMAznR4/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=/Z3uDMa2/QlCumOU32GtDDc76uVvdXwDV3Ho6CxdykI=;
        b=KMAznR4/NcMOvdHnkcSSaLpesHhXGLwy+U0F+iPf/eYULb+JtDgJFhz0E/+QpwzgB1
         cKBoamdA0hipATXAbht4LFOYtk48d5X+FvJnRi7L1q3Zn63FZZFAKZ4v3DhHZVoj1Eh5
         qeMp0tZO9PqqXx79EqS5dw+dmXGRZ6URqfLHwqb6DzakFw+DOVSuIigvNPlrtKJRIhj4
         gZP+2iR5dl5Qq0RGtirERw3gB/j2DM2VA75sMFNDi1/2YDairlcp6LpaAKx8/rtWwnG3
         6QyA5j3fSQPy5CRcd+K1Bm9Y3ha/m9Y502AYV57v/NdmZzpXgVHYVSTWFkJyfts3H8Im
         1XmA==
X-Google-Smtp-Source: APXvYqzIrTSRsTzd8f636TzWqjoAMEhSK0sGhCEnjCIq3nrXnUM/A6UNvSXkTumDDoxADJxgy54EYw==
X-Received: by 2002:a17:902:1002:: with SMTP id b2mr47361083pla.248.1552528023732;
        Wed, 13 Mar 2019 18:47:03 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id n23sm15442045pgv.86.2019.03.13.18.47.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 18:47:02 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: compaction: show gfp flag names in try_to_compact_pages tracepoint
Date: Thu, 14 Mar 2019 09:46:38 +0800
Message-Id: <1552527998-13162-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001495, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

show the gfp flag names instead of the gfp_mask could make the trace
more convenient.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/compaction.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff..e66afb818 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -189,9 +189,9 @@
 		__entry->prio = prio;
 	),
 
-	TP_printk("order=%d gfp_mask=0x%x priority=%d",
+	TP_printk("order=%d gfp_mask=%s priority=%d",
 		__entry->order,
-		__entry->gfp_mask,
+		show_gfp_flags(__entry->gfp_mask),
 		__entry->prio)
 );
 
-- 
1.8.3.1

