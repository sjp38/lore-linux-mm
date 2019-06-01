Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1333C46460
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A1EA27298
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="o5wRMSJr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A1EA27298
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A011C6B0273; Sat,  1 Jun 2019 09:18:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2CF6B0274; Sat,  1 Jun 2019 09:18:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82C6F6B0276; Sat,  1 Jun 2019 09:18:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 429DD6B0273
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:18:00 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d7so6555640pgc.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:18:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QQBIfERgasWv0rgmG/hw/sJXFl7FGxnQifs+UbhRNA8=;
        b=IzDpqNE96GQu9JL7DibS/G9fSTu+eOmeumk+0GydCVWbDjcB34cwBWffIZTDSCz3RI
         Ol5umrtcxclfG6BKklyCgPRUftFAY+NrK14j2yHoSPLiUcwg191Z4qq1rBH6Vb1j+Wbw
         c30guZxPLFBgA5eTEM9g7p1px9EcDvS0ZUPBIBs1Sg8A2ELC44Ckp312xhko03tCFq1B
         xrreu90BsF/I23vjMoU63QRk1qiAd8+4mRXIB+GC0N0hlU6eXDTmafPuEV+OobG1Iftp
         Iykaw0LOnHvNqL1NXZ4NCmuPGTIT7SwTn6jytnpLOFi5iwe44sOOhPMYbBgj6FbvkllL
         fUCQ==
X-Gm-Message-State: APjAAAUIvOcdDa2F70c9eMq9XRHI0e+aqDFrIpimaceK92EzjGRuZOIA
	qvjSEiapymKgX222QAwn0hOZM7GtQo+d5R1TNrzEVTCIRzhOqJXKJlDsNhOrOciQg4WZwBycI2a
	1HIMxBEGL5oibo3IBYS5x3BEXlo1Q22vCxRPoJDSmVEa0rS34A2t08MFoJlLcBlKZgw==
X-Received: by 2002:a17:90a:35c:: with SMTP id 28mr15497816pjf.110.1559395079930;
        Sat, 01 Jun 2019 06:17:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw80jFPY2MjgLUeUa6CH1bNbArvSdc1kiLkGDOHo212EcyvKlu2CheX4bAzz6V36bc29CR5
X-Received: by 2002:a17:90a:35c:: with SMTP id 28mr15497737pjf.110.1559395079205;
        Sat, 01 Jun 2019 06:17:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395079; cv=none;
        d=google.com; s=arc-20160816;
        b=nAc6OhptXeXMeOk6Js9Jqzt+8GJWt6e83UV23E9BGxS2eqwed06d0/15SjVjLsYyi9
         GwYFUCh5ZG12wZOnK6DKtKvuaEoe8y6nC1IgjDUDIcsGxmvGsJRzXg0Fc6npKVU8CtfV
         0Iwi+LA+lX9HxdcUpQMFoQC7wzna2s9xIvY2k910nZRiZrBziwkS43YAFBWDZM1kdzXJ
         opJRh8ikGuHChPG4NMEjqXHEdPqII1k/JwNRK1GuxFfVPz0Zr4t1cBqJzVuqBCEJNIHV
         8BkWga7WUekTg2djkqyZtx25TrKAGlQsnWquO/QWuZZS5lL5Dn4ODwhKI/mm16e6T87j
         qrOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QQBIfERgasWv0rgmG/hw/sJXFl7FGxnQifs+UbhRNA8=;
        b=eBPj9JeWZ8N33/tiNZQwKiLfp0ocSu0hH8zRcNAyL9sWm5uGQOh2CRepESqmSbrpAH
         9T0j3+PpIufIMBSMtMv10alK1fPvh/TNejoenz3txHjBEMiG2tPIcHorPVqMWom2EZ1p
         bpaC0rEzkYhqB1m97IzuEI66zp9NiLDWabHGLX+F8lg1eagqyPA5SsP9kUYklVKL30jj
         uENXaAjnfF6UFnNEYWV2fYUwQIMiWLABxYE1NpOeGgat1uItqsVCZ4orfLQY5VliYX+d
         jFElb1kyymHFNoA5XqxDoRVmHlqkCOHL0unlDOc0oybl4vS2fKQ2LjsqItnrxIiRCMns
         Z89g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=o5wRMSJr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a34si10601620pla.426.2019.06.01.06.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=o5wRMSJr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9926127253;
	Sat,  1 Jun 2019 13:17:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395078;
	bh=fBG6o237/Gi95Ym64uFcIJk2iniP//T77hTEuO8BtCg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=o5wRMSJrGKW1vMF10zjqyWPSJasEkBUnG2zreR45v3oIcxqZFEz2v0tXbP8PmFtvZ
	 3F1VrPsT+nutAca0+NT2xqixV3ZhtfsqzfEfoiICvPEav2sw2LGp2vfU8aZxLjg0Yb
	 sMTjeVugpQ0SSxiSg2kB0jP8qbUf9fSPpL2AD6gM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	Dmitry Safonov <d.safonov@partner.samsung.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 021/186] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:13:57 -0400
Message-Id: <20190601131653.24205-21-sashal@kernel.org>
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

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit f0fd50504a54f5548eb666dc16ddf8394e44e4b7 ]

If not find zero bit in find_next_zero_bit(), it will return the size
parameter passed in, so the start bit should be compared with bitmap_maxno
rather than cma->count.  Although getting maxchunk is working fine due to
zero value of order_per_bit currently, the operation will be stuck if
order_per_bit is set as non-zero.

Link: http://lkml.kernel.org/r/20190319092734.276-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Joe Perches <joe@perches.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma_debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 8d7b2fd522259..a7dd9e8e10d5d 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -56,7 +56,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
 	mutex_lock(&cma->lock);
 	for (;;) {
 		start = find_next_zero_bit(cma->bitmap, bitmap_maxno, end);
-		if (start >= cma->count)
+		if (start >= bitmap_maxno)
 			break;
 		end = find_next_bit(cma->bitmap, bitmap_maxno, start);
 		maxchunk = max(end - start, maxchunk);
-- 
2.20.1

