Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC5EBC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 19:27:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 672C2206BA
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 19:27:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 672C2206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B7EC8E00A1; Wed,  9 Jan 2019 14:27:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16A128E0038; Wed,  9 Jan 2019 14:27:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009798E00A1; Wed,  9 Jan 2019 14:27:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B165C8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:27:40 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f9so4723798pgs.13
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:27:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=YvHbbFTQGKzu1yoPcOk6gELXGq0DpSPHtmrDxZOcDa4=;
        b=LsNVq0Ba5RnIHV0Ea8ZQr9erA2pbCh9LULKGtZ0GPTh1eajKV4lHdk7E0SYPiB6BMl
         ekOqcB7DZrusDlLYC8UmlQLtTSm9vRck7AKBx61mIK08P2UTWT0150vgDvAma7N4zJLS
         R2h3T/xNC1kWjrzWRibIx9l7WnBtqQ9UMQE5icmD3pFs15opqIbhvLHs3ivvO8ssJemU
         wpd5abkZT1+AennENbA4calau4jg+nCrjuwhMhoFBzAEqoj6ninpKV236fr2WVpHNdgP
         ifJjfTZ2wi6r2VzVW5FwhUbH6Ui5jrm8R80HxCliydcRnk4kW+hQR33YdhH5C4UkylmG
         VsbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukdH4M2JAfw0RNnMAeZEnm/M8V76d0nO1c+cvZR/xSclDzCWnoc1
	I25vixIM0Bu7T51KwyxQhB06oa2erB8Tnoabt+TicLCO8iqZOdfDM3FpeVQgGPKJogG0A02sNH0
	Q3F3AieDPuUiMnqsCapx95ycm9RuHbkKQ6yL6O8ZyKi63ad9xJ0t3eWNWrnNW9L3npw==
X-Received: by 2002:a63:f844:: with SMTP id v4mr6554405pgj.82.1547062060359;
        Wed, 09 Jan 2019 11:27:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+URTajkmDU2T74IU6TAb7wm8vDXipKCyr0jJMM0fxN6opty+8UKXPo3fNE5ixc47zwKNM
X-Received: by 2002:a63:f844:: with SMTP id v4mr6554350pgj.82.1547062059156;
        Wed, 09 Jan 2019 11:27:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547062059; cv=none;
        d=google.com; s=arc-20160816;
        b=JhQKx6eM44jJK1OIi6zj/HUppfttn1HYe1fOrVSIKBqz/tTYfZOw0npZ1u2NkpBdm6
         HmeD2LLbaLAS+PlB86y75byydUE0/HTNlOHFDXvq7sy2HdrqizVvqbnMG5sEOH26Q1XR
         al+dkzx91ngAUkUO9ZFn+uLMA4qgXGbTGizkgHW6fo65RLEid/ENGu3kzQndWn2cWIqV
         CqmrStEA3zNWhIW2KmlLPcxNzEHe4LFG64LfXfGqsAOOCDNwXjBBpUDBt07/U50V45Ci
         TQerzAjIECxm+LWb2TDeaXPESlPkF9Su0nQYG9CIF111xPXY7RBIXaVv887Zk+7up9Rs
         29EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=YvHbbFTQGKzu1yoPcOk6gELXGq0DpSPHtmrDxZOcDa4=;
        b=OIhLVUFWnoOkRVbangY6fm5/UWvtfme/PmhT3YNIO7EPMBun+bMfd/B4mz1Blq4Fl8
         k7boqf0PKp1oOkFJUl10C25OZUFVYlLji/J/JqlHqb6o3wHL4ka27b7HkTglwq8zy22g
         OmNAPgAuSaq7NHR/OOC0GP3ZTtVwI9YJLDZ6rKgUac+8Q0EuGjlvnuQcwdLqJyd2pDUf
         LefN2q4MMuyr17RA3Is++fDtA74E0DSXI6LtgMX6t7Jae1sbBrUD9DSzsKMLIpLhExCx
         NpoBYZI4a+0UUgYiwQWf9upNwnUCeG2mU/Ntd2H5iTAtYzQ6Xl0nSEmrMDTqoz68V2Cm
         1TRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id f24si10448757pgj.315.2019.01.09.11.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 11:27:38 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R231e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0THtvvDg_1547061291;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0THtvvDg_1547061291)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 10 Jan 2019 03:14:59 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	hannes@cmpxchg.org,
	shakeelb@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 5/5] doc: memcontrol: add description for wipe_on_offline
Date: Thu, 10 Jan 2019 03:14:45 +0800
Message-Id: <1547061285-100329-6-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190109191445.yNhtP8uJvihoSx2W5DfU34mdqnm6tt_8bZFkuPNJ3eA@z>

Add desprition of wipe_on_offline interface in cgroup documents.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/admin-guide/cgroup-v2.rst |  9 +++++++++
 Documentation/cgroup-v1/memory.txt      | 10 ++++++++++
 2 files changed, 19 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 0290c65..e4ef08c 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1303,6 +1303,15 @@ PAGE_SIZE multiple when read back.
         memory pressure happens. If you want to avoid that, force_empty will be
         useful.
 
+  memory.wipe_on_offline
+
+        This is similar to force_empty, but it just does memory reclaim
+        asynchronously in css offline kworker.
+
+        Writing into 1 will enable it, disable it by writing into 0.
+
+        It would reclaim as much as possible memory just as what force_empty does.
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index 8e2cb1d..1c6e1ca 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
  memory.stat			 # show various statistics
  memory.use_hierarchy		 # set/show hierarchical account enabled
  memory.force_empty		 # trigger forced page reclaim
+ memory.wipe_on_offline		 # trigger forced page reclaim when offlining
  memory.pressure_level		 # set memory pressure notifications
  memory.swappiness		 # set/show swappiness parameter of vmscan
 				 (See sysctl's vm.swappiness)
@@ -581,6 +582,15 @@ hierarchical_<counter>=<counter pages> N0=<node 0 pages> N1=<node 1 pages> ...
 
 The "total" count is sum of file + anon + unevictable.
 
+5.7 wipe_on_offline
+
+This is similar to force_empty, but it just does memory reclaim asynchronously
+in css offline kworker.
+
+Writing into 1 will enable it, disable it by writing into 0.
+
+It would reclaim as much as possible memory just as what force_empty does.
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.8.3.1

