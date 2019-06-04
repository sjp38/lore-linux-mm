Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 311EFC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03048263F6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03048263F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 809A56B0266; Mon,  3 Jun 2019 21:58:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BB426B0269; Mon,  3 Jun 2019 21:58:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8256B026A; Mon,  3 Jun 2019 21:58:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50AEA6B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 21:58:28 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s83so15304422iod.13
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 18:58:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=6Wo9ulrqd7q+3K7sRh3lbOdyz9EMsKshF5q7A5MI86E=;
        b=a8bTWteAYvCizWuiiJuv3GW04M4HGEgA14UQSEZlnTo2x62Vsc1pNKpDsqdSkibpD9
         th9s/D9SseHMP/+KxinYwtQno1Nqjkx7WC3fthO2ArZjPj4BA3GaQOgaLvLm352xXeUd
         4ZTUA3GJapOGg2qcdysc6javUEpwXBlD/7mrlyJKSHh0cFzEHMQ7E2rcQo3RTnJZYJFA
         6K2AJXCsOTnKNMzL6/fUYkw0gjxa0zE5eJ/rlxOk1Hu8hMHuAyEx1kKTh678CtZeA9RL
         u/6P0RsdFMEwUKyeyH2aNG/FJcticngz6LieurYdKMBJ2z7tbnxz35L1yFMj9jEE1k83
         pEKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVbmxD0bqL6ryHW6inUIOsW8Usxa5HxKkyBf3nAOGVXKcTNEiXA
	7qvA2h8DUCM3hZ1EFcwgPWNfMFAjOTdQtSw16KHRWTEmABm6tplNpDpH9/C1rNeCdQ46iRIpknE
	nLyaJWQdvV5pYP+Wj7YePH9SrK6Sj1QxVxQqs4qRfls7rjFm12UBdRWBVGuyvXl8AGA==
X-Received: by 2002:a5d:9d90:: with SMTP id 16mr1153617ion.132.1559613508102;
        Mon, 03 Jun 2019 18:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyp3HKsF8d4oE0nEZA/6ebASujIpvi4NAwRud5pDpG0hwdcaa2se6VRholxnWYukLDFvZq
X-Received: by 2002:a5d:9d90:: with SMTP id 16mr1153590ion.132.1559613507391;
        Mon, 03 Jun 2019 18:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559613507; cv=none;
        d=google.com; s=arc-20160816;
        b=pWMG5T5Ake8OR1ZeA3WPDVjhusTUYRRzAx7GQGNe/d6B5kGMQyD/SKvn+JLpTHD22s
         rPM5wwFxF7ThN6lt0p4FKqS2Tuig1xG3TMaxrEKanAg/1PgFsTa/ECJJsgKBkLAubkJ0
         +RQ7rf6YvkFZtqIUf6qalNj8n6ApCqX2esWX+NjxFb/KofUrN1P55cAWEwgrDt/mbDGw
         SkhBY8P4xQyCx6V85UGUWiJFxTUXYUn5RESu+XBfgb0XHjhUNpeOF2iP252dPIsD0MeV
         6sD4RhxP1G/ZyikXgg4/2xR2kg3vv4Oz+zu1JRFNXFKh/sdnTVDEV/8sQv6Yk9ckMtCp
         wN9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=6Wo9ulrqd7q+3K7sRh3lbOdyz9EMsKshF5q7A5MI86E=;
        b=oj2AtDVx668wAwVTVzbZQZKU4ld2n+3uJf8ANw6md5b04K4qEeIxd6ebWpc5FdSQ9Z
         LIdNyW3tyuvy+Co2l7Q+ekE1qw1tNHNTgXKlu16unq1EaHVwum49TlqOOFnNdWvHpkhb
         cSxwx0nN7Q0dJiBaMQCIhvFkUvtqueSDqLyEa4y0EvTV6VANwZ+1BdDg7jezQIQrQE0y
         D6HSheeja6gQ7h3fuJm/8lp2NITEhzIGvRlILF16w+CFg9CTSnI4/zCY8sXa0lXTbo+9
         x02tZPQbUZpZsuT/u0LMk3LfX8LmpND1ZykPAVK8Wp5M1K2CiybK1a7KVd0Aqn8FU5u9
         TNgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id l7si10034233iof.39.2019.06.03.18.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 18:58:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTN906a_1559613491;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TTN906a_1559613491)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 04 Jun 2019 09:58:11 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: linux-mm@kvack.org,
	cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Caspar Zhang <caspar@linux.alibaba.com>,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: [RFC PATCH 0/3] psi: support cgroup v1
Date: Tue,  4 Jun 2019 09:57:42 +0800
Message-Id: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently psi supports system-wide as well as cgroup2. Since most use
cases are still on cgroup v1, this patchset is trying to do such
support.

Joseph Qi (3):
  psi: make cgroup psi helpers public
  psi: cgroup v1 support
  psi: add cgroup v1 interfaces

 block/blk-throttle.c   | 10 +++++++
 include/linux/cgroup.h | 21 ++++++++++++++
 kernel/cgroup/cgroup.c | 33 +++++++++++----------
 kernel/sched/cpuacct.c | 10 +++++++
 kernel/sched/psi.c     | 65 ++++++++++++++++++++++++++++++++++++------
 mm/memcontrol.c        | 10 +++++++
 6 files changed, 125 insertions(+), 24 deletions(-)

-- 
2.19.1.856.g8858448bb

