Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7ED7C28EB2
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B36D20866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gMZWUftQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B36D20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32DAB6B0010; Thu,  6 Jun 2019 06:15:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DDD66B0266; Thu,  6 Jun 2019 06:15:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F5A56B0269; Thu,  6 Jun 2019 06:15:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC4C76B0010
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:15:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so289292pfk.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=iC7IvtN4NDCekairGwv/3Djq2q1362Qy2AwvFRN/5YY=;
        b=icTzxff4PhwlkRP/WKEKTIV5ixEcSQa8r8PYrHNUj2EWvUEZpY0PkCwGMCRnhMVFs0
         tYvr79tcR2lELmPwQflU8XRwKgJUrlll9H/zUtTSGwjGq1dTt5H1G9Ju9WlGMIicl5ry
         SFShfm65pGehJbPDdUPUbiHNv6b8QgeQYFU3KIvaIaj7+0CsaW1UPwNO+vVZiFZ0ahZu
         ceqmaxC3PRubZ6Ip9+Qx+cSv2Jx3HBg8yQ66A1cKzDa8aKH/vSVsqDZ4nsVV2X62K338
         jRx3rJuAflOX3Dqj0jez9WDYs3xYpyg7NNFIYVcKcWhwNQgfYmGDNJKs6zhEOda6wC35
         qbZg==
X-Gm-Message-State: APjAAAVfjGJyH49MBITVADY5awvKSJUG10Eu/ydNQHUtrJWANsP7mLR5
	iv3Ygdste5kI1F60rxEK3ihlsCY26PVrLF23UvO0WVKd/E/mYwOPQ81WFm6x45MNtDUtQr0lKPN
	eTDfzaUZKMF3scSsxcWh7TTAzPJfL3xx8z2AMB8hhcbSQygqS6jKzjY42uGFdlfLFOw==
X-Received: by 2002:a65:5304:: with SMTP id m4mr2655001pgq.126.1559816119185;
        Thu, 06 Jun 2019 03:15:19 -0700 (PDT)
X-Received: by 2002:a65:5304:: with SMTP id m4mr2654903pgq.126.1559816118015;
        Thu, 06 Jun 2019 03:15:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559816118; cv=none;
        d=google.com; s=arc-20160816;
        b=EAAQvzXKoJHPXXSJVWU4QNlWzrXHIr+f/NTDjLncMsXr7WZcmG6KnW3OddbYoaOokD
         16hk5htP73s6473IezBDjqT4euTJbV4JeibqbRBhiJiafylRQthI9MZYl617YpK2OkVL
         XM8LDLoyoRNDSNyj6xOFK6aKFDXG8vpvfnXjqwW4ZfNvaEGr9aus8aOI/ers9tT6bpoY
         ohwTD7zVUHeLTi/1FH8s7mQAuJpDVvlgWZslsWJPFQTEvz9iHLNZ+qDwY7n31KVJ2k9N
         i89SrMZfTkMK9w8p2FkgdIUS+kuINYUg7w/nFmHMtGFRdsw6Mqs58R5NsH7KNgZ4LQ2s
         AhYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=iC7IvtN4NDCekairGwv/3Djq2q1362Qy2AwvFRN/5YY=;
        b=g+XQ9LMNN94WEzx91TcBJ62IfPHXMKEhZQbWpx0dUatCHB0D5nVgiBmikQkAQ39ekP
         24AiOQvzP1J+2AXdVCKAz5U+MDglDP4zJAhxQNB5Xzmn04EOVWdhfDM0a74wViPJkwqD
         z9/IXyxQA73JpoN155bDWSfy3qLf2gpNfahEE5wUhcgLT8cXQMHMre6lPe8Rqr6wwqhG
         Wj4sCqxEibMn82IBXfmtVUW+UXZrAEmbLw0vvO6+y3cs5r203RhArITyTKUsOAdtp0Ag
         GKFqIdE36YwGA+kYrfPWw5LKb/7JUfGEa803jRhxv5ULrxxch94NbhFRHNAPE86mZUsg
         Gtig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gMZWUftQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor1409720plt.10.2019.06.06.03.15.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 03:15:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gMZWUftQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=iC7IvtN4NDCekairGwv/3Djq2q1362Qy2AwvFRN/5YY=;
        b=gMZWUftQlfmpgzqStlcNNCulcRTf8QMFFt20jXwOLapLbmxkUrSmDWNSPVC7Amf7ni
         3V+gjJ5tAEXTmkmvpyw63wliVPYrRZ3Ky8YyhPCrKlzAdJVFrCrF/uUCXyHuDeX5ScOF
         RuBp32EY6fq1CCye1kKTqf2hHOmd61Oxq4eibffL/nCuLcfqlDUsdZOvVO2oQaFgnbhm
         OXUOaeYl0ArW+9GtHpwCQGeqdX5YpIKNSO6yx6XHG7MpPJgt1BD8z5XLqTtv0d1L9t0T
         bZF8uYWtpK7+IpSa+CvWasIDyKyC54Dx9pJB69wOJ1HH5cQL20UyDNcTxhkHWKmUDyoz
         ry3g==
X-Google-Smtp-Source: APXvYqzPQuNQCuseJiQ7kbmP2jXJ70zcwJGhguUmqchqJI3A3dfuByA/3XsAq2oLJkAOg1x/6RrJwA==
X-Received: by 2002:a17:902:e85:: with SMTP id 5mr10506374plx.202.1559816117788;
        Thu, 06 Jun 2019 03:15:17 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id z68sm1895829pfb.37.2019.06.06.03.15.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 03:15:17 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	linux.bhar@gmail.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v4 1/3] mm/vmstat: expose min_slab_pages in /proc/zoneinfo
Date: Thu,  6 Jun 2019 18:14:38 +0800
Message-Id: <1559816080-26405-2-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
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
in_slab_pages to user as well.

That is same with min_unmapped_pages.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmstat.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16c..2e1c608 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1550,7 +1550,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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

