Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 781D6C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD5720883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gwhl6Uyd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD5720883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35486B0274; Mon, 27 May 2019 07:53:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE5D26B0276; Mon, 27 May 2019 07:53:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D6096B0277; Mon, 27 May 2019 07:53:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6475E6B0274
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:53:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so1968171pgs.13
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:53:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=d5YLlCSOeCJr5dwjTVNc0c9xuTfOgnRmCoT1zoXFz1P2f0RHKPvLmkw9tu0ssTzxXJ
         xdBmJQkbmDtlyaT7diPJxQN4u7neFJDApqE2exP5rdIlyG/sD6eJX+13giuWmkSBLPzo
         lNFs4cCgNxH4SZh4PPut/jgLEPd05bV0iTwsqqmkKOZV5syD0xegUxmzY3FWdFUWQDPv
         HZpWgVN630UmK5cLAlCVBvfB+SJZPrgtCTm5WJEmYstQZ8FsbZpu2kG3vGryLAMN892r
         K5gcz1X9/PA6nLQcg8n5llVfEKeT6iltIiwFE2HBTR+a1T3Jb+3FsBZxzxun910jFxEY
         FLcQ==
X-Gm-Message-State: APjAAAWWYM+OxjS51AChOAaIrR1/y9NHbc3mpZku1EGkvzcnkTUfsRh7
	Iv2NR8nSie51mi8KzC+Z2GWjNIH7A8iNyXQtCWsrPBI6SLMa1kw/iPTxuGygpXIi1FQ37AMw9mW
	Z263+iM/kpXeSMM13/TO3lYXhXXk5ls0yFmU/ZFtIet2JTJT7EFhk15FVCLgkUyIMlA==
X-Received: by 2002:a62:2f87:: with SMTP id v129mr63103855pfv.9.1558958002067;
        Mon, 27 May 2019 04:53:22 -0700 (PDT)
X-Received: by 2002:a62:2f87:: with SMTP id v129mr63103794pfv.9.1558958001192;
        Mon, 27 May 2019 04:53:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558958001; cv=none;
        d=google.com; s=arc-20160816;
        b=e70oJZQUomwDdkQ3dNH0evF9+/Naf993Wd5Wv6NuWsP34tEhFdgZVfIQk39swWwV6k
         ZIvsghTVQBIjFHnAyxwYcyhmc5TFdVnVoFU7lkuhAjO3oFlic7S/OdYDrezTZJ0lJMxf
         XCiGEvJ562Y1JOs9+iWxl0oBeT7HdIQqF+yxeqIvunOFRFgyWtZ8I0b3ykTWlhBpT41B
         4bXcST1tXBc7OaeYNzuCrIHUBjubZTGH2FkvMejv1GK5zZbtp4a2ML4mv3jE4/bXfIyi
         LrpQzTvdzLaSxox06StYsY7GVY1rmkRILLAjzhB6CKhPE3BFtyToRrxgPWCPuyuBmfXJ
         GSQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=HyM0lqele2itxms1VtZ78mnkgGTUsvixCdLP7PeuRR9t9qNFSmbLeG3wmUqVvbZXlB
         u0EMu4MTT4fvl1IKWL0ldusj8/uoSNMVTUNL8RZLCXyn6pjwq+70BTPDs+t5SkGcFRzF
         o5lNtv+TzTvNU+TIubMqACB2cTHkD8hhaIEmQPylckPN4C6i5TKuT9vnvwiGJgZzCCXR
         Qx06e8Tu1tEq/5DfNR0hOYZAAwgi7DFcFp28Sm+gjqempj3JfcVxI6LUtSeFLeUOYkcM
         mBBu5ki8BcHzqCZS6pFrM4Xj+B3TF3HjTpuazqTDYTP4NjHI+lD3Jih63GpMlgrYS+lO
         jGmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gwhl6Uyd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t32sor6497219pgm.70.2019.05.27.04.53.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 04:53:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gwhl6Uyd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=Gwhl6UydUlKku/Zlw1lQSTiLSE/e98mws+wTcdKE/kaRNc88tiWPBk5wU/GKMuWU+Y
         9DT0c5USFh8LtLrcNMeJaBKwc2zdUKMgoQR0jcGrXOIGvlNqkfBbQST+HTt3taNRQJ8X
         FRFWBlDB92VrCFN1FgIcIVI8ipSHe6KOdz1JDwocpkAL6/csfFn3K2YhFm1YbWbq2XHc
         vZgcpHPBa9qXfi7Kv0DL9lalMPjz/uSChRVfAyp59giyxHZsjQoMpms4CUcqKjYTiY6r
         gzXSjNvYt8g2dSBzeXdjEsgyB/T6o3eAq2q2BLNOuOPna0bAjUC/SMEwWU3oSkvY5fiy
         3yxQ==
X-Google-Smtp-Source: APXvYqw6Yd2DOEHsp8jed4XQtl8xX+zGbjN4PxPFczeHI+r4qoT7Kj7vIKYyux6vLntpg7Mjg6X4Uw==
X-Received: by 2002:a65:51cb:: with SMTP id i11mr34733872pgq.390.1558958000941;
        Mon, 27 May 2019 04:53:20 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id e24sm9797738pgl.94.2019.05.27.04.53.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:53:20 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2 1/3] mm/vmstat: expose min_slab_pages in /proc/zoneinfo
Date: Mon, 27 May 2019 19:52:52 +0800
Message-Id: <1558957974-23341-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
References: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On one of our servers, we find the dentry is continuously growing
without shrinking. We're not sure whether that is because reclaimable
slab is still less than min_slab_pages.
So if we expose min_slab_pages, it would be easy to compare.

As we can set min_slab_ratio with sysctl, we should expose the effective
min_slab_pages to user as well.

That is same with min_unmapped_pages.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmstat.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d4933..bb76cfe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1549,7 +1549,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 				NR_VM_NUMA_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
+
+#ifdef CONFIG_NUMA
+		seq_printf(m, "\n      %-12s %lu", "min_slab",
+			   pgdat->min_slab_pages);
+		seq_printf(m, "\n      %-12s %lu", "min_unmapped",
+			   pgdat->min_unmapped_pages);
+#endif
 	}
+
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"
-- 
1.8.3.1

