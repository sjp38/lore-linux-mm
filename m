Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39C17C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:09:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0267F208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:09:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0267F208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E6906B027A; Tue, 28 May 2019 12:09:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 996E66B027C; Tue, 28 May 2019 12:09:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AD9F6B027E; Tue, 28 May 2019 12:09:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4A46B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 12:09:09 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id 25so3866057ljs.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 09:09:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=lGXYVbVFDLEG+3o+OEguFFx9LFqpstQwPQERo0dQPlg=;
        b=ksoIOlD7EKl3dzvB5rK5NE9964zgiLqsPQDl3MyvyX0DVWbTHzShoQl53FGShGna0C
         H3m28JBpVtuHK18CBNFX0WSAayeJYm8rfRO2oYF+ny5CixaBdzrn5TJGXJACvCPbzMLe
         eRt2Z2rwUOQjIKJuOIU7MtwvTVYoahrlciyIi6gjtbOkbFK18zcIGY3bcKoOOVYxicuT
         WPfkUU7pn4HdpoRALZJDVqsRVeIYm7scGQPRpJJl+/YziZ5DxbXS6dCmAunaoNp28rAQ
         /lkZzQP9Ba+N/hf9RGHLF6vOAWLJK/ibKHJy7ctAU+HvJPOoIWjn7xi8rvYfVQXVnT22
         wzhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV3ixuNQDTDdh8d3lz9aPDGmFtNyds53G+TgCXhrfcaN2DnvcPF
	OlQRJSFFJBNknaJyoWA0do8zVjKx3JVRw2dBJKBphP91EHi0q9gfoXKoF/awjaVibIE9SyNr85R
	aM8C18L2zCeO1fx1N1P7acr8lf6q4YrDn3VrGA+N4qxchP0P1YYA3+OsLdu+2l5DNjg==
X-Received: by 2002:a2e:9bd2:: with SMTP id w18mr15790691ljj.120.1559059748663;
        Tue, 28 May 2019 09:09:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYHJElvETaVtSOXK3kumDDY5UgcPIDi2ETKZXMEXXrTLpcDEkG0I2bbGPoc/AbXVCnCNwI
X-Received: by 2002:a2e:9bd2:: with SMTP id w18mr15790646ljj.120.1559059747633;
        Tue, 28 May 2019 09:09:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559059747; cv=none;
        d=google.com; s=arc-20160816;
        b=lGzGhoCYCP1biln7W5mSNvseTxyKFyCEiXVEXeotNFe+unh5mPESaTNNXFgHqzgU22
         8viz8utql1YPsd03Y13rKzDh8abLmIl/X7QR6hFtC+Op6Zhtrxy8Q6on1Iz0FG5pELx0
         I+5AYtNVg720Gtj+G9W5qXKSAwhk99B+Qx08iWwVEhNTjP6Lric7IcCxWrlUe6ggNjLa
         o93cLJZtCEmGTKIViPFl3NEZrUQybRvH+fz8OHAsi/avbE4a98dW1cqvVbH6qPu5Uc2f
         rGLgGi9X2a/oeUrD/l85EO4QDS5XUPRwadq8Jiq4UqK4kJmG3Fq1gChf88+Y+hyHRALX
         DY6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject;
        bh=lGXYVbVFDLEG+3o+OEguFFx9LFqpstQwPQERo0dQPlg=;
        b=dRZcYncLijdpprdn4lJC8+C9ufpocGSnPeOYZ/xLHPP9VRl87pREBgT04tw1PaucXN
         iGE7eLToNIkXeYfl37otrXj5YluwsBHy8h3PP7+iY/+OXD0FYTniuDTVBVUc0ieds6zp
         qvjJPgDNYBStuQKlW3c2qCC4nuDiLzPyz+AP5sIsHpRJn9p9VFi7w7hHlMtA1c5ERd68
         yDZ/s2DJGgt2HAt+wMI/5ixGUsjwbrlZD8hf9wMh2mi+WqaN9iDG7ri0SsPptLWFKlfd
         tFGcwM02brZEAnQe/6ku/oyFyGSPMHJjHCWLtmS0NcEUtM5qoulWIWTk7aOXEUMdadLl
         oREw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q8si13804380ljg.5.2019.05.28.09.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 09:09:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVeet-0005lz-4x; Tue, 28 May 2019 19:09:03 +0300
Subject: [PATCH] mm: Fix recent_rotated history
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, ktkhai@virtuozzo.com
Date: Tue, 28 May 2019 19:09:02 +0300
Message-ID: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes pointed that after commit 886cf1901db9
we lost all zone_reclaim_stat::recent_rotated
history. This commit fixes that.

Fixes: 886cf1901db9 "mm: move recent_rotated pages calculation to shrink_inactive_list()"
Reported-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e873eca6..1d49329a4d7d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1953,8 +1953,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (global_reclaim(sc))
 		__count_vm_events(item, nr_reclaimed);
 	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
-	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
-	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
+	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
+	reclaim_stat->recent_rotated[1] += stat.nr_activate[1];
 
 	move_pages_to_lru(lruvec, &page_list);
 

