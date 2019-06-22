Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D592C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D0252075E
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D0252075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E795D6B0003; Fri, 21 Jun 2019 20:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2ACC8E0002; Fri, 21 Jun 2019 20:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D66FC8E0001; Fri, 21 Jun 2019 20:20:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCC316B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:20:27 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id h4so12982079iol.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=6c7uHyt4YAjoLdZWT+yhkHs51uMPywRMfxp3vEnBHGU=;
        b=ktvzK9SIadcBXfLY31fSn+uhdrqMXBkqDATJdqvFMNVtAm93qj2OQ1uIr2BMZGeYPt
         Kq2pWAaYCDwsVZux+fONFLKPYPJgzQTV8NfiEwzLDZN6HH5eILXB2wIWDQQnaD/rBewK
         W6oF2Yy9uvcfjUyM4PxuqfYGmHlHMEirxk56us1PfMkHpy4ki1HqavKxOHXox8/tYMoZ
         HZWTdsmS6E9oTruM0yLcHEL6hiK/wUxoZfC79RzJgOsBxNwIlu0NmFiRCd58l+cr7MOg
         auCMHifOltz4ZVF4ESAAiWD8BIpeoHQT+S2tZG2AGM15H0Lr0lQJZf9ox1i0CbRhwgAW
         sXYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUNyeZtt4XIaepo/eDXbLB4RcZ/1ilF3ctUbIEHOS6jlkFptBoN
	IT+72s5/y41h2LyzN1rEFQ5fGf1EHuuyIRpCPMXuqLYZldrAI0luuEWQfDaMab+93vafC8PI0BU
	QlCw8/XTRiTyODdSyCNI5i70ff9QoEFb62vIHztlZmoQckRLWTcUD1+wgv5XHOYox5w==
X-Received: by 2002:a5e:db4b:: with SMTP id r11mr42942878iop.172.1561162827368;
        Fri, 21 Jun 2019 17:20:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2D2OyGPtqSBZJJN9ep4TB6Rrv7f5SSA9qq0v/Se5qNugbc+WCyrszcWjXFp/b9vYZwayq
X-Received: by 2002:a5e:db4b:: with SMTP id r11mr42942843iop.172.1561162826781;
        Fri, 21 Jun 2019 17:20:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561162826; cv=none;
        d=google.com; s=arc-20160816;
        b=unKclfigbIel9vYHhXfxZ/uIy9ZScoc3KNjoLoT/9/ivGZXFTj82+qSRmkyXg9xOJ8
         jo5rIRVMl6lp7WpMQy6k03mxmt48DJOW/kAnEvVJPsqqVMJ9NzfsFHjHUYrSaf8bzyly
         ansMkPVZikyqm/ZxGCMb/ZKndoYcn/ZyZJ3t2z2OfpXPpWn0Amsn9nBJ4gtseC+flwyQ
         apR2wRlkv27GzzYvhfN0NrcOoBZc3kLgmMGPc/ywQVUaTRb1T5GnCB1On5sdQX+usexJ
         LZz1krG7MgUXfMMizM28wLFcJHSME0QMl4xyVb5CuQ3zJDekPOnXyEBzKB7ayoPXEQSg
         If7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=6c7uHyt4YAjoLdZWT+yhkHs51uMPywRMfxp3vEnBHGU=;
        b=RfZlioVeNZS0Fvbz7+MOAEc6+COZNchOZvTMiKO5XMTs8ei+WunIGO8TLwwXFLrVFi
         SJ2a0zM/FVg45dBc4sAve6XNOmTX5/mlWmOo63skucqL+h1nvdam/KALeF22nPtsYSvI
         qlAxjPGTrUdeEWSXMHwLbPQBb8fwEzC2NklttqZtuykd3OPvuowmuDFYpdRNfdTBbMrR
         akxvGZ45CB6Ail5LRB5OsIKireFQTAfU6cGpU+aqitndDTQZkTEUq7LXUT+1OlM28MKR
         ZJT84QUm2dF4kxwPSNn82vGKC8r1sGmnlzSEc/3Z8C/B1C6EahSO3dXKaWru2RfQmaFH
         94cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id c23si5714118iom.72.2019.06.21.17.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:20:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TUrY3xA_1561162815;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUrY3xA_1561162815)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 22 Jun 2019 08:20:22 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent behavior for unmovable pages
Date: Sat, 22 Jun 2019 08:20:07 +0800
Message-Id: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Changelog
v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
      immediately by a separate patch (patch 1/2), and this is also the
      preparation for patch 2/2. For the details please see the commit
      log.  Per Vlastimil.
    * Not abort immediately if unmovable page is met. This should handle
      non-LRU movable pages and temporary off-LRU pages more friendly.
      Per Vlastimil and Michal Hocko.

Yang Shi (2):
      mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
      mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind

 mm/mempolicy.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 88 insertions(+), 32 deletions(-)

