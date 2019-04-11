Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60856C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12CFA2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:35:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZTb1EOoy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12CFA2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD4C86B000E; Thu, 11 Apr 2019 11:35:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A83EC6B0010; Thu, 11 Apr 2019 11:35:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 973E86B0266; Thu, 11 Apr 2019 11:35:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 504636B000E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:35:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id y7so4152477wrq.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:35:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=gzw9m7TOyzqmWbE+BZargCnE00pqGoUysBp7+VYaKE3J68QuQ5Ih6D71YrdG0IVMYr
         q6SI1TV/vwdKDOddYlpH2mI6vNtKkSEePo2CLRWtdb21HUDp+PvF5UczkktICf89GFDx
         qFovpqYxk4DjQSEmQpsq1zUjXU2qwvqjhjQFypB7taux2NaGSeSxNMbgR2oJh7BI3E6D
         0K/icWuo0CybMF05lxUf5zgDkAJkmgQgbZo023NIVOOa7OW4JwcASxTdPhMoHw21TGWj
         vdS/mbMqcdB6PmZ9cdG3TizVtXuHtLkxxLzpVzIw66sGQ8cmneK5Bn5Ced+ddw4s6FET
         S9lg==
X-Gm-Message-State: APjAAAUycTDu54FeEsu0TyRnOOgYvUg/jZQ6p3rCKQdKtro4JSrK+g2l
	VLPLcz7pYGYWJ1VFTxClrOYg3y56g5fWNN3ijm2TsMKziNhI1CCZvhi9G5/JhMQJ8xd5KOlq2av
	x7yVOHEZyYvxzVyrOz2XQa/+3poXO8cSxPDIIVDZW0/olaztIk8I6915Yz+LcbUOG1g==
X-Received: by 2002:a5d:6a8a:: with SMTP id s10mr33270179wru.66.1554996953814;
        Thu, 11 Apr 2019 08:35:53 -0700 (PDT)
X-Received: by 2002:a5d:6a8a:: with SMTP id s10mr33270108wru.66.1554996952699;
        Thu, 11 Apr 2019 08:35:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996952; cv=none;
        d=google.com; s=arc-20160816;
        b=yArcbHwA9tE5W4g22vW1GtvCAPlAM6bHH52QWm3l9sXIIAxOVuiPQP2ALQovLInqR6
         kxTlxD5HMMqFnqajynZ9qVTGIFCVcIgmHA6//mJyH1J6uXsrsPgN6zF9IH55NNdGFWkz
         P33OdXh6TaJdPtrgv4CJ7mKLb+v8fjAL4ZIKHeoJVR1M+LThbWvfuCH61tuNqPOSesIW
         sOoKy0VwrxhOr22QIH4/wV/mpZvyo7gzfp2j4C2h5FB2Z2AKDVn4uISEvdj1oRj/etHm
         ZbxWQ+y7M0V7csccvzIt3MtPzlryooM9x8WAyShnub/WLA9C8zl1LgUze5Opy/XZakvv
         j2Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=QPXSPo1JvqjuCCUBi9y5W+348+bnjNtSqug0Q8inBmrcwJ/3/IJ9gBJ7FWeWFAx7gj
         vwVuUQ8J3ZFoMSkuAPnEY6iNMtfT0whjsRuTt+qMCfJ4v5N8BAT5LcDu38bvexkDUd1L
         Ey4F+myG0Xvu/mpKIA2kJjgI+5wht0S71UXgzkyK7TNEz33CL2y/7wLf0HWrdm7z1VHK
         2DL+NBmdELkloMZWhujwUEWOcJc+bsBwLuWvFvUEscq8jYz89yErSsGleWyfUcuAPtn6
         YInd/z/bLlZUA++/xyxVBhdlrcSqLC+o5qGchsG19f/mzTQf8XUrYbHlzCFfUfBl9+AU
         WRwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZTb1EOoy;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor29268207wro.22.2019.04.11.08.35.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 08:35:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZTb1EOoy;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=ZTb1EOoyk2g0YosWNn4VcVrp37Q37OEm3YVArlwvPoQFaE1YLjccap5kzXUaRAtmIh
         iptk4qUXxUluaeBul5VtytYijzh5GrqUvh4aHjKLU4MbcHNab9IlXjLoRh84P/zFC8Q6
         QfkJJuVplNXhj6gFHj6tCAQLE1XiE6TI79mQaNPa5N4OsmBwId4hG2sG48LpcY7PgqDP
         7au/fLKxLOEJIwaiyvVYzqwEEhw4LQPRLrlVxZBA3uOqm/QXMaeFMdjO7BfsSGJ94Cox
         Fk9uKwaVDpqVdJStUt/WQBS/ZTDc2V60tVb9YN6NI6bMxrp8AzPcg6O0CJEAdaCIt8Cl
         5NCQ==
X-Google-Smtp-Source: APXvYqwdB4n0/82+wCQjWn8g2IEax8X5UaRW6x7ipGPP/Fo56zhXp7uZIX+UZNz9jOWSuzaFN8e2xg==
X-Received: by 2002:adf:db05:: with SMTP id s5mr33095860wri.247.1554996952020;
        Thu, 11 Apr 2019 08:35:52 -0700 (PDT)
Received: from ?IPv6:::1? (lan.nucleusys.com. [92.247.61.126])
        by smtp.gmail.com with ESMTPSA id 7sm130817888wrc.81.2019.04.11.08.35.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:35:51 -0700 (PDT)
Subject: [PATCH 2/4] z3fold: improve compression by extending search
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com,
 Dan Streetman <ddstreet@ieee.org>
References: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
Message-ID: <c1a85d7d-d372-6d8f-5bd1-8e124c335d6a@gmail.com>
Date: Thu, 11 Apr 2019 17:35:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current z3fold implementation only searches this CPU's page
lists for a fitting page to put a new object into. This patch adds
quick search for very well fitting pages (i. e. those having
exactly the required number of free space) on other CPUs too,
before allocating a new page for that object.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
  mm/z3fold.c | 36 ++++++++++++++++++++++++++++++++++++
  1 file changed, 36 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 7a59875d880c..29a4f1249bef 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -522,6 +522,42 @@ static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
  	}
  	put_cpu_ptr(pool->unbuddied);
  
+	if (!zhdr) {
+		int cpu;
+
+		/* look for _exact_ match on other cpus' lists */
+		for_each_online_cpu(cpu) {
+			struct list_head *l;
+
+			unbuddied = per_cpu_ptr(pool->unbuddied, cpu);
+			spin_lock(&pool->lock);
+			l = &unbuddied[chunks];
+
+			zhdr = list_first_entry_or_null(READ_ONCE(l),
+						struct z3fold_header, buddy);
+
+			if (!zhdr || !z3fold_page_trylock(zhdr)) {
+				spin_unlock(&pool->lock);
+				zhdr = NULL;
+				continue;
+			}
+			list_del_init(&zhdr->buddy);
+			zhdr->cpu = -1;
+			spin_unlock(&pool->lock);
+
+			page = virt_to_page(zhdr);
+			if (test_bit(NEEDS_COMPACTING, &page->private)) {
+				z3fold_page_unlock(zhdr);
+				zhdr = NULL;
+				if (can_sleep)
+					cond_resched();
+				continue;
+			}
+			kref_get(&zhdr->refcount);
+			break;
+		}
+	}
+
  	return zhdr;
  }
  
-- 
2.17.1

