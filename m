Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8ED7C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86D64218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="mUmeIE5t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86D64218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6F4A8E0004; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C19148E0001; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE1348E0004; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB118E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id r8so17957089ywh.10
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=n2kszXwCnFM+aRWR5wlv7UWDw610mJ75OBq3Y8ADT5B/LhhsfjBjiC33h8hcl1Ji+s
         5HulykOIJVmlWyMIVNLhkQNOCzpyW8ofwKdcXICgPPQ6xlVPng0waUoVOvL1vZcKAGtn
         z5gyCBJXX9VPFrTTWDUfPRtGlgeXHz/hIHrHqayziroyVW1usD5S3WdKh+CyL2HAL0v8
         5JcI0AHHRfoR83zzbp49Z44B+2MOYvJphIJcZD8Ur9CLw19mVhgjbd4A0f8i3py/C36e
         Qdr+LIHzudBTW2ZykcfacRtvpHiR7dh5hzA0Y3vOrRoH1T5bCKIvpcOVYy7Lee02k4Ed
         Z2xA==
X-Gm-Message-State: APjAAAUobbvowpLWlHQIvNgz7MXaxaBkHtrDGOMdwpivy8CQAAHMfohG
	8V3aGuMItPxSxfHCn6Dj42VDENcGdPisucggtrgnLfnkltuCe1D2qI9pN3k0IckSvKIAvS/x4xg
	NB8nMMr9zNVj92OALDY4gEEMI3ujWVyRzmEAPrpoUCr4IDS5owUpdfSHTUIt2+eiFvNqqg5XFL+
	9Sij+AuLQZrhm9EP2sVvT/xWA1RSz3PcEZHakHvKQgsqb2nt/RyIiZAe7zNAoGY+qWW9zqnEIxr
	sdlotUJRcLyj/mGU/BZA0N0azT7tnLDpN7+sfrIH1aHCqCjtuV6MS9MIL4lPnhub1reeQQWUlEj
	ZMwPGIfxbCJoKJ7Q+yNKGvt3CDK13o81T6OJny9sQWoSV5r5hrRKXOXQNT4zNMUrAeOkqKEtKK1
	S
X-Received: by 2002:a5b:10c:: with SMTP id 12mr187423ybx.323.1551371443256;
        Thu, 28 Feb 2019 08:30:43 -0800 (PST)
X-Received: by 2002:a5b:10c:: with SMTP id 12mr187320ybx.323.1551371441966;
        Thu, 28 Feb 2019 08:30:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371441; cv=none;
        d=google.com; s=arc-20160816;
        b=bGuYHK/ZXY708Rc9+9pNWBYNxcA6JZ18aTfPbGwcQJ6OCEoSNJcQzptTS+p1NA5HMi
         pQjljoQ2nrMlnV9w64gjvLeW0wvvxKO/HgC1KFCSmHphRTk1ued7hgKDCME0CIEeaxUl
         EiS9n1WfMWkDXlCj2W2DbgF81tK5b8lznK0uMTWhBELGd2hcCCLnuZiQl3vORVred8HW
         5poVHQEXEf5koWnmvjzOePvrmxQ6VWbT03tNx6JEzMxl1pIbmdS/Q72brephTsrWiiQH
         K9JgFaMjFP+cIlwH7hEx5xNlzyAuL0OXnkudCJu7gQrmRyKq+8RRX9Kyc0hCNQaLC0Bz
         w0mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=lH4uAWY9+ov/T1bq3esR7MHxWKu/8fmX9N3NOcbiGybS7olCknvYYA5LHhnaYfks0g
         68almH4nzhxt7K2Cc9uoFHPYdaZAH/cOSChqPYAzQ2LVI6USSjugyFvMQKdw/eoT+C7b
         c3oc82WBM2R0RpeHYw1gzoq7nmFeEFoXBQpjBcrVBNxolUyuYa+wz1no+nf6H39XMuuf
         ccn0Wuws14ME2mkr7fHTSoRuFEsxfn+5f8kCcMK7rsrD4TmzPMbgusZxvRihfZe37GCW
         2QwaMZZdQ+dMK6s5fT00kjrr3n2DZa+M9dVXsG7+QM5HHSg1zcbAf2r6Gbpu+rV5yYW5
         pkbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=mUmeIE5t;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e124sor2295791ybe.175.2019.02.28.08.30.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:41 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=mUmeIE5t;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=mUmeIE5tnpsUGSnPqHmhaPEa7lf70tbLRHRnTncX97PvuH/o83yraWIA5zNr2rhiIp
         mpkAWKlqywdH7kW6UpgZyAHXZCyBpYNS+SG54JVKSe2fLL5wNcgjH9Q97zxt1D5RpII1
         WeWjuyR4YDKC3jKLczUULysqQOcc+yP8bzEynWwg3HCg5WHMxRZlTti0KtykiQuvv3kq
         YROup6kl8Iuyzca2iPVlj3322bMupx6H73LQkPOdGiwtgd6ZjWn0XHKo9doJy1JuxVuG
         Mo2SA/F1rgT6zxF9PDEGAuC8LLHWA/fy6BG5ikjx7h55H5U7V9xL4eH3UKlRj6MnSuI2
         /XsA==
X-Google-Smtp-Source: APXvYqxewDo9FoX7nVCKQojbWSDBBLdU+jLrQJ05GmxyJbsxGjn1zJNbtkW8/KWmBzXl7+uvezlSOw==
X-Received: by 2002:a25:c0cc:: with SMTP id c195mr229095ybf.166.1551371441698;
        Thu, 28 Feb 2019 08:30:41 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id l202sm4189121ywb.72.2019.02.28.08.30.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:40 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 1/6] mm: memcontrol: track LRU counts in the vmstats array
Date: Thu, 28 Feb 2019 11:30:15 -0500
Message-Id: <20190228163020.24100-2-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190228163020.24100-1-hannes@cmpxchg.org>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg code currently maintains private per-zone breakdowns of the
LRU counters. This is necessary for reclaim decisions which are still
zone-based, but there are a variety of users of these counters that
only want the aggregate per-lruvec or per-memcg LRU counts, and they
need to painfully sum up the zone counters on each request for that.

These would be better served using the memcg vmstats arrays, which
track VM statistics at the desired scope already. They just don't have
the LRU counts right now.

So to kick off the conversion, begin tracking LRU counts in those.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm_inline.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 04ec454d44ce..6f2fef7b0784 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -29,7 +29,7 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
-	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
+	__mod_lruvec_state(lruvec, NR_LRU_BASE + lru, nr_pages);
 	__mod_zone_page_state(&pgdat->node_zones[zid],
 				NR_ZONE_LRU_BASE + lru, nr_pages);
 }
-- 
2.20.1

