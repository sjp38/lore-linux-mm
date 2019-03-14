Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC2C0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:40:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 542362087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:40:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 542362087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0A498E0003; Thu, 14 Mar 2019 05:39:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B7FF8E0001; Thu, 14 Mar 2019 05:39:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A7538E0003; Thu, 14 Mar 2019 05:39:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 313248E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:39:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m25so2131623edd.6
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:39:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=OKrhb6Brmiz2JMub5vodi+ISe7Ro4R0QG442Nou0lJQ=;
        b=BbfJcOVBhoMp1AyQ9qF8slyBWHVwUjt/TjSbL9VdEZzZcQYYkkGtSEYJuow6W6Y04/
         7hA0Ngz8T6fXYz90eQTCmt/1f7HbiSuLh6qBgWe6YVHUvLq+O5rolHP8vTmfD4FYi4QY
         Zj9yamM5QfosD5/HOxt3oDnk4kvKqRlHMcv/mSb2j4fY5ZoIT9IWNhOxD5jwrsQUlMvK
         G7WBHRS2sgnWI6kP4NK5SAWv20116HLVkxTfsfula0wOz2xTYSjqOLmJZ6g351ndLJvy
         pv5MjPRSuPzECiBLCmq4zMMzN32Xh6fM/TkGOx+eRAUclE69vHTLAoQgsqXTdNysIfaR
         46pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXhDSH9slRv33twx+Sf8FmtvRg/iP0FXZmj42W2oVMk/ko/qb5u
	CaAPAhlQXq/NEIdoHXk5niFnDPXXC4oAs+7W0UQllJLFikqbgrznt/y1lRgxbUvPheYUPiusFQ0
	+H1W17Uvtz0YnQ4D8Yltm3/CyWyyzD49/FtmwDpi5C5XCHGS7TCE7nRIsH8Itl/SRuw==
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr31892370ejv.52.1552556398630;
        Thu, 14 Mar 2019 02:39:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvf4GlrrAEe8tyQtz7LpszM5W35/MFdHHxGVsqQpnnVVNFxtOtsll2QWBqsRCHrGpvRdSt
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr31892316ejv.52.1552556397421;
        Thu, 14 Mar 2019 02:39:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552556397; cv=none;
        d=google.com; s=arc-20160816;
        b=g0dHnrtyJwQILTXU0gn3SjzGJBJTXkUmGr7sm6zcebAU28XZkaYfdX3PqzbqWdLq1F
         /Jhz9DLHpAb7Mu4Vo7T3Pa9NOL0WaMjd7f5gtvNkdq4B8sfFLQMAJJsnu8sesIdFE5vi
         LBE/UcG2WcA45q0fXANRBitk6nl2nkktjcTnl1W6AQBxrtWXdKWJDaJ5HFOnZ9MgFq95
         NUzKIbkQSyu/lsEu2zjggDeskbvYYkTDpaMX8lcgy9SxuFoYehC7aZnA0H3o0UE3WXqy
         MaqWO3ySwGvQJYrq+01J51eT6vMibWD/WM7ylCmabnAydos3MLg8UWTjvkntsW2r30+L
         GY1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=OKrhb6Brmiz2JMub5vodi+ISe7Ro4R0QG442Nou0lJQ=;
        b=yol/23qFeGfXia44fp61fQJ2t79OGjxUjSA0J+M2M+AE2ruAHAj5tLBSXgDIPFD3F6
         djiNyRYTyVHRVnxD8zg9n0CM3AAV/bsvKIVxWOnDVjvPxR8aTgAqcJFwy0e8wLgTaNTV
         Y/bxuR7NHD9NiKMXYneolybVd6LbehtN+9IUhb3lbHtxttN6oyukhcRI19BcL7h4JqAr
         DnQVmGrUJPA8jF4PwLtxY1+ptkVhd3zjGI+YfqEUvbpmjjG0xs2fadqnLwZWhWnTZpSY
         vC3QaqSkj0xnh+hyJuiCwame6+Mr2U5kC2ZGLj+hhDXnTV3QZdBmWFDd6pud5jbX4fGp
         UXQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si1569648eju.316.2019.03.14.02.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 02:39:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF779AF7B;
	Thu, 14 Mar 2019 09:39:56 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
Date: Thu, 14 Mar 2019 10:39:44 +0100
Message-Id: <20190314093944.19406-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_pages_exact*() allocates a page of sufficient order and then splits it
to return only the number of pages requested. That makes it incompatible with
__GFP_COMP, because compound pages cannot be split.

As shown by [1] things may silently work until the requested size (possibly
depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.

There are several options here, none of them great:

1) Don't do the spliting when __GFP_COMP is passed, and return the whole
compound page. However if caller then returns it via free_pages_exact(),
that will be unexpected and the freeing actions there will be wrong.

2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
things make break later somewhere.

3) Warn and return NULL. However NULL may be unexpected, especially for
small sizes.

This patch picks option 3, as it's best defined.

[1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b9f577b1a2a..3127d47afaa7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
 /**
  * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation
+ * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
  * This function is similar to alloc_pages(), except that it allocates the
  * minimum number of pages to satisfy the request.  alloc_pages() can only
@@ -4768,6 +4768,10 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	unsigned long addr;
 
 	addr = __get_free_pages(gfp_mask, order);
+
+	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
+		gfp_mask &= ~__GFP_COMP;
+
 	return make_alloc_exact(addr, order, size);
 }
 EXPORT_SYMBOL(alloc_pages_exact);
-- 
2.20.1

