Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D24C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B471620693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B471620693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E94888E0012; Wed, 31 Jul 2019 22:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4EC8E0001; Wed, 31 Jul 2019 22:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0B848E0012; Wed, 31 Jul 2019 22:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3538E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so38686110pld.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wOFTjlq9ACF/EsgC3War9On4yRhkld8OJAs08VCe3Hk=;
        b=KJH22lfD8YDZwea4i8+5UysiAKD68LxFEh4I7KM7mw1yossokrWL3aNZAze0SO+EXp
         D23iy97GcBWxh/lyPGt9vjLA9CRTIZ1ijXwBNCrN2m0VRJ6yqgIoRCprOXOxffxdoTMs
         ygbOTkA3/6ZJz5/CRpzK8OVMuqp0h5TYI0fZZ4FCGEZ55O8kCqelk+rJTnc8shBr26f3
         G0HX2Q4ggGaNoI4lKfBuV6Q4vQewa6lpzuckWljMmiFDME+dSI/4CSKcbw6QVQDFerWg
         a0W9kGlf83EhPg1ZyrHu+M7HP94It9mMKT8w4kg2q2PWc/uVV8D9JQvECoMOV2mVhdSZ
         acXw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXFDiwTNl9A2Ea0vt36espMYe3Ibx4dhDioyckkwgPQ+LZ+1wRV
	NNZWEYArU+PyNZ2+ciynjG1a5V+XtM4sYbr5EcVg6l0xgUtX+riNRkm2dPNjqm+uj8TZE7O6axI
	emk+wqzyUvrLqnoUUaNQw1yAGbhqkmyvL+oEKIsHKo0W0ukYXuSI21Dfw2s7mvd0=
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr15845544plb.7.1564626815199;
        Wed, 31 Jul 2019 19:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+kOj0irYS22kYEMh+sKT1kc4BnxsyPoN0KQ1CNqVyaLd0OX0FTQEePmP7xMhlQTRy19xu
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr15845493plb.7.1564626814063;
        Wed, 31 Jul 2019 19:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626814; cv=none;
        d=google.com; s=arc-20160816;
        b=vMr0mPAKLdVznUnAR4/ERviorjFtu2lRfyZyrhAqFrHlRqSjeb4Hq86MPUWjNUFX5Y
         Dd1R1APWIkE2vM28oGeTy2C7e4orWQ5o0IE3iMQ12BQHPdMqN7HTvpkurJWaeuYb8L7X
         WF1FuiKX9zwEz/gqGfKJDHmaewDSM7CNIWk7U84bW1NHl9r6zIHTOMGlLmNXqx/tbJA4
         J8oMzRCviSbPhjpH2py6Pz9Vv33rtsNVlq3G6CEUO+jSFe+6o2lAapDdIV3RMpxBnJKO
         gSWyF1tfqARF2Bk4MS5CtsErSDv7RShVMKWJX9RGuwGLab0d6HR6//Kt/TYmJlmlZiQ+
         4JIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wOFTjlq9ACF/EsgC3War9On4yRhkld8OJAs08VCe3Hk=;
        b=AnciSB4ru6yVs2JZyDf0pTz75kOJMGg165bg/ro6lxKhwRGd73TdS4yBcKmAg0EX6k
         /5FTMjP9u+oxxSK6cjSR4wkm+dCmUx/oJwP3kyF8PwGZiTZ2KjSb7Ae5O9f1Sev+FYS7
         hM4p22oiDkc03DFkw4HmHjwnLcSviHvymmqUuF2CHsPGeTTS+e2OAlPRhO04gxRnihgr
         FLgB4b92TX6nT9cLnVFT+SSQUbDcNiW+JAJUYj7MOc1lBsv80gWcaaOa7UL0AfVHxWpj
         aHusRX2qjf4R3q2om4UBj7UAI+4+GtPhSPb3S3S2NO7lOqdvyv6oFftsMl6XfWFwDv0k
         K4dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id w21si37417337pgj.153.2019.07.31.19.33.33
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:34 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 07DE9362348
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:32 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aO-Nk; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001kZ-L8; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 01/24] mm: directed shrinker work deferral
Date: Thu,  1 Aug 2019 12:17:29 +1000
Message-Id: <20190801021752.4986-2-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=3J8m_CEvPCn7CZIx0tYA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Introduce a mechanism for ->count_objects() to indicate to the
shrinker infrastructure that the reclaim context will not allow
scanning work to be done and so the work it decides is necessary
needs to be deferred.

This simplifies the code by separating out the accounting of
deferred work from the actual doing of the work, and allows better
decisions to be made by the shrinekr control logic on what action it
can take.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/shrinker.h | 7 +++++++
 mm/vmscan.c              | 8 ++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..af78c475fc32 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -31,6 +31,13 @@ struct shrink_control {
 
 	/* current memcg being shrunk (for memcg aware shrinkers) */
 	struct mem_cgroup *memcg;
+
+	/*
+	 * set by ->count_objects if reclaim context prevents reclaim from
+	 * occurring. This allows the shrinker to immediately defer all the
+	 * work and not even attempt to scan the cache.
+	 */
+	bool will_defer;
 };
 
 #define SHRINK_STOP (~0UL)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44df66a98f2a..ae3035fe94bc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
 				   freeable, delta, total_scan, priority);
 
+	/*
+	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
+	 * defer the work to a context that can scan the cache.
+	 */
+	if (shrinkctl->will_defer)
+		goto done;
+
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
 	 * pass to avoid too frequent shrinker calls, but if the slab has less
@@ -575,6 +582,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		cond_resched();
 	}
 
+done:
 	if (next_deferred >= scanned)
 		next_deferred -= scanned;
 	else
-- 
2.22.0

