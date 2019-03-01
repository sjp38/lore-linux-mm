Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF78C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:39:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B863218B0
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="osqhW6Yi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B863218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 974378E0004; Fri,  1 Mar 2019 02:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 922F98E0001; Fri,  1 Mar 2019 02:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E96F8E0004; Fri,  1 Mar 2019 02:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D73A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 02:39:15 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f6so12395975pgo.15
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 23:39:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=ifV3V9huHyD5u8TqmYIPKoWrC3WTwwBCy7SXCckE2ss=;
        b=LSduifj4A8yFHkZySABNaiYIWGZmCqysbGfM0gCVB0BdB/eZb/WyeDggjkF1lnux4F
         qTcjK2l/J/XxkIgbv5RH3eSp2efmzTo14PSC2P0NTx56eCrtLeJ8Z3YGhSb2LSuNBeYh
         FJm4MApopcpoCc0qT0kSXZIO33mZ81gko9KMbF9f2yDFhqQns8jQZzgw3AKprjcg0qFl
         b1rH02vd7phKYuoiueyisKFNmmpaYjSfSslilatJeLYerhM03h5ZP2ir7gWHLkJHkoOm
         WUOi2TacdAunewm8Thtjb/pE2HelB4YnHr+q+Ntt8PslBnpV50VA92VScpT7KdgxJtuI
         A6uw==
X-Gm-Message-State: APjAAAUL+pY+8/Vqh0ASlpBmCSaFUmpTK4lYvKe3duzjK8LDoRvf2pwu
	8yk2l1C2MMn5ppc4Xb+ywIom7vQGux3UMwuBkz8wZRYxWDm4baqFGzn0akK7qiuP7OfUHaMvbFf
	/wx3BLDzGIvXonXvNDMqSSgJaEGKd5HQxghuTdK08qK52+BFZBXxHkA8BILwWES11KY/BJ8lgs8
	1ZMNDcg/7+6e3WqPmnNXEYh+Pb26e4F0aHd+UKuQ73vnkgd9Ko7hkemzVD2Qqk+bvQwJ+zYt62+
	7KzEsKr7lGJcnZ05PprEjsEl6rwlUwmaOTfuz5rId/X4wjdvSpuUo/RLDF8D4P0+K5U4xti0aQu
	IkjwVcAYv+HQPXDkSbeCc2UepTK8odWxmfLg3hs96B7iaDPwtkwyW41EGcrcownOA7FlPfYNrVN
	V
X-Received: by 2002:a63:c948:: with SMTP id y8mr3562653pgg.263.1551425954800;
        Thu, 28 Feb 2019 23:39:14 -0800 (PST)
X-Received: by 2002:a63:c948:: with SMTP id y8mr3562590pgg.263.1551425953643;
        Thu, 28 Feb 2019 23:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551425953; cv=none;
        d=google.com; s=arc-20160816;
        b=tWIDcaxfAP6sH7peBXeZaCV5L9L07ff+KRBNCTbaZrE4fA+dpd9EwLlfJmGDDC53zV
         TrboN/OavGmhvEmgkw8WERwK8t1G5uzZrVIMattWELS1w74J2U8ihIurYxFtxLxMlwcP
         mqED6NfyqSel7E7C8KxyjwIKIb/EdfmymvZi6Gwb/T4FdvNjDXkbX9z0QsXy1mbxX/i7
         CqHUGw8nr6IuibqydgD+mWFpOnqo7jpVISm6jX5aPf98LaY4RV7DBnVvtTcyzK0QGysc
         bWq18mxvxp+7ySLh4gEeYuw9JxccfjjT+o/4IKSJSeMExBkwrmdT9p7IhilejZRvObYH
         /KBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=ifV3V9huHyD5u8TqmYIPKoWrC3WTwwBCy7SXCckE2ss=;
        b=gO0u4uvNCyl5xWPjJxjhGcfwe+eIWGwt2vyzruA+80MRTc65RxWEfXmzQGpoezfN8B
         UQOXmMpcGa/1F7tD54B9mKelYQVU/hkhNr0IJCxWmA7+o6VdipXMF9gOJBztc1/bMsyw
         cGxpc+u2l10hkbiHJbp353QVp9X2o5kw8soAngXZwKIqtYwi0IrwSpc7l+pYjjJrWXTO
         vSEczD0VpeBMj5SVEALRFjHHawNkuSTLSf39J6L/zyAHM7DTamCFtm6hG6c1AscZBGrp
         iNNO4RKEK/SEU2ZhRMiSY5ew8UsRqDzcZSGn2z8B2PH3zgXxh61iz+tBuwIODeuufH45
         sd3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=osqhW6Yi;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 18sor20739615pfi.49.2019.02.28.23.39.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 23:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=osqhW6Yi;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=ifV3V9huHyD5u8TqmYIPKoWrC3WTwwBCy7SXCckE2ss=;
        b=osqhW6YiRr3Sz+qMynvqndb8/UtqfH511IuNANtjrelzFFBLgoMa9cDUcvIedYrPSv
         11XwcCTMEiul4VCZYpTQzlB3e6lnFq4j15N01JfcopdwHq4IOVfw/qw1uURc4GbzpalF
         UBSrvjkorlLRWMlN3r2asBps94EyZHtVX4a++RJHT1iSPjC4CdFaMwpRHfI57vBWLrYj
         e4WU5NRte3y8Ru1DbqQnuWxzuiOKRVNgrxbrqLYliROQrT31MeyRfU7mj/xZZUrkooGR
         BjMGnkhFKtJ/acxME1oizYa11gfaUaC7BiTb+fWdXUw7wyDltwpt1c7tj2BQSE5NSF4R
         y4qA==
X-Google-Smtp-Source: AHgI3IZ5f5upbF4ffY82LgdGfdBJHfFqYs9Rm1k9djP4PaxH8SwT6ON3nwRmRw4S0U1p3BsE0qJscg==
X-Received: by 2002:a62:1e82:: with SMTP id e124mr4175052pfe.258.1551425953284;
        Thu, 28 Feb 2019 23:39:13 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id c3sm33455385pfg.53.2019.02.28.23.39.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 23:39:12 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: vbabka@suse.cz,
	mhocko@suse.com,
	jrdr.linux@gmail.com
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: vmscan: show zone type in kswapd tracepoints
Date: Fri,  1 Mar 2019 15:38:54 +0800
Message-Id: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we want to know the zone type, we have to check whether
CONFIG_ZONE_DMA, CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM are set or not,
that's not so convenient.

We'd better show the zone type directly.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..4c8880b 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -73,7 +73,10 @@
 		__entry->order	= order;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
+	TP_printk("nid=%d zid=%-8s order=%d",
+		__entry->nid,
+		__print_symbolic(__entry->zid, ZONE_TYPE),
+		__entry->order)
 );
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
@@ -96,9 +99,9 @@
 		__entry->gfp_flags	= gfp_flags;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
+	TP_printk("nid=%d zid=%-8s order=%d gfp_flags=%s",
 		__entry->nid,
-		__entry->zid,
+		__print_symbolic(__entry->zid, ZONE_TYPE),
 		__entry->order,
 		show_gfp_flags(__entry->gfp_flags))
 );
-- 
1.8.3.1

