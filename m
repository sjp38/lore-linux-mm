Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82FD4C5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:23:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45D62206A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:23:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jcmOkzly"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45D62206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84116B0003; Tue,  2 Jul 2019 21:23:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0C988E0003; Tue,  2 Jul 2019 21:23:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BADE88E0001; Tue,  2 Jul 2019 21:23:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCDF6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 21:23:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id p14so411637plq.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 18:23:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=G2kFVbgsMrwZyePn3c84RhfhSwgLXLOi/Hitwd9W5qk=;
        b=Cr2XGCOLEWtsFuw+PM3GiJrrrmz0qQpmyNw5CMNA2IEBqsQTzbGryrA9lAdutAbiGi
         P399me0cVuSXZ4yksm0Sc4dYK28vH+R+QHO6bR57yxTSfCH8dKEmlNFPh9U54MO1Tz/x
         YHicK15sEYv0yFnAfJO7WDWfd3H+8Dk5kXVhDyMJDfUZ/2rdjzLknQJZ1Cv11EuIhVom
         iHxTQZT6OWmWFcZDB8AG8MTS8rWqLDQZVD2dwkGcwaZTaWivXgBXUbUOLMN2q54QqLwy
         8z/K9BuZGNBbRG2nM6g2OzhgDHaaV/wRefTVITa3Dn/MqsNNM2gcVqZlRT+d3PMcyNrI
         xLfw==
X-Gm-Message-State: APjAAAXDTVyId/KKbMBT8GQxsZ97onjuSAXAcW7eMgkigmyMrknccMrD
	IDsQ73fBbA3JupFyBpDNu/a0WTr/PBG1STzASLZsrrZC4B7IJZJ7UZtFUL8oaZOvFBYArHdR49S
	bcSPPmf4ug72qZLERY9zmPzxKNG/r11BFnSuh5zKhTm4dJW75r28kiB7Z5h0cB0KVZg==
X-Received: by 2002:a17:902:106:: with SMTP id 6mr39435920plb.64.1562116996146;
        Tue, 02 Jul 2019 18:23:16 -0700 (PDT)
X-Received: by 2002:a17:902:106:: with SMTP id 6mr39435867plb.64.1562116995506;
        Tue, 02 Jul 2019 18:23:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562116995; cv=none;
        d=google.com; s=arc-20160816;
        b=N9My8vNKHP3bxDMwrI8QzCXG5vR+taKtIyUTN0ZU0zepp4rnUypo9o++7FbEjKPQ1O
         fpN/JqpdPp0zo1fbKuMfYD9wNHaFEV5WdYbqjF5d+XXBBhSRsIgXydtwjenDXhgYBbU+
         WM5H10/9xgWMsAdwbENHsDTp1Xn3puyxetQ4OI58ymcp4WzYJ5pxWW1ZUWGvTGEtkiqi
         46MTStzZqo/eWQAopmH0nw89CK6ZinIzyWrGZH77UjBcqsDg5+tZ9dYHFsL+cdHJZgtW
         QiwS6KvBK2bGenBY3W/5RaqeOarddiQWaQqtPvwpxI5latWhuw6J6m6ortepeCL3xQzs
         grHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=G2kFVbgsMrwZyePn3c84RhfhSwgLXLOi/Hitwd9W5qk=;
        b=edR9Zmnpgb9euuq9oud+B8VisF7dMfpEXOtbmftKOsHDNfT5c03E+y9NpQl8mPvHmm
         w39IClHQ8ioms7tmO8Vn0aG3pZWNplqsv1PmCsCMEPOPeeOk6AhPVslFDt4WzOZuuIxk
         DctamhjUzv1zR0k94XYygQGMGdCeyGgx/Xzok+BpwmtOikVWmqbLagBeFUK6LVUomyem
         HQP7gmm7XLcNN/d3z8IZ/MOusCQxCLxETYI9LhD28G8/qAmwEiZJpZ8+8bxBGhjD+qtS
         JTb2bde5Sq0EMQ63pG8Ua0KluoDmSI6NRhKHq2cgk4gXgXGN6c/Kzs1fVgnG2lWzPy3l
         lrAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jcmOkzly;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor942608plb.21.2019.07.02.18.23.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 18:23:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jcmOkzly;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=G2kFVbgsMrwZyePn3c84RhfhSwgLXLOi/Hitwd9W5qk=;
        b=jcmOkzly9kbFSo8NsjyYhoMkuDZUPJp2xjWa/qwkA32kboZPIVATjD2xTB48kcKIDq
         4SQ4vMTkY+P6biW51Mt1xihSlcWZNNOqCg5IYhHpKadSQChmC8z1vvBph8UewTPvcRuq
         j60g4grw0RRq4cp10HBy9AzSvuArWP0PH9FhJU/zvKrflkYzSStKejyAYQMMA9JfcTlI
         wslKA6U4xDDcypy5lPHbUp17bMl0Fi87BneZo1DpnbDPFclYiO/LDglOsiJpD0PrPUd2
         04hbJnQaveMqy37vwHO0e2Y9ODaNYg07qwsFuFyWI80hyyQjKiFYNVN+AVQByyKmr+iu
         QVjA==
X-Google-Smtp-Source: APXvYqxmuJ9SVVOsuTL9CM8CPPgzspzYKYkuJh61i7TG96+uOrFt8Msdnyjfzy3vbCEYn10QE3j2UQ==
X-Received: by 2002:a17:902:59c8:: with SMTP id d8mr39706243plj.55.1562116995260;
        Tue, 02 Jul 2019 18:23:15 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id n19sm320222pfa.11.2019.07.02.18.23.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 18:23:14 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm/memcontrol: fix wrong statistics in memory.stat
Date: Wed,  3 Jul 2019 09:22:58 +0800
Message-Id: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we calculate total statistics for memcg1_stats and memcg1_events, we
use the the index 'i' in the for loop as the events index.
Actually we should use memcg1_stats[i] and memcg1_events[i] as the
events index.

Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/memcontrol.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3ee806b..2ad94d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
-			   (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
+			   (u64)memcg_page_state(memcg, memcg1_stats[i]) *
+			   PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
 		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
-			   (u64)memcg_events(memcg, i));
+			   (u64)memcg_events(memcg, memcg1_events[i]));
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
-- 
1.8.3.1

