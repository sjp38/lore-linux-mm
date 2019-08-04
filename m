Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60D2BC4152F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E9E8217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AhiTy6Bw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E9E8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B9396B027B; Sun,  4 Aug 2019 18:50:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F3B36B027C; Sun,  4 Aug 2019 18:50:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3A476B027D; Sun,  4 Aug 2019 18:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A309C6B027B
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:03 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so52211482pfb.13
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=hfwPKVTNa0mwwiHXf2QHVZFxEHbSkUc4hvkM1dHf1ggbig8u4RqxCxjY2gcjAB08sm
         5CVmygugOJ/eUmN4aA8HcZKI35oU04BRzmBJtclimkK+ZGXdUcSpvryVZpMpMT3326N+
         Mwif5HhaLFqYI/5YdBWuKm/QxZs9Hk8gm+M1zBXEIat2gxUu7YO6CpUSznB4ww6efmoE
         fhoAJeffApFcxcGnuVruaYF1O3HY7eWodgVtGhoWxwEL4kSzj+mq7QTG9CjMbAKXVjSh
         t3N10fH+qGCyrpvfWQfeP4frYIEmI3TtxiTDIji3iIUoUSweoDpgGVNQDmF5YkoE7HLn
         SKVw==
X-Gm-Message-State: APjAAAWMUHLAbcasZJ1wcRabvaV4k3RQTQSLMi/agbyXNHvL+n3WSwcj
	+bxrsjvEr6BeO8F6EwuwAHHuXG+jb4x9N/e8mzaH1evN4qvqzEOhS16AuX55+o0TvGQiEsijQkG
	vTukTpTpoouY20sVEmS4P7F12RTlGfSWRtY/WONrkaz19ADNGPewAi/EHz9GkRqlFYA==
X-Received: by 2002:a17:902:28:: with SMTP id 37mr131107813pla.188.1564959003381;
        Sun, 04 Aug 2019 15:50:03 -0700 (PDT)
X-Received: by 2002:a17:902:28:: with SMTP id 37mr131107787pla.188.1564959002619;
        Sun, 04 Aug 2019 15:50:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959002; cv=none;
        d=google.com; s=arc-20160816;
        b=lfu1QS6EudHDg5Iq9VEDn2aIo9ZrO1IARtlsj5+pOs2DcBhFmYdEqSa4JzkTUqK365
         WgSJXXF/mWQS6H1GQmOCfOxmIwLMxd0Lel5bhtY8pL1K17bCx+PlUSFBOsnxAMIx+DE1
         HY7okwDonvpUOrfNFeNisKB+2IJJhYQoBa0AkIYJnbWKwdWLi9z7yIGGZEYASbiP5g+q
         NGbCZ5btjVrMzqj7VYe4a7bI/FMnHrepeoTZHyEoet8swlzNVeAme4mKfhlH54MhcOWO
         EBLbqpYqMN+O+SUV1rqf+xutYQk1WBQ725pJLF0E6et33hDHerRFI/+h33OtpYu+ro8/
         wvXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=Em33Jmn0REi0L9d0F3w5zcjG4kxcvI07YR+OM+njtyEWRGXv8tJMOgcBlt/cnu8ct5
         sPnpf7GRu/JLDpYQYnDb2kHEsZroF7s7ArJKT2pCX6pPX7bVklNzKAcN/NIT8k5Xs6BU
         vkA7BJlGlpp7Z+i9Z9ulzH0VLLODzUsM+LRgySs/U6VJ7I1PzRYVjKlK4ABQJwbBonai
         lebt01mty7v4RD9Y3IU/3t2P7n9SdujWnPJ/Z6/YIUsfzX8Pm+U0QyidpSMgL+JH63HA
         lvr3JDezaH3gXTr4li6iC4MCIWu74iwUiGpVB6Ctk59NwMnWfjH/EFM+0uOlC3nbXOAw
         1SAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AhiTy6Bw;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor36895311pgd.65.2019.08.04.15.50.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AhiTy6Bw;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=AhiTy6BwwPX512pCtOjXzDhtmzbgOoiJS/+TVyOQOpgZBJJ3KH2MvMlT06wgQ0OyIE
         yRj5vh0m/7nueGoCFtjCaur9BEfURX9GzhTYKWy0B3aTXsLWtG8nWNwdvuLJmmVnPrhP
         95nQuVNILOT8/qwgmNMhZUxktGIeWYoKF4s7BnIeiizbkSEamO5uEElN38AxJ2A5eBFh
         hUZ0Kt1okRjv7luJmtlo0FzBe+9ghVWNnXfTbLZh+WnsUeeUMycJgCWu3dSBNK1w3TM4
         /0kY40aJkh8f8jXxTbX8I9Uw2iPPUnqs4M2MJ05zm7QPLg8alWzs50lrMgIbZfArqyLV
         LbSg==
X-Google-Smtp-Source: APXvYqxnFD3/8kVar2adJXY1j7ibwpw3u4EZRA3KMnmY1X8dVMpcbjzWPVU1wzddWPe9+8PMCheF4A==
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr78564615pgd.151.1564959002300;
        Sun, 04 Aug 2019 15:50:02 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.00
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:01 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 27/34] mm/memory.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:08 -0700
Message-Id: <20190804224915.28669-28-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..8870968496ea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4337,7 +4337,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 						    buf, maddr + offset, bytes);
 			}
 			kunmap(page);
-			put_page(page);
+			put_user_page(page);
 		}
 		len -= bytes;
 		buf += bytes;
-- 
2.22.0

