Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70368C3A5A3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3263A206E0
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="b3C+Ykhd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3263A206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB85F6B0505; Sat, 24 Aug 2019 20:55:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D14366B0507; Sat, 24 Aug 2019 20:55:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2A806B0508; Sat, 24 Aug 2019 20:55:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id 98B1C6B0505
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:55:05 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 47D424853
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:05 +0000 (UTC)
X-FDA: 75859130970.21.bear22_497b7c5d66a2b
X-HE-Tag: bear22_497b7c5d66a2b
X-Filterd-Recvd-Size: 4089
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:04 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B67222CE9;
	Sun, 25 Aug 2019 00:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694504;
	bh=kKaN3Cr5sqAV+xNvs8rkdG+UYpwdBQMLlzsekFu2QlA=;
	h=Date:From:To:Subject:From;
	b=b3C+YkhdpZdaK92lI7iq8EhrCpuqxcU2qCpaHqHdUCdCNDNWkFKOtjy7RjUIW2MsE
	 umfe8j51j3sb4BZGFNZ4TC0b7irE1zRMD1P4yyxKz30Z1K0zjlvM2DViyk4E69yNst
	 wve7Gq1B1+a4GNwhgo+5IG4OLlsP6y4xNmukCyWI=
Date: Sat, 24 Aug 2019 17:55:03 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, henryburns@google.com,
 henrywolfeburns@gmail.com, jwadams@google.com, linux-mm@kvack.org,
 minchan@kernel.org, mm-commits@vger.kernel.org,
 sergey.senozhatsky@gmail.com, shakeelb@google.com,
 stable@vger.kernel.org, torvalds@linux-foundation.org
Subject:  [patch 09/11] mm/zsmalloc.c: migration can leave pages in
 ZS_EMPTY indefinitely
Message-ID: <20190825005503.70Mi5FZ2O%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Henry Burns <henryburns@google.com>
Subject: mm/zsmalloc.c: migration can leave pages in ZS_EMPTY indefinitely

In zs_page_migrate() we call putback_zspage() after we have finished
migrating all pages in this zspage.  However, the return value is ignored.
If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
freeing the last object in the zspage, putback_zspage() will leave the
page in ZS_EMPTY for potentially an unbounded amount of time.

To fix this, we need to do the same thing as zs_page_putback() does:
schedule free_work to occur.  To avoid duplicated code, move the sequence
to a new putback_zspage_deferred() function which both zs_page_migrate()
and zs_page_putback() call.

Link: http://lkml.kernel.org/r/20190809181751.219326-1-henryburns@google.com
Fixes: 48b4800a1c6a ("zsmalloc: page migration support")
Signed-off-by: Henry Burns <henryburns@google.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Henry Burns <henrywolfeburns@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Jonathan Adams <jwadams@google.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/zsmalloc.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

--- a/mm/zsmalloc.c~mm-zsmallocc-migration-can-leave-pages-in-zs_empty-indefinitely
+++ a/mm/zsmalloc.c
@@ -1862,6 +1862,18 @@ static void dec_zspage_isolation(struct
 	zspage->isolated--;
 }
 
+static void putback_zspage_deferred(struct zs_pool *pool,
+				    struct size_class *class,
+				    struct zspage *zspage)
+{
+	enum fullness_group fg;
+
+	fg = putback_zspage(class, zspage);
+	if (fg == ZS_EMPTY)
+		schedule_work(&pool->free_work);
+
+}
+
 static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 				struct page *newpage, struct page *oldpage)
 {
@@ -2031,7 +2043,7 @@ static int zs_page_migrate(struct addres
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
 	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+		putback_zspage_deferred(pool, class, zspage);
 
 	reset_page(page);
 	put_page(page);
@@ -2077,14 +2089,13 @@ static void zs_page_putback(struct page
 	spin_lock(&class->lock);
 	dec_zspage_isolation(zspage);
 	if (!is_zspage_isolated(zspage)) {
-		fg = putback_zspage(class, zspage);
 		/*
 		 * Due to page_lock, we cannot free zspage immediately
 		 * so let's defer.
 		 */
-		if (fg == ZS_EMPTY)
-			schedule_work(&pool->free_work);
+		putback_zspage_deferred(pool, class, zspage);
 	}
+
 	spin_unlock(&class->lock);
 }
 
_

