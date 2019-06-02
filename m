Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55F6BC282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A964278A6
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RxsN7voa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A964278A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D4EA6B0006; Sun,  2 Jun 2019 05:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 986B46B0007; Sun,  2 Jun 2019 05:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827266B0008; Sun,  2 Jun 2019 05:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 496A06B0006
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:23:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so5940176pgh.3
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:23:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=OvirsbCOUeiXlydGsQdyHrJsMeeWA/TWX5G2ToCQ6rPv0cqN2avVON+hnOIu11BgyT
         yqF937dw8FZL27MRQsD2dDv2qSOdg5MWHP43KilCiBDfTwS+KOh9b7OIUyQ+K2UTZkg0
         50LjjuJX5rjQ5IHgGapXQpXRsYTJMmbXPSxNtb0lIHf/bzzsW2k4g5hFGqMYplQ8+YQG
         T8XpKQ/zd4eu+XfVg2fRAFBauKdW0YCTbuIML7Bm/vKm2enSj1RvWEedJOTjcit4IQQ7
         4pV1Id2RGyrLuKmVIIvaV6ISNfQVcdHZOyKeYYKQwo/CXQrpfSEo49pzzUbtqGNFVuB8
         NePw==
X-Gm-Message-State: APjAAAWjtnYv5ULEVtgVGHkLvv8klnKJiLqyReEA3NZsuM4AhH+Xyovi
	Uc6o4PvT39CbE71etDVVbSN8aqyi90LlCn036abCXHrCvHgTZRNdMCtAyvjGX1UxeSbd5FPVdv5
	/RsznciqZ9weM9Jc1dNb6DHWs8KOTRzSOhawank/9nO0aIznWYH7fY0vBmmjFcDPscg==
X-Received: by 2002:a17:902:8c82:: with SMTP id t2mr21918745plo.256.1559467404749;
        Sun, 02 Jun 2019 02:23:24 -0700 (PDT)
X-Received: by 2002:a17:902:8c82:: with SMTP id t2mr21918706plo.256.1559467403794;
        Sun, 02 Jun 2019 02:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559467403; cv=none;
        d=google.com; s=arc-20160816;
        b=aBiOLVKkAu7f1DOSIcSo2V2eniNXKT2Yv6ulPGTImDNa1bLevwIYUE3AbBnSL9g3s4
         C3+0OfPwBI2cHJCnoWDAP8t5ZfGLZnXp8/ZKm4cwrRNzf1Y+DujbWlqyHlPl2FYELSol
         YfB9cdMe+5Zi7z/I8g2EG+xyl0ZryP5HvXx/Jh2Nbm3YNCIhrF/p4vWFSHZbfHZHkpAc
         E6G4tX/p1HOmNG/h5CgQtZhYTtRtfg27KIWfgIzQurfq/ERHxRBcxae1vRDrQxXCt1Qy
         zLo9TC32trmn6xbN2UUTnjt3yYeLj8W++g9dCWzeWKyGI+gcSm2bB6Az+Ftliw53laWO
         QtVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=s9djITum9raUHc+ifnAas24OYfv7wFGCLWNQr8edHaXLULBndvH/DgIYpAeTGrNK0O
         AQjXE+osOL00C8UGlv5ZdpaCDkG5xWd9fvCMVsdr/r7VUpowW9j1FJXt2Y2N5JqRJ4NM
         kgKigccdshrhAKYPtxa8Z997ceBC6WbT9o+T3o69GLm/9sTXhziXjSOwjn+ZeQt2fDwf
         kTtj0MUOeCtBzZ9Ties5KACIlcDsga6D4A0XylT2JJuWMJAHutjyrTG1V/8DsJl4iIb0
         phslSl6KF0vPwksODAx8+INA0cXuz4qWrFXMtU4N5zH+vRxRUQkt7EKqdJ8AsvCpDBcx
         uB1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RxsN7voa;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22sor187664pjq.20.2019.06.02.02.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 02:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RxsN7voa;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=RxsN7voaEB59YA90a3K6sWWDoXVjISKDQkOjoGwjLil+AEEmOkxrrPK1YpIPPrf2Ut
         kWuZM4pBc6PXFWAzAdQ4zykc4c7jEHsanwJ1hakQvSv5dXCRW0XopfDozv5HHqpWUXHu
         D7f8yc79qu7or7PPP8++pcsUCJe+zcjq0LSbf2PvZHjWsGQwnqDYumFaYf05NSMbh5oK
         2XvOT+7G4WOrx1cdsN9DCMDGyDRVeuWw6D31Vh6sYglyffX71wqSbwfTG54h1JRi/B4C
         CBw1srgIo4tRRAt4iSmtFQTRRPqAdv3lAc2D1xCH3neJHSZ5NCOilB2nuyS3PHO01fjM
         MrVA==
X-Google-Smtp-Source: APXvYqwt4C1tIrWdayHBYjIEmKWsKaj3nlUktKW7lwVemvIfwTWN0Vmft4eHKBG1ctfShEIzHIK7Dg==
X-Received: by 2002:a17:90a:658b:: with SMTP id k11mr22036913pjj.44.1559467403548;
        Sun, 02 Jun 2019 02:23:23 -0700 (PDT)
Received: from localhost.localhost ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id t124sm11633191pfb.80.2019.06.02.02.23.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:23:22 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v3 1/3] mm/vmstat: expose min_slab_pages in /proc/zoneinfo
Date: Sun,  2 Jun 2019 17:22:58 +0800
Message-Id: <1559467380-8549-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
References: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On one of our servers, we find the dentry is continuously growing
without shrinking. We're not sure whether that is because reclaimable
slab is still less than min_slab_pages.
So if we expose min_slab_pages, it would be easy to compare.

As we can set min_slab_ratio with sysctl, we should expose the effective
min_slab_pages to user as well.

That is same with min_unmapped_pages.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmstat.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d4933..bb76cfe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1549,7 +1549,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 				NR_VM_NUMA_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
+
+#ifdef CONFIG_NUMA
+		seq_printf(m, "\n      %-12s %lu", "min_slab",
+			   pgdat->min_slab_pages);
+		seq_printf(m, "\n      %-12s %lu", "min_unmapped",
+			   pgdat->min_unmapped_pages);
+#endif
 	}
+
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"
-- 
1.8.3.1

