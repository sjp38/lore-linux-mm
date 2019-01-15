Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 288ACC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 12:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5A8D20657
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 12:03:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5A8D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8142E8E0003; Tue, 15 Jan 2019 07:03:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C13F8E0002; Tue, 15 Jan 2019 07:03:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B3018E0003; Tue, 15 Jan 2019 07:03:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11AC48E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:03:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so1033778ede.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 04:03:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=1AyYviTWrmxVZG7i6I3JwtFU3+Vu/ABOtg8aZQHEoDU=;
        b=RMtXzoXyiLVjq3WxqnwLrvjVdA8G9oDvAePhr2NO/3f6LKdEd6qYDPW92BTuZzmwwp
         6SOUhIGfKj4iFzHQ/3OdKPcfxy3ODNRnlSu7afIUoIBuRWYZ/XvJUAt8/9InuJs5O7ax
         sZYvP/tj04KHoreEqpyvNMf0deh16Wk9HvSM3arX/ZQIHimmxSjdvHHdTNv32tgWhv1S
         KgKAa27IZZDUegaHZsjAeEZYhvJm/CtfyxXdbXtp+kK1ExrUXjCbXgn+ELAVHSh/go9O
         ab7YaU/0w7XtNQ/X1/ToMC4ow/oE+HLHL5p20FYOLWzdoP6BpIjsMI5U81w7gANYuoUv
         vfLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdcSnnFM7DnGOc7yeplml5lLl453gwDCRBaOe/4qjngmiCPmJmx
	ckdzJbC1tBfHhET4bmamIWH1cyjx46H1YLElCusoX2nXPaW967Ei3XtByFJSpV1F4It39lMQjpe
	JIi/Zpluvys9lrKqRnLX8COXaMmI5bXeG4LoNYtZHD44cZEioBgjJZC3XcDMc2ZfrucWudUE2Jc
	jQ0/hDh15/Xrpmo407VWp5PL0/IJuJZzhZTmYPbyU0VfPxrhsdJGYXEsj37gc8NxeFGzdm3jFQE
	X0bUI+Hvw08/O0dlHQWPTRNVnQf8em6amT69MDC/zv81XlzduqQ+bg6IfIMtXCjl/AqAdVsdBcc
	6U7G8EgcQRJH8TE9zVy2u3F2w5+E+ENVFkjhFRS8zzapU3A0SRIS+EHWKZQCiwBokU6hxuPCcQ=
	=
X-Received: by 2002:a17:906:5e46:: with SMTP id b6-v6mr2844495eju.44.1547553795551;
        Tue, 15 Jan 2019 04:03:15 -0800 (PST)
X-Received: by 2002:a17:906:5e46:: with SMTP id b6-v6mr2844440eju.44.1547553794594;
        Tue, 15 Jan 2019 04:03:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547553794; cv=none;
        d=google.com; s=arc-20160816;
        b=LllGISm85tX/BNx1WF24akFli8v964M4p1+0spz0eNzbDTSp31CXWrPEAnE5DEW2cv
         5dJttHOspiG4tAMnoiJhYGInG3Tub/LQS1Me6ZMMHOOXZ+hR2Aa4XjWcTiZm/T9JsUR5
         DoFV3wvoHQLsMHMyauy4vaK0fb2HF0ByMaC4CQvEYjhMuW35/rzU3vX2fgJkGNSH6fSs
         jXNYIw1Rrg9UXeo3CrjJrUJbjtj1NHw78/cabTBEN5yRpH7+5UrYZInAKcqJmaW1FTur
         634abHuoOJ1eGUB7Z2YJqiyULfA2IHJ4PAu5lmrDss17J8+fV7A3U5dN3L4lDCRbV7mf
         eZ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=1AyYviTWrmxVZG7i6I3JwtFU3+Vu/ABOtg8aZQHEoDU=;
        b=yUZ3r7PWGYcWgB/xxyhI650OOuBnXb/Mtorsidn1DEKJrMWuAOeEyYVYK+c/eWMrzz
         qFobF30pZausQvHUkjmq1axCi4M5jXbbieB35m3kiTwDkOFC5LAzZTaSqagQBuf2rcNX
         tJdqtjc6ClYNwjapw9MuCazauZQThLU64gr9AzKqdQNK0JAQhetsJHAdFNCNoJO9qqzj
         lx3Tj/ZmmR/BB5iu/DYviM1RiHJdtF9Idbq72aPx92lCWeTi5bP7fXLi8qUbA7qbQkmu
         5Je3AXyLPWFJjFqLx92L9dRxU8O2jpgR9Uunev5mxE+jkojt0lwedIZg0KaboU84Th7P
         9Hjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor11144071eda.25.2019.01.15.04.03.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 04:03:14 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN6Pm52D1x6VWYSGwsa7PInXlY9o+bLrCPRRrH/SoMpTmVMg+eFjWY2khLL9Oin8Lv4xdLMLxQ==
X-Received: by 2002:a50:a938:: with SMTP id l53mr3060528edc.194.1547553794115;
        Tue, 15 Jan 2019 04:03:14 -0800 (PST)
Received: from tiehlicka.suse.cz (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id n10sm4749260edq.33.2019.01.15.04.03.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 04:03:12 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>,
	Oscar Salvador <OSalvador@suse.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH] mm, memory_hotplug: __offline_pages fix wrong locking
Date: Tue, 15 Jan 2019 13:03:07 +0100
Message-Id: <20190115120307.22768-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190115120307.KHg7T4MLJoyn62BBcAjIhJERbh8j-uvmCPH0icrWM18@z>

From: Michal Hocko <mhocko@suse.com>

Jan has noticed that we do double unlock on some failure paths when
offlining a page range. This is indeed the case when test_pages_in_a_zone
respp. start_isolate_page_range fail. This was an omission when forward
porting the debugging patch from an older kernel.

Fix the issue by dropping mem_hotplug_done from the failure condition
and keeping the single unlock in the catch all failure path.

Reported-by: Jan Kara <jack@suse.cz>
Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..faeeaccc5fae 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1576,7 +1576,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
 				  &valid_end)) {
-		mem_hotplug_done();
 		ret = -EINVAL;
 		reason = "multizone range";
 		goto failed_removal;
@@ -1591,7 +1590,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 				       MIGRATE_MOVABLE,
 				       SKIP_HWPOISON | REPORT_FAILURE);
 	if (ret) {
-		mem_hotplug_done();
 		reason = "failure to isolate range";
 		goto failed_removal;
 	}
-- 
2.20.1

