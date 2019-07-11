Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23E45C74A3F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C461921537
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="scmCxifB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C461921537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 627208E00A3; Wed, 10 Jul 2019 21:25:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FE1D8E0032; Wed, 10 Jul 2019 21:25:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ECED8E00A3; Wed, 10 Jul 2019 21:25:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1634F8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 21:25:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c5so2579110pgq.0
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 18:25:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ytlBWMtHJbXM/Fdr0Dw34etRRl/dA5ETgcx25kBAXTE=;
        b=KteFTVWzxAHXXrRhy+JjVyFRxNdxSusOGarZVcye1RPFpq4HBxr9sddfhwKgS8ew+q
         i6OIpeD2IjW/LnhMdswibjHl7YiRDD/UERri/KnrDtPGxtKtwpehXwrKKhzwCZ7rwzjl
         zJRX0QEA6jhUDomJe1QlD+TLd35CkJAQ30QB1Gvt0OYLH7yk0RXWbtifjZEEAQUwkh/J
         vdurmMLRR5EppdQLCEq1UwMjxeLJoEbnihmcBJeXjPDWLIKGpkZOWhdpsfkrxReoDpUX
         Z2X0BNvUs/cDdMWh9/5ImzqDGGM9DBfvMULaXgPF2AmxNR3PDN9H6j911o9uHr8X39GZ
         ga5g==
X-Gm-Message-State: APjAAAWSGV5TLaNz4iQX5as6boabBPoyz8uepHO902dP7NNOkiWNVPvp
	TFvhprVGP/Vmfs2ozWZvsoJ7D4+fSS43ZKqJIgWIQofsYg84uM3Zh2NJu1Wok0IRB6EP6D80mD1
	lBiJ5cSUbHKVVPTOQIcqxBr6ksC4AB7oy2SRUqpUPgwFHdqldRJEIsTNVWv9GoYc=
X-Received: by 2002:a63:6f8f:: with SMTP id k137mr1398737pgc.90.1562808351601;
        Wed, 10 Jul 2019 18:25:51 -0700 (PDT)
X-Received: by 2002:a63:6f8f:: with SMTP id k137mr1398692pgc.90.1562808350803;
        Wed, 10 Jul 2019 18:25:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562808350; cv=none;
        d=google.com; s=arc-20160816;
        b=Xc7gEb1wiOl48e5IUOhJrX52ykitp966JYX3rr9/NL5hq0Awf4dqIyUdopcoUld6HO
         gHGDabpH/zwn4wD7KIxKPISnZc9WMAolRgwddeqJ+ogqwhHdOqMKwpokD+PrhEedf/2G
         FHfIqI/zTzyd6Ggu/uJMY+ouTB6WisGz3nJs1ag8AyO1eROLJG5+oC+U9iUJa4RhQrDJ
         Omivni8dgsOwmFLHeB4BGcTNvXcktBcSmGRGJQzgBrUfeq2KTVgIbWk/+myTHwPl30pH
         ACKQvFQ7lx4Ql8+RIHkWuOODS6H/k5d+gGHxvEpkOg8qKx5oj863GUQSJo03VObhiKxK
         9+FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=ytlBWMtHJbXM/Fdr0Dw34etRRl/dA5ETgcx25kBAXTE=;
        b=osZ3duMH627TsvUhqEKLTrp1brpcvQ8DKXItDRJETphca45Nd61hOTgXmdFClxzQIU
         nN9Shj0ZrJGIRMAnJdADLeHNCBQIGBv0WcY9/80hb2+lwF6lnjF2KMgmLBBA8om7tDa6
         DxMhiY5EKnVX0m5PpziAmH1BjnJ2i0zWQWUGcPjcqALtHFhvgZ66LU/srht1wip01/ul
         OlBKEfduRun00/Qum6HyKFS6mnRYoWruaq5CwPk6MOEi7UhqlwvoqTBel7nB2gAQYrGi
         aym9KUo0Y1zkV8/u2nFmw3UI5katwKnUJobSztwHSXl2AWejVTni5XidZyyQk1feGcLP
         sLIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=scmCxifB;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t29sor2085021pgm.5.2019.07.10.18.25.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 18:25:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=scmCxifB;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ytlBWMtHJbXM/Fdr0Dw34etRRl/dA5ETgcx25kBAXTE=;
        b=scmCxifB8StBEnmKJK3AL4Hjoo98qxRNoQ8Fk3T8R9JuJObsuBeHZD00xDTlmTG4lh
         BzuC9uPW4vFnIP4tbOwbF3cqX08QGsRYfP2p+KEsQG5xIuaSSWt7oxSdFKZjc/ofymfx
         qw8C+OcxbqqZk22YmTmHhF8Mp/eKpdhQi+NAjVTUMZiePcw0acmeucdEhdmeeE+aiX3n
         gRwdmJpdShHc94ZVrAYoPS7XXlnnyC6tXr4cQj2bhACNORepwXVk2b2tOmJO2srqMWit
         qXgqphbd2UH5Wt76dnSGGMN6OabavY6+qQ2dpOslFYo1NQUYJE5KTS3xQ0D5pJ3G5Cow
         U1JQ==
X-Google-Smtp-Source: APXvYqwoGIjOCi1444aQyMZiTm8AH1PhVwM3KaGhWog4eNCwyVy0z+FnrWXmbFQXXt10zF79f3fcAA==
X-Received: by 2002:a63:9a51:: with SMTP id e17mr1412020pgo.212.1562808350302;
        Wed, 10 Jul 2019 18:25:50 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id b37sm10031974pjc.15.2019.07.10.18.25.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 18:25:49 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 2/4] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Thu, 11 Jul 2019 10:25:26 +0900
Message-Id: <20190711012528.176050-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190711012528.176050-1-minchan@kernel.org>
References: <20190711012528.176050-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with ignore_references to make it more clear.

This is a preparatory work for next patch.

* RFCv1
 * use ignore_referecnes as parameter name - hannes

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a0301edd8d03..b4fa04d10ba6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1119,7 +1119,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1133,7 +1133,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1264,7 +1264,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.410.gd8fdbe21b5-goog

