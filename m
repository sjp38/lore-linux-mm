Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27E03C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB9B2343D
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 23:04:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LQVSpJ7D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB9B2343D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 925AC6B000A; Fri, 30 Aug 2019 19:04:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D5056B000C; Fri, 30 Aug 2019 19:04:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EB346B000D; Fri, 30 Aug 2019 19:04:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6EF6B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:04:38 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1B33DAF7D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:38 +0000 (UTC)
X-FDA: 75880625436.17.twist70_286c6b78aa53c
X-HE-Tag: twist70_286c6b78aa53c
X-Filterd-Recvd-Size: 2313
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 23:04:37 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 560202343B;
	Fri, 30 Aug 2019 23:04:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567206276;
	bh=iUw2+QrxtF8V2pQCqlNAu3LyQkGpQ92Kt+gVsEjPXYw=;
	h=Date:From:To:Subject:From;
	b=LQVSpJ7DqsFNt9JTgxoDRi0CXtZiWPEllIDAWdCZuLfAEgf098+hsh3cV6k77XCaw
	 LCPBpiCHeELUhmx0jylio0j0AvMEEJeb4DDltBWCMg24fB5y4+heA/Hp2jWS4nYOCt
	 jqn6JbNiUuJKwzntK5qvLUGSkMaGmaOCWWWt9e60=
Date: Fri, 30 Aug 2019 16:04:35 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, henrywolfeburns@gmail.com,
 jwadams@google.com, linux-mm@kvack.org, lkp@intel.com,
 minchan@kernel.org, mm-commits@vger.kernel.org,
 sergey.senozhatsky@gmail.com, shakeelb@google.com,
 torvalds@linux-foundation.org
Subject:  [patch 2/7] mm/zsmalloc.c: fix build when
 CONFIG_COMPACTION=n
Message-ID: <20190830230435.JBzfJANBd%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/zsmalloc.c: fix build when CONFIG_COMPACTION=n

Fixes: 701d678599d0c1 ("mm/zsmalloc.c: fix race condition in zs_destroy_pool")
Link: http://lkml.kernel.org/r/201908251039.5oSbEEUT%25lkp@intel.com
Reported-by: kbuild test robot <lkp@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Henry Burns <henrywolfeburns@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Jonathan Adams <jwadams@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/zsmalloc.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/mm/zsmalloc.c~mm-zsmallocc-fix-build-when-config_compaction=n
+++ a/mm/zsmalloc.c
@@ -2412,7 +2412,9 @@ struct zs_pool *zs_create_pool(const cha
 	if (!pool->name)
 		goto err;
 
+#ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pool->migration_wait);
+#endif
 
 	if (create_cache(pool))
 		goto err;
_

