Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08FE1C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3927218C3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3927218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4270E8E0004; Mon, 18 Feb 2019 03:20:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D6798E0001; Mon, 18 Feb 2019 03:20:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ECA78E0004; Mon, 18 Feb 2019 03:20:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4D6C8E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:20:54 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id d8so1742880lfa.23
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:20:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=omg8hblO925Iii/gNvq1uzTXkXSircScpfMUneW1bQM=;
        b=oH6476+jOoXmk9iwQuF6hF4WSeCfj6empqFpvFmpnITGonFW+AzpkYD5PKFVcP8U7w
         LqFPmbzqrIrSCNLasqsbSZY/zZGvno7cPVwBAit/xgh2AjHVslj0qN+MAk4z9l/I52IB
         qeJNIek4FsuB3d562064b9Kf/ZvfY9QOrvmoynG3kh8vH/bWnk8MmBCvyhvvuNfPhlAY
         UXf0FOnQH1QJcf4O2LA3nSJjTKrT6/ASqcpMd3Q6+kIKeqz/w3Z9Qj8sz8kJyn3LJUgZ
         bkV4/eWWBTxM+aLamRsP/NLNpEW6lkRv0iUEKmH131O7Lq3HvG44uryUuz8AN3Qc47rM
         Vpig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubei3O9pCJ1s7fUSD1zDQkTIjL0dKvFbLn4UTvV4fPX48okB2hO
	uu0l4uIKxZvqDCoh7AHB1rnyG4OW3I6p3UGiwCIm17S7WoDyvW7pUAGc7AMe5uRXWjDfJkPnAUg
	uiZpvOrhnKPoOWZCPI2/MJDzK/sU4Mt6UwDbBKU0+ee5cjlsGEk3Rda1vFlVUYEQXAw==
X-Received: by 2002:a2e:4504:: with SMTP id s4-v6mr13018196lja.165.1550478054135;
        Mon, 18 Feb 2019 00:20:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDk2/KHbhMIw+Hp04uSbwJaeSG40TL/c3Pxv3hubuS2MXG9/KOBgpXsYuvkKyFHnreJMfW
X-Received: by 2002:a2e:4504:: with SMTP id s4-v6mr13018132lja.165.1550478052873;
        Mon, 18 Feb 2019 00:20:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478052; cv=none;
        d=google.com; s=arc-20160816;
        b=duZK2efyotj63BKdFNoDoGg7phfg05XWcky5wtKkyxCR24Fy82XyfFg0XvK7EhSFMy
         LeATxHRPrz/8aWSTOHSzIRyS8S+UsGcgRw9GqrEnayDSwE5cHPgtDOeOUUWjpPn0czCZ
         nPxsEC7wi/uBhRQ684vUQaPPBNLDfTw8b2KcjYhMw8DUu5CPyhbU8eZZgTD8KnN4stDv
         hyrxyRt/U0Ghegsqk+z0hnHXzksHfvx5n5686T756sN3s3EcQjqpOMOSOHgvINBvwHUc
         8jLKSWCrE6dF/Sojn0FlTyRTc06RRFvOfdwjmCP1L1DQQIdbscyk94kQ5513P4ZpWIrq
         W19g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=omg8hblO925Iii/gNvq1uzTXkXSircScpfMUneW1bQM=;
        b=SV/tp73uy6JDGTGuvvA1lFjX+vbz1moJkr7nngTSTNquEOcHqCKU/hpjT5kizAjfnR
         BJl9NLisYzvZyH8MB2s/U2RxbOa1qGP7r+v5Dy/GaFbarnDs4VSKHQRG6RjMPN3S68Dn
         C/lgorGFwHC2KuNNOcibdeQ0rmG1gT3gdcLoVPRDOuPzMPf6w2bdf5MVaRBVRoOsWfkb
         H8othJezdAG6AOdKS+71DuxHOVFX/bn9sYJeV01IZTV6/0TgDnLg+/3eR8Ma/PFbq1vE
         68t2EkY+4z92VhVoEdJWOBUqc0yzPHcx/HithXJy+OPFxfpGF20EARkyLW1cJEPeBMxS
         i59g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id b73-v6si12301735ljf.24.2019.02.18.00.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:20:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveAO-0007pG-ME; Mon, 18 Feb 2019 11:20:44 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH v3 0/4] mm: Generalize putback functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Feb 2019 11:20:42 +0300
Message-ID: <155047790692.13111.18025172438615659583.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Functions putback_inactive_pages() and move_active_pages_to_lru()
are almost similar, so this patchset merges them in only function.

v3:   Replace list_del_init() with list_del()
v2.5: Update comment
v2:   Fix tracing. Return VM_BUG_ON() check on the old place. Improve spelling.

---

Kirill Tkhai (4):
      mm: Move recent_rotated pages calculation to shrink_inactive_list()
      mm: Move nr_deactivate accounting to shrink_active_list()
      mm: Remove pages_to_free argument of move_active_pages_to_lru()
      mm: Generalize putback scan functions


 .../trace/postprocess/trace-vmscan-postprocess.pl  |    7 +
 include/linux/vmstat.h                             |    2 
 include/trace/events/vmscan.h                      |   13 +-
 mm/vmscan.c                                        |  148 +++++++-------------
 4 files changed, 68 insertions(+), 102 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

