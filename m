Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89EF8C31E47
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 11:17:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29A4D21841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 11:17:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29A4D21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85D276B0003; Sat, 15 Jun 2019 07:17:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80EA86B0005; Sat, 15 Jun 2019 07:17:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FED08E0001; Sat, 15 Jun 2019 07:17:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47A406B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:17:27 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id x27so2428552ote.6
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 04:17:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=D4s3JSPvEUNvSV/fiVs5AxXLIEoYgFmz0uGEjvS+fI8=;
        b=j4nO2wlUmCOG9FxlHK8+zLSOkNL4TL7OoIpJk3XThjO9pW57jicJSEjvNNy311uQ+q
         TEWtF2IpwhZPIAuY8gV4xRE8eX0WMhXJszQ225/UQwehv4V5DMolOieiHrD881RNjGB8
         1FVY7wcor8M0qCo5m2LYEm/1jYOE+o5KwAOFMM4hHEbCq97j455lTf+aIpSJvdYTVOoa
         WIRBntArqw5Zpsgkab42UWCHmaCUpDJBQeeQuIWqzi1jDj1Xj5LfmxJJJyuRmAdgt6qi
         rijSwWjQSyijsAAC6p2piXoayVrbyqjZmb03xqhkZajRGNhF53DW83dgFk7MeHNxmtDX
         JrTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWlhFm4hhUfavldSzrplbyiNOYKPKLfXmuCN90XpDzUgnLwlloz
	zu7gFGwMQ+x58QkqMR9xrg+OzNTrkzTMyhcsnfVD026X+L+XXaB5mCmU89hUJ/LOvOgNZyzT5Lb
	z5jRaZzRLhZR3SH4X/kwmTIoUqpl7A5rq/k/o88rcoR59XXAjWflYmqVvXoa2Noa9IA==
X-Received: by 2002:a9d:a76:: with SMTP id 109mr23749737otg.252.1560597446882;
        Sat, 15 Jun 2019 04:17:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC30YbKUczK/Uhl8X1lOT+RglgIi6qaWSqpNDKcEU82LGJoGrblA18eBvWTer18GZ5Kqop
X-Received: by 2002:a9d:a76:: with SMTP id 109mr23749682otg.252.1560597445664;
        Sat, 15 Jun 2019 04:17:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560597445; cv=none;
        d=google.com; s=arc-20160816;
        b=oiuObN2kk1oSPFwq/GxUUJMI3jlcCh8YozNhoSfIg4plmrY0Gmasn1aSrKg/S6dC1C
         zWRFLge00U2i5cNGcTTOAcf76tF+xI23IutNgBP+2OjcUn05EBXZZQC5I78SO0j/1hCZ
         mmCyueVr7yPAZOZIokNamzRuNTSWEU1fcGWjvfeqr31NC55WDa0U/cc1exDNe93qJPFM
         /FBS7Wfbw3+pshSCfHSFOpoXzn10u/GHNzTJs+bzDDARetMyheHXaOf073LwMA3QEY2v
         /ZxCqP2eh/J0eebJ6oGHm0yE6O9TKYBbJnnqQbUid8Ohv5+4x1Y8Ge6Scugyr3DBGghz
         +HcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=D4s3JSPvEUNvSV/fiVs5AxXLIEoYgFmz0uGEjvS+fI8=;
        b=JT2iztNyTea7RQUnGzgdc4MDTQFgRZfRnzI+OATczclG2XrZGuW1FTOC/TiYynrvIH
         O8XRObaZejDgoqCmVpJ//9R6c7NQADBiehZ1VrCAuWaYccGkX/JCw1WZoDlMRxtRfiEB
         Nx0PCFcKBGPmUwWmlJ2vR10chhdxtoTAMopdhJa6/J4DB0jaJTRBRsd+SEXmaSvFrfab
         ukjheu5Rcbxdqk+r8xnffIm4yMGWQ2HDbbwCWfUfx3KDQRw2Z+HmkGDSFM+hLhT2xKrq
         87uElV2PftUwiNwonus551agkJJGl5Rxezk0SEcTh4q1u7gX/lmT+iuR7En4MPxZBu55
         mjHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id z68si3788870ota.248.2019.06.15.04.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 04:17:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=xlpang@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TUENDtX_1560597424;
Received: from localhost(mailfrom:xlpang@linux.alibaba.com fp:SMTPD_---0TUENDtX_1560597424)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 15 Jun 2019 19:17:11 +0800
From: Xunlei Pang <xlpang@linux.alibaba.com>
To: Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] memcg: Ignore unprotected parent in mem_cgroup_protected()
Date: Sat, 15 Jun 2019 19:17:04 +0800
Message-Id: <20190615111704.63901-1-xlpang@linux.alibaba.com>
X-Mailer: git-send-email 2.14.4.44.g2045bb6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently memory.min|low implementation requires the whole
hierarchy has the settings, otherwise the protection will
be broken.

Our hierarchy is kind of like(memory.min value in brackets),

               root
                |
             docker(0)
              /    \
         c1(max)   c2(0)

Note that "docker" doesn't set memory.min. When kswapd runs,
mem_cgroup_protected() returns "0" emin for "c1" due to "0"
@parent_emin of "docker", as a result "c1" gets reclaimed.

But it's hard to maintain parent's "memory.min" when there're
uncertain protected children because only some important types
of containers need the protection.  Further, control tasks
belonging to parent constantly reproduce trivial memory which
should not be protected at all.  It makes sense to ignore
unprotected parent in this scenario to achieve the flexibility.

In order not to break previous hierarchical behaviour, only
ignore the parent when there's no protected ancestor upwards
the hierarchy.

Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
---
 include/linux/page_counter.h |  2 ++
 mm/memcontrol.c              |  5 +++++
 mm/page_counter.c            | 24 ++++++++++++++++++++++++
 3 files changed, 31 insertions(+)

diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index bab7e57f659b..aed7ed28b458 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -55,6 +55,8 @@ bool page_counter_try_charge(struct page_counter *counter,
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_set_min(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages);
+bool page_counter_has_min(struct page_counter *counter);
+bool page_counter_has_low(struct page_counter *counter);
 int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ca0bc6e6be13..f1dfa651f55d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5917,6 +5917,8 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 	if (parent == root)
 		goto exit;
 
+	if (!page_counter_has_min(&parent->memory))
+		goto elow;
 	parent_emin = READ_ONCE(parent->memory.emin);
 	emin = min(emin, parent_emin);
 	if (emin && parent_emin) {
@@ -5931,6 +5933,9 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 				   siblings_min_usage);
 	}
 
+elow:
+	if (!page_counter_has_low(&parent->memory))
+		goto exit;
 	parent_elow = READ_ONCE(parent->memory.elow);
 	elow = min(elow, parent_elow);
 	if (elow && parent_elow) {
diff --git a/mm/page_counter.c b/mm/page_counter.c
index de31470655f6..8c668eae2af5 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -202,6 +202,30 @@ int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages)
 	}
 }
 
+bool page_counter_has_min(struct page_counter *counter)
+{
+	struct page_counter *c;
+
+	for (c = counter; c; c = c->parent) {
+		if (counter->min)
+			return true;
+	}
+
+	return false;
+}
+
+bool page_counter_has_low(struct page_counter *counter)
+{
+	struct page_counter *c;
+
+	for (c = counter; c; c = c->parent) {
+		if (counter->low)
+			return true;
+	}
+
+	return false;
+}
+
 /**
  * page_counter_set_min - set the amount of protected memory
  * @counter: counter
-- 
2.14.4.44.g2045bb6

