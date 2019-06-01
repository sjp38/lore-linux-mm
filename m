Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34730C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7B9524438
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GaSzDOR/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7B9524438
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 878006B029C; Sat,  1 Jun 2019 09:22:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 828D26B029E; Sat,  1 Jun 2019 09:22:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CA696B029F; Sat,  1 Jun 2019 09:22:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB226B029C
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s3so6556653pgv.12
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Olle9xQljGas3XNrVqvm1GBkXaQ4T6hhKOwDmwI0ujA=;
        b=WlHM/LHG08P4ULzdCPKN9uNcu1WVwfW5ghYZOcsvRXHFhw07/Ru4HLx063rUwy+Ryh
         hQP7sB7gGJQFomuRSmAFbLWomzOSqczjfQh57gQo7MihKOkCh5faiMKiADh8Ir7s+KwN
         ShvgG/FXSm5+rjdWDrN0q+5qdk+AM/d9JJ0hSPJve3sbUn5QpU3OAJiSunvj4HUqzcR6
         XNw/LdKB3ZXV45MylOf9rp1d+1pqlURkHiCOANza7Garx3Eo4c1a8ZFr+6suDhRTlzM7
         lYFGnakV7O06WYBsEbj+Ef96sCZonqMrrJqlhySxIhL6F+k3m9LFsz+IwT4rsGoNbHhW
         Ajbw==
X-Gm-Message-State: APjAAAU7Q006cNcJXCXdI4bTBDY5dFOEgBkwl8lIk1TiEEFgevoDitjq
	x8JK86s7rC4B9+Rlj6w+7RwVenArx+ZWQyooQeSjMtd4Pmoxg3Q/UsK0PvohpPLyZuzwhditjR3
	Pe7uYFN9j5Ydmfs3s+ugmbXz0rYfLkNd4TtBO23nnOg5wMz26u/8QLWtv/5kWo3qTBA==
X-Received: by 2002:a63:285:: with SMTP id 127mr14353716pgc.200.1559395358822;
        Sat, 01 Jun 2019 06:22:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8Ogy+EPfUoWgP2oTfM3eb13a079khMlvIvNR7tTbE2+CnBez0CfygUhmhxoQAJ3nh9Us2
X-Received: by 2002:a63:285:: with SMTP id 127mr14353640pgc.200.1559395358057;
        Sat, 01 Jun 2019 06:22:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395358; cv=none;
        d=google.com; s=arc-20160816;
        b=vhwmtvdyhcap1pczByru6n10pVmk4+VNzqas0cgQiPUV7xpM3wqiivCE8lFhXqg+jg
         2GFiNsJPuYX7Ad4NmFibhM3daunKP5pIf90XJeHJ/pp9qR5MDeFJs6mMrUJR1MOmPhkl
         ZuuWV7D5TwZI1WUq2jkDC26K2Tfr7Omjzn5fnkhCCPCwFTqqSV+aQbaK1m4QmdCE1z9x
         0JYvbwkY3vM5ryvjmA8zI4dPevrTZonPGg985jES59vskGORkb+lHCuL3CyLSztOjpso
         Cf/5q7Hrfs6Pww2JNIszxjxAJ4+++a5q1cTQeo8yhfKYhUS0O3rEBxqlEHE33gdifvAv
         dljw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Olle9xQljGas3XNrVqvm1GBkXaQ4T6hhKOwDmwI0ujA=;
        b=vJlMjNrwnBLt3sqa1MtHFOcYpkYIlzHuCb3RllkWEW631uLyIBtJxjixCx7K2FR249
         HpnToheQeT4JBjhaKIyumUKPT2QDfo+9LXuF6lZikKXVnqwSG6zPmJLYPaHq2oUeV/u+
         oDssDHgGWKt2akk3zhkd/7RiBUQnN6149ySm9YsKwktwkpzC1YKKcTOGr/XeokB24BB6
         kGrPNFLRtbobcRpdKVzzARBnaTfaMle672/NpHtRDvBJn9I8G3OWZKJAmEBZpZ21TeuY
         Ffxo3lEEisvV/CEfr5K9vzGnvBQGZvSOhoWVEhB5POSuqCPFsDyDJRBvzXGxubUL0zUG
         kf9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="GaSzDOR/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c9si9529340pgp.39.2019.06.01.06.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="GaSzDOR/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8CAD72409B;
	Sat,  1 Jun 2019 13:22:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395357;
	bh=ySSBzNCHE8z5+w8tkOcIZjG4dIlaAl6/E1llUlc4oNg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=GaSzDOR/Ecbas0BxXtfHXWqB8s3zDfxnb2HGcARJnTzJhisfuH++MMbAfZB+aMbCK
	 0W/sC9uYymAtrwc61A97eELQhCStJx9BxBfqvnrzAdCgVCEFOE4FaAcKZxbEZ+W9Du
	 Di0Z2GxwiTaJylq7Ujyc7/RJe76OJrRR/XwNLqOM=
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
Subject: [PATCH AUTOSEL 4.19 014/141] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:19:50 -0400
Message-Id: <20190601132158.25821-14-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
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
index ad6723e9d110a..3e0415076cc9e 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -58,7 +58,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
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

