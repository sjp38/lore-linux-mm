Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F93FC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:05:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2CB520850
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:05:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="yNMwW5Ib"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2CB520850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323396B0266; Tue,  9 Apr 2019 13:05:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D2CE6B0269; Tue,  9 Apr 2019 13:05:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1770E6B026A; Tue,  9 Apr 2019 13:05:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A078C6B0266
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 13:05:45 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id v4so2488899lfi.17
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 10:05:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=v9DyRz/rUCB+286erOd3GH561hgvacNMYfA2ZmmTxzI=;
        b=E4DOR/lmw752/YDLddAaTfBqdLN63YIgD+PEXTBKX0Wl9I0VbsUSoro73ocdF7cNWP
         cX2Pro22jhefZq7C278FKHru/u41S5mw+mEeB7qDBZvyOITzSlDgXjz1kXLfdbf64Jb/
         D/qoR4/BGJRpB77PLpu+ajIxfb0Ad2V+59GT9gDhO6yPdgOADjZvSGgs+F2ZcZWvQA5U
         658tE4hkpdez5vFhQJ/zRT9b3nSFnzJ910rqGCi0FnFEVn1D2eyimPfQWA5LKA40+OG7
         hxsuRHRPJTsy4r+RlY3JhPJmaehOVavPLfivNh2yLPYmG1mVt/VqodHk4AYvSn0e3p6R
         FNcg==
X-Gm-Message-State: APjAAAVDuQXMECJ/aFYBzwg4NIbyX+6lwM1ETuqOMqntpku2dY+VBOBj
	pwfcX8+Re6KuXlPwBiGdvyEQL2ttVwjt58Bod+pujdK7MhRTGKMbngSCvNoYXAd1pNYK4QDRxkx
	6dE0PLWdL5gx7q5IVQuFlQ040A7reAI1byw0493GaGO4aGx3U0wkOFviiz/x9x3/tAw==
X-Received: by 2002:ac2:5501:: with SMTP id j1mr19629241lfk.113.1554829544772;
        Tue, 09 Apr 2019 10:05:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzK/qj1VlJ2bhQozUdQP3Qa28vvWKtcWOj5LhYdWAjvDrnmjByPnWZQ6+mDkBqVIJRu+6sl
X-Received: by 2002:ac2:5501:: with SMTP id j1mr19629192lfk.113.1554829543429;
        Tue, 09 Apr 2019 10:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554829543; cv=none;
        d=google.com; s=arc-20160816;
        b=eebBmIoecPNBBBiAgjJoOIvH721a1nxJzNweaSuhILYIGV3maFbRmCKpq0huFQR43G
         U3V9UGV3wVAWAj+N6HUDfadw4Zx08QL0QTDQZyHow6RmlkmXkqZ3MZ+smhQMZiE4hpoQ
         +DDd65/nT4qVy3O5iy6sn7z8+924NIURWRH0okN1lScjsEdUnxD7uyxK22F8Co81qS55
         1SB+hB0KeieeVz/5Ttx7aN6BOuoc720LvCcksLzC3+YTJiV6lZ30cQ1pzeP5EmLO/EFe
         EaU5j3rwmjRszk9KUFmNo6Tfq0msibYGQuLKmQDZx2BCol8HaMZexNcveSTjuCcaGKeu
         spvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=v9DyRz/rUCB+286erOd3GH561hgvacNMYfA2ZmmTxzI=;
        b=cSF055zhtae42RgygzCvptal6JcdYEIjLhwhqTXkKHJFlrUDR3aD+/UGM+3389u118
         HmVNLxMMdNr3Q5ep70t5uGx9/nd94X1Ij647+mZB7KOWBCQapft4H0VVAVr0xqLS+wNt
         uMdwnNkN/5AChhR5oOJIopilIjqtY62wbZduSk/V6ldCfVwJBU5BbiCaKRddd5CU42+8
         twjogfAdF61EMyyHjUpSg2rvj7rB4wHWz/EUYk8dJ9fReDUXxnWEWSwmq9IshgYsFZGB
         TOA9r9nmDgFF1l/IzTrHforcCnwvlk1oghlsl0IVGzkeAqjL+Yt6Ifldf+fg1a58ehlR
         dRkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yNMwW5Ib;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id f2si7718420lfk.119.2019.04.09.10.05.42
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 10:05:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=yNMwW5Ib;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 87BE32E143B;
	Tue,  9 Apr 2019 20:05:42 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id lSneN5YZxL-5fMqdvtJ;
	Tue, 09 Apr 2019 20:05:42 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554829542; bh=v9DyRz/rUCB+286erOd3GH561hgvacNMYfA2ZmmTxzI=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=yNMwW5Ibo3YUY6aDmKxpbHs0zh9l3Ia+C1cBwJEm+b/Ntk2Zf8sjZUxrYYgofiidO
	 jW1nn5VcJduSisN7XC/iNSuGRmezIMEz/HEr7YWubNchVeGns2Koputi+0hzQiQNp6
	 44NIvUwensr4KtnrgasyDh3sZQK8s6tprC+1kzYk=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f5ec:9361:ed45:768f])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id GX2E9pKdXZ-5f0KLW23;
	Tue, 09 Apr 2019 20:05:41 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 4.19.y 1/2] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>,
 Vlastimil Babka <vbabka@suse.cz>
Date: Tue, 09 Apr 2019 20:05:41 +0300
Message-ID: <155482954165.2823.13770062042177591566.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>

[ commit c29f9010a35604047f96a7e9d6cbabfa36d996d1 from 4.14.y ]

Yongqin reported that /proc/zoneinfo format is broken in 4.14
due to commit 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable
in /proc/vmstat")

Node 0, zone      DMA
  per-node stats
      nr_inactive_anon 403
      nr_active_anon 89123
      nr_inactive_file 128887
      nr_active_file 47377
      nr_unevictable 2053
      nr_slab_reclaimable 7510
      nr_slab_unreclaimable 10775
      nr_isolated_anon 0
      nr_isolated_file 0
      <...>
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   6022
      nr_written   5985
                   74240
      ^^^^^^^^^^
  pages free     131656

The problem is caused by the nr_indirectly_reclaimable counter,
which is hidden from the /proc/vmstat, but not from the
/proc/zoneinfo. Let's fix this inconsistency and hide the
counter from /proc/zoneinfo exactly as from /proc/vmstat.

BTW, in 4.19+ the counter has been renamed and exported by
the commit b29940c1abd7 ("mm: rename and change semantics of
nr_indirectly_reclaimable_bytes"), so there is no such a problem
anymore.

Cc: <stable@vger.kernel.org> # 4.19.y
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmstat.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 72ef3936d15d..7b8937cb2876 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1550,6 +1550,10 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	if (is_zone_first_populated(pgdat, zone)) {
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+			/* Skip hidden vmstat items. */
+			if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+					 NR_VM_NUMA_STAT_ITEMS] == '\0')
+				continue;
 			seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 				NR_VM_NUMA_STAT_ITEMS],

