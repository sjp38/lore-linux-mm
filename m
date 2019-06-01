Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D9BC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C5CC23AC9
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PIAJLMrq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C5CC23AC9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F7CB6B026B; Sat,  1 Jun 2019 09:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8CB6B026C; Sat,  1 Jun 2019 09:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34A436B026D; Sat,  1 Jun 2019 09:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE3AC6B026B
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7so9571064pfq.15
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lwmEoo237hXBLfm/gooPZnZBnsu0PJI0BS6iqECl89Y=;
        b=CaMS4I5bnhI7YnCTGsd1OWnMQR6HPDrOauFjHE9XwYciCn3Dnjt7TeLjw1cNlVvt9J
         LcA8N9Y1IixuyqSoVnxt9cLmUI10ImETajHzLU/5C7vk9doH6plcym4tB14TadlezhqS
         7mbWOG0UnP6i9/JAQNeHqI1YVdhhQYYY0JV4zukwBpgMGFDLZLbNKYbc+c5MErr3wUcm
         M3VWdXdG6AOvNFV+s81+D9UQCdRjxsMwosqmC1C9bekLhAut2m9mCTnEGST8lsZkLCrf
         d67d8NOHKLI7wJBfU5zJSQAIvdZsMXW9Mg8c6h+F1Dej0pshDONfrtCOa46DS2WvrJC9
         3Dkw==
X-Gm-Message-State: APjAAAUB/cWex7pwxub1o8AgK7FmqiaeA61y7STpknzoo24stdG6+YLF
	Iaue9RCMBu9vVk2Uz4s8G8JDi0jv06YqwvIQxdavzkwKCwdG+Y1ypuDvjX0TUmnGFluNZX1H/cw
	MySvSmdugXQ7bX27Zru57GsAy9HxnygFJ3LdgcppcfI0otjK1cZPCTXeFpbIeMtKG0g==
X-Received: by 2002:a17:90a:c38a:: with SMTP id h10mr16087567pjt.124.1559395067589;
        Sat, 01 Jun 2019 06:17:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxcoPEj2IGCWydCn/7f21Y/A0J4ts8GphGAd42hju0Ooh5BqbHEeudFWt3sSpBHHkpMQan
X-Received: by 2002:a17:90a:c38a:: with SMTP id h10mr16087495pjt.124.1559395066870;
        Sat, 01 Jun 2019 06:17:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395066; cv=none;
        d=google.com; s=arc-20160816;
        b=hxj+dJUCdJqE0MU2DOTlQNkT5D+QjKrqorvybzupFbvRrdzkxn059I3L+EFH0VBAT2
         Pkl8V2ThchW/KM2C2dcbLC8i8Da8srQR5jlk53oZ94uZb5Lh2g0iZW5Tgx3D7DQ4sS+T
         FpgTQuHgKkomqiiMp2pAHrEXz8bQozDSh/Fkjf9blnAfb0Zl/GoQKjRpGxHw41YoXta9
         3gMlMcKfEedyFWDdcRRmJEdgrL/a18oJwQPeyrCclSP8aUkpOoVooqvso+Ri/hmj5n9R
         Ei07Azz6/zPUP0ZylIlIIZguOws71K70bTP2lEnsloxFrSiaFT9WLB5mwDJ+AZAJOSND
         lX5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lwmEoo237hXBLfm/gooPZnZBnsu0PJI0BS6iqECl89Y=;
        b=NWzNBpu3ZFAd12rRBoywdNZyXmnUhCK7Mqu+HlYoj6mpnJ+cUDmyNxym4oj23z+E+c
         5McjmDIODIsMD1Tz0X6O5TyE8+7SoJ/ebBXTWRJrfB/xUhqunQBHL76+V1pfOpbAH/Mo
         IKEjiZwMUvCLjPFIHwIGTBf8/3N5jqDMRh52KsFvyiZ2E2QOeUvoiRUa7RAtK0aGHMTc
         D2Kws8Ms4aegyYrZC8EpDPHxJe8xV98paBKlR5cVrPCp/+P9DpsT4/SVYuunfc7ZcNYJ
         79mv+fem7c3i5VCqf+6Zve9d/E54PD3NJTLyybaq1VdUar3/pqepIYYbxQy677Z/tehe
         KnwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PIAJLMrq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 91si11159772plh.398.2019.06.01.06.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PIAJLMrq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9E3E22569E;
	Sat,  1 Jun 2019 13:17:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395066;
	bh=SKeFZxLlJJEe28gVBbpYOeHuIKrn5SXSvLw4bDj5xSs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PIAJLMrqXO9fV6XF4DxT8NsqjxvNxdDm4szh7RUueQN2p+OUWJOay3OaEdcZA9X4N
	 0aNZcqx7Crw5EtqBRYtGOYIRok0QAcC9DnyaKU2ZufxW3oz3t7DiN2RV5NL8R9CQ2A
	 /LqzE2boG0UYW2tfsyfkVzYMI5q6+2Wxo5bJISfo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 017/186] mm/compaction.c: fix an undefined behaviour
Date: Sat,  1 Jun 2019 09:13:53 -0400
Message-Id: <20190601131653.24205-17-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit dd7ef7bd14640f11763b54f55131000165f48321 ]

In a low-memory situation, cc->fast_search_fail can keep increasing as it
is unable to find an available page to isolate in
fast_isolate_freepages().  As the result, it could trigger an error below,
so just compare with the maximum bits can be shifted first.

UBSAN: Undefined behaviour in mm/compaction.c:1160:30
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
W    L    5.0.0+ #17
Call trace:
 dump_backtrace+0x0/0x450
 show_stack+0x20/0x2c
 dump_stack+0xc8/0x14c
 __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
 compaction_alloc+0x2344/0x2484
 unmap_and_move+0xdc/0x1dbc
 migrate_pages+0x274/0x1310
 compact_zone+0x26ec/0x43bc
 kcompactd+0x15b8/0x1a24
 kthread+0x374/0x390
 ret_from_fork+0x10/0x18

[akpm@linux-foundation.org: code cleanup]
Link: http://lkml.kernel.org/r/20190320203338.53367-1-cai@lca.pw
Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 444029da4e9d8..7b48ac9164a89 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1164,7 +1164,9 @@ static bool suitable_migration_target(struct compact_control *cc,
 static inline unsigned int
 freelist_scan_limit(struct compact_control *cc)
 {
-	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
+	unsigned short shift = BITS_PER_LONG - 1;
+
+	return (COMPACT_CLUSTER_MAX >> min(shift, cc->fast_search_fail)) + 1;
 }
 
 /*
-- 
2.20.1

