Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC0BFC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C14F273B1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vkrfiYXH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C14F273B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7E676B02B8; Sat,  1 Jun 2019 09:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D08916B02BA; Sat,  1 Jun 2019 09:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCF926B02BB; Sat,  1 Jun 2019 09:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1BC6B02B8
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:25:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q25so9619062pfg.10
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:25:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wvRNJqh7r6tQHZDAM384f5hhC5mXuxiJjJH1rckLOuA=;
        b=Erybv3VPGVcGtXuv9qb9E+zyuJjqZkofFSxPHAfvFgwaxnBMElxP5GhaNmtNO5qKlP
         5h1BOX573fDL+pTxDuIjyf4bPGhUnpvuIgfMgb7PqN3T1gUddbr5JHxnyUOVF7h9kuz1
         4zs0082YcAxZ119PYA/wMHMMBgKNYVGCQUMHC82FwafsbG2blRmpJbihDhpCJeK5Bfu4
         uPwZq172ToATOrTs1V4yuDXkPchvBCe+xnWuwStQW2wYhm2tJAwosf/V785QifcBI+rT
         3C0rVr+4WW0ae3E60vgtYKbxbC4aleNWiUZYGZyEYAdlu/c4C21FBYp2Pjo+I63NwomC
         v12A==
X-Gm-Message-State: APjAAAXb0O6hU7FF6TBWpbv2k7JW231bITXXx0IUVM7MuX728RNbImIy
	xn4Sznff1OCnvD8824omWWwKGGz/pkz01DsG/XovnRDBw8xAXHJXg9Z0lQ/ug9g58ntUw2MmlbE
	dRIjcTmcAGMIQYnuwBg3ISD6JzThiDTtHqn+kv9XnQ6LFjodul/DfG/+G/dGc89rg3Q==
X-Received: by 2002:a62:683:: with SMTP id 125mr9741593pfg.168.1559395528167;
        Sat, 01 Jun 2019 06:25:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZRZh5VJlZXO91j7O4oO7PR2as0zu0b57uGC7L4sMEnC2/5Ha2XSVIvu3xCaH/F+Ywp6bW
X-Received: by 2002:a62:683:: with SMTP id 125mr9741512pfg.168.1559395527563;
        Sat, 01 Jun 2019 06:25:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395527; cv=none;
        d=google.com; s=arc-20160816;
        b=ymy4Nt3l6f+JnvcYenIz66inZNk0HmO+/zbvcD1HBD67vifCCvf895Bw0jmuSUzXWn
         iK9uEt2109LOT0pdtirXHWGlw4NNnV6OLxdfN/eDmRrSkNz0/nyf2sv7xTb3FlfldmOy
         CuMS8brfNso4SeGEYQQDklJ/lvsO+q2VtJ02+0ni601ktEOKNV0ZY1SCGJyUyLhVeAVY
         MKEJ+LF7Rcqer0rqN8DjrsxGD7n+9bghJub3wRCmns7ZZB0jkkmNHJWadHKa7GVjtpNP
         K5Gg8ui/DtGxQWWmP6QFGvyq5Mss4qNfqTzcIC9yaV9om8NmuTWB4Pj+GoQ/RVq5jCIc
         wY1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wvRNJqh7r6tQHZDAM384f5hhC5mXuxiJjJH1rckLOuA=;
        b=c4t6dQBkioZ6ovpveo5jDiVBSTJWtvtUMGxkKDL57UP8SE6i0X+jqSRVm7Oj1UAzIB
         7D5HXDCDwMl8O4NuiNTR8gjz+e4qXNhfpMHPt63L+WLUvHC1y74MkCowol0RW2viFUTh
         vNdpo4CWFsnfOzJQ8xXmV3+kFH6jnnuuLuwYfgGy35ljhNod64P+Qq86ORNJAECMJzAp
         bCAqTgZavHP80hiP9C8U9sH6AU0lGAn+PPkAKbMY7K4hRXazH2NRSbaLqNBZpe6RqCJ7
         DtrYWU6Imdwoo2BiVYdgBVfP6IP6KTRmtJ3MMvCF7wcNiwcAL9S8qGITyoAAUHqADeJF
         2xAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vkrfiYXH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z18si10038200plo.175.2019.06.01.06.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:25:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vkrfiYXH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 156E5273A3;
	Sat,  1 Jun 2019 13:25:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395527;
	bh=W+mXVN4o7qdgu7foKIesICoUXtgOLDULDim6bbYHyBQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=vkrfiYXHG/UaTTFIJkMaF3CYR+GkeoS90ASRMOvcQ+jOeUO0EqsMsh9illfg0NwZZ
	 1WuvbE08RCqe3f6lm6Wlyofn2CcC2eHzrj4B8dvijGt9ldTT14H60B41TXrlAlY/gz
	 N0XwX7G6UbN0MTCDPcTFXeRe3nzfBsa8BbobhsCk=
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
Subject: [PATCH AUTOSEL 4.9 09/74] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:23:56 -0400
Message-Id: <20190601132501.27021-9-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132501.27021-1-sashal@kernel.org>
References: <20190601132501.27021-1-sashal@kernel.org>
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
index f8e4b60db1672..da50dab56b700 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -57,7 +57,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
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

