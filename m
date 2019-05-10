Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C6FDC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C749216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FcPOknlM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C749216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 564456B0291; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4521A6B028F; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F19C6B0287; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C170D6B0288
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e14so4086874pgg.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=x3QMzWs32Ka8iEInbNwmU942Ku6RIUdAQkunVS8M82U=;
        b=d9cZpZUdsIb0EGf6OCZf0UwSEv3iW+WSFcXvk/O+JfWiJnHOHAKnvyIYXHuBuMsnXV
         MURngenMxLvCF3cwROlEbIZ11KFJVHXisXPYhFNDFQ+RmBo7fOp1mt4LYu43PDd73gPi
         ae7baPIJJiXHfclqQX4n/pLeUnF09IS3UJxr5xH5szR2AckV1YZXQG8AzyVuUgU+THOl
         s14N4Ke90wx/sbTY2bq1ss5leOZ7XpOn2vKQ+wvRiSCX8b2ujPIEG/DZPThsR9jNrQpr
         hOw0DNFbxKbGViQGeRnWufzaAdtRYIKZBzgVz0SfSfkukv0V47yP4edVVT9na0SfvSol
         786w==
X-Gm-Message-State: APjAAAVGc+6rAkfDXzcpRMth+v1lzK5KXJKtiqTKwDMigfu1m9kOYLDv
	aT6HcdtHFKrZ2g251Z7Op090ls0/WubjlpgNf9VUTkqIJ/VLb3InzXr8/yB6J5TiErK4e7B4Aj/
	EB5NupGzMnPbhxm580OiIWUNYJJqZqsYuC8R0P/ogbCO8VSpkqVLJHwCGaaGNDAljmQ==
X-Received: by 2002:aa7:8251:: with SMTP id e17mr14617535pfn.147.1557496242215;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmQ8xvgjxJikLQyY2bPTqiO3/QlDkeOo1r/gVXXYc0zkyDIozDMEO/c7RgCt0Qnl0NSfFF
X-Received: by 2002:aa7:8251:: with SMTP id e17mr14617339pfn.147.1557496240785;
        Fri, 10 May 2019 06:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496240; cv=none;
        d=google.com; s=arc-20160816;
        b=ovvH65xja+TNBsHOmpU6AHIr91m+w8oWM6eMwTSTkvlt8+ibRI62wASymjumSIFMXP
         hCJi+DF7U/e3hvqis6tyiHBoQMfBkcklZJKwpl9C/zAWSRK8RKvF7/mzZqsoQ6QxAYAK
         YJyTwdlpUncb69WbQjrOfesHredYsMj+Ec1JEB7sR5n7bs1SY2Bqi9Fe3su0Lz/0Vsq+
         pXLavbCtUv68BKH1no2R4htypaWAss1DbtGNTIyKg32gY2ma7rhJ+ndXqZc6Zab9h6eF
         HF4dDjTcbiF2jAac2v2Hv6R8oRoC0HNmWnD7OwmPLwJhwj/5Dxh9Wglpt9fBlaXMYE4U
         UNSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=x3QMzWs32Ka8iEInbNwmU942Ku6RIUdAQkunVS8M82U=;
        b=KUlrGNbYspxWjXSTV3kNpur9LFe1umbwqB5kU5yj9aSWWmqSAHadBBrIwaP9eEuRvB
         VrlKI001VrvRDFsVz/cL2Jc3c+SgyzyxC4+Z3rfTHy8Bh07Ai9cvcHPKrkOzKOVWy3mQ
         G8E2DclfEGTGUyJlzvs3rsRXQ9H0RYKXD8hZUlXo7xkrZWsdDu8e2mm11vul/SmIJ4q0
         M6YZ0/BedJ8YrinTfr9lW76/n0mXBA2MfO5zUrkxNeaGpy4rSPb0oiAWHOT3MIdAcgi3
         d6MoGv5gMM1qKFnlDHzQCgXNjyskWPIAVa2tEnkMF6hGbHy19QCV6FE8ETp3w6f5btDy
         OzRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FcPOknlM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j1si6802235pgq.173.2019.05.10.06.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FcPOknlM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=x3QMzWs32Ka8iEInbNwmU942Ku6RIUdAQkunVS8M82U=; b=FcPOknlMXHmkD0S+xX0Fbm0Ze
	rFpDuGDSx1wH1J809MOUuJLOT+sn+mXG7OAA2ZMJrJdXmP8+oXRgKps056fst30tlGkdHun4ltPPB
	ljjEtsARBYkdqUbVnDUgvvbxfygdr0p8v5r6jdOz5NcxXpDIi20zYjyP0u7F16GrCcFbuAZnstbzR
	ZCs5Q8quF0UiimYuSAQ6Lx0p0nMew4iq9fcY2XTW6oPAxGb0TFDweEdGGrJd3w+dg5NxfJN0xv9Ix
	jJbI2+q90cvvMlGU1bjgKZdpt/TrxM+FmwiMM8IBmG5qbzp1woQwUvmG3Ne8eZ74673Gcs5wT8UjL
	2IQNCXWtA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004TJ-7o; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 01/15] mm: Remove gfp_flags argument from rmqueue_pcplist
Date: Fri, 10 May 2019 06:50:24 -0700
Message-Id: <20190510135038.17129-2-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Unused argument.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f99db76b1ff..57373327712e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3161,8 +3161,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 
 /* Lock and remove page from the per-cpu list */
 static struct page *rmqueue_pcplist(struct zone *preferred_zone,
-			struct zone *zone, gfp_t gfp_flags,
-			int migratetype, unsigned int alloc_flags)
+			struct zone *zone, int migratetype,
+			unsigned int alloc_flags)
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
@@ -3194,8 +3194,8 @@ struct page *rmqueue(struct zone *preferred_zone,
 	struct page *page;
 
 	if (likely(order == 0)) {
-		page = rmqueue_pcplist(preferred_zone, zone, gfp_flags,
-					migratetype, alloc_flags);
+		page = rmqueue_pcplist(preferred_zone, zone, migratetype,
+				alloc_flags);
 		goto out;
 	}
 
-- 
2.20.1

