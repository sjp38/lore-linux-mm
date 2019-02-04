Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32BBAC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 08:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5445214DA
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 08:55:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5445214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F4438E003B; Mon,  4 Feb 2019 03:55:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A5848E001C; Mon,  4 Feb 2019 03:55:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 595FF8E003B; Mon,  4 Feb 2019 03:55:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00D4D8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 03:55:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so5572998edr.7
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 00:55:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LZuVEIh5iPG9fPzOuRrWUdtrl0NnUvQQYHBYDYgN95M=;
        b=MLseQAk1R6dgGdQtJrVe4Ob3raTP7U4wah1d0iR2x5ZeG0IaALJEfu8xlFHv9E5pnB
         ia2KFoTisJ0c670sbT4kxROPHnc1lH9/r58FooC2RwsILmKT9qIirCxQqmO7vaWR/4fJ
         o1QNZ0pJNI50M0M+soSKT94Xi6NQwqC4ztjrOWOZkIjVDDymCO9RNViM/MEuJEMMMHZ9
         X/CG2T+DqglDZpEPvtprHW3IuEb77uxDuvgLh40h+SAittHplgH/47FRfF2F9Nl1SWyh
         329GkQvkRohLmXtmxUsPjBwpwT2I9LZjM+4A0GyX231vR8LnuTA8soRQF+g9uXHm652/
         IKkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukeYfw6/YIxVFKhEyV1oJP4cxZfUgrccpprwn3eRSqFtRH5/dvxl
	pl/PHLUOZSjwd+mlptLaK120IzVunNeu73KjAvN3jKiLg6YcGkyaSO82tB2kIBWM7Yb7J7hBLXo
	KFdlILRZr9an/BftUIOVi9wYCc4ZLeZ3+KPkRWS8h+Q7zMSZtX57/r9OXm0VZtNPscA==
X-Received: by 2002:a17:906:2e50:: with SMTP id r16mr26401972eji.44.1549270516450;
        Mon, 04 Feb 2019 00:55:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN578cl0j70KJf4iOCWSTiQ2nAweg9gBMgVHpg27i2Dm3vnUSUfuiymeSfRenGJ3WNcMoRsG
X-Received: by 2002:a17:906:2e50:: with SMTP id r16mr26401927eji.44.1549270515440;
        Mon, 04 Feb 2019 00:55:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549270515; cv=none;
        d=google.com; s=arc-20160816;
        b=X9SYtDti7m5sNYYtpPNLhG5GTIuEriNdaam2oovs/Eq0FRLvwdQ0iu+tb4CHzWARuG
         XFvUFONxvuvNAmUIyo+D6jVY6UgGJ89kH/0mfzD3Xqr8MStxHVH4Id/dhFEdoN3YZrYP
         INGgr+YB92dxaXMxmrHJsNSZ7Uxa67OLx9jvpejpW1Poa9BtM/haqz9OSTfYZqC8trEY
         DnHCfhQsTo+ts6FIn3DYqGYU81sdcEmFlrYaif5pkwmYPDkFNYI6cs3vxxyhXXd5sVds
         GEvBdT+w5IiP2b0KrAzckgJSLT1N/AqTC1BZYjtUEUZVwau85drjIDSI9JFarbKi+4g5
         4elA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LZuVEIh5iPG9fPzOuRrWUdtrl0NnUvQQYHBYDYgN95M=;
        b=HAPKD0auUfyF+yBJIicd44pbuksXyKeI5SLz1YomcK3p+KVD1fYz3AmkdWvAt0tokQ
         6JlENbeTcJtGNK+CgLHsitiYiWw8HcdR2FoMHIHvyjhwj7mN2dv7HsFH4o5tJN1W8URk
         oh4fQtuu3+ReIRlxhh51O+UFmGH2s8Q/uyhcDen0F8IdwAe9hnMGeD6cAzmkrFsMCROj
         H8MfS7K3BWwJIV0qBTQ9P0XVi5+IPZbiCJwr8i24jv9eftvt9hKw5GvILu/4fwGoilOz
         831Qd7hOlGIFfS3LexEvNyAmf4g91bvPzHyk1eSq3E5znGLfOxNpDaEDEDwXWYKtaib0
         +1xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id u9si1636014ejk.263.2019.02.04.00.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 00:55:15 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 14463B8714
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 08:55:15 +0000 (GMT)
Received: (qmail 18787 invoked from network); 4 Feb 2019 08:55:15 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 4 Feb 2019 08:55:14 -0000
Date: Mon, 4 Feb 2019 08:55:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: [PATCH] mm, compaction: Use free lists to quickly locate a migration
 source -fix
Message-ID: <20190204085513.GK9565@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-10-mgorman@techsingularity.net>
 <4a6ae9fc-a52b-4300-0edb-a0f4169c314a@suse.cz>
 <20190201150614.GJ9565@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190201150614.GJ9565@techsingularity.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil correctly pointed out that when a fast search fails and cc->migrate_pfn
is reinitialised to the lowest PFN found that the caller does not use the updated
PFN.

This is a fix for the mmotm patch
mm-compaction-use-free-lists-to-quickly-locate-a-migration-source.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/mm/compaction.c b/mm/compaction.c
index 92d10eb3d1c7..d249f257da7e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1238,14 +1238,16 @@ update_fast_start_pfn(struct compact_control *cc, unsigned long pfn)
 	cc->fast_start_pfn = min(cc->fast_start_pfn, pfn);
 }
 
-static inline void
+static inline unsigned long
 reinit_migrate_pfn(struct compact_control *cc)
 {
 	if (!cc->fast_start_pfn || cc->fast_start_pfn == ULONG_MAX)
-		return;
+		return cc->migrate_pfn;
 
 	cc->migrate_pfn = cc->fast_start_pfn;
 	cc->fast_start_pfn = ULONG_MAX;
+
+	return cc->migrate_pfn;
 }
 
 /*
@@ -1361,7 +1363,7 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 	 * that had free pages as the basis for starting a linear scan.
 	 */
 	if (pfn == cc->migrate_pfn)
-		reinit_migrate_pfn(cc);
+		pfn = reinit_migrate_pfn(cc);
 
 	return pfn;
 }

