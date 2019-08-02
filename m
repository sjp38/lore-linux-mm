Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B45C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A461920644
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:53:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ljI7lFF3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A461920644
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E99A6B0003; Thu,  1 Aug 2019 21:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19AC26B0005; Thu,  1 Aug 2019 21:53:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089BB6B0006; Thu,  1 Aug 2019 21:53:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1EE76B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 21:53:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q10so23208330pgi.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 18:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=VKzEuSkmyrWV8LhwIH3JFAo5TpB9gh8PzM9j2uJXmIA=;
        b=tsPAVqiistTQX4cWu94/OuBtGBEPWjWP7cNa1JGxC6tVhLUTkGODbWH23FpgZTZXT2
         AWPKgqqfsw+S/wdbKB8A/MWSFt+mNqpTwLCeRWHXydn4D2Fubowf+z6svw0SfTP+Z0yP
         BQ2KLUv7DrAanKmV6mf01GPD5gYdwwqYCi93Sq1TpfGMTHdGgzq8ZETtAoKloLZXRkkG
         KPGL+jWXeuqMeAUlP2/6QZffDIXFIdCcOI6pV03Lu3LxaPRkiz6sE0d3kKB/Pi4GRAHS
         d5TKVMeci8D+y2XlMcCskZYNUHEM8iNCn4oVn7ODNyu5/GD0uVkzgwR2kCJepkoVS/6V
         bkgw==
X-Gm-Message-State: APjAAAUp5Qv11Ds+dLewFfo/j6sn5b4g/zHiW3yD0Z3LMdsYv8q6Q8XI
	deJBWzICjfCdsy5tHFecO6QXqAZ3RbMy2CWcJSDFSBo/6x32gr/9RY0rKLbDuhhDzrp7H0pilrk
	GDWhQI1HkEf+7pfdqZ9z/462/ki0xCpB/U9tLj+DLLQq4qufqU5JG00pjS6GcxB/R/g==
X-Received: by 2002:a63:36cc:: with SMTP id d195mr80483213pga.157.1564710818188;
        Thu, 01 Aug 2019 18:53:38 -0700 (PDT)
X-Received: by 2002:a63:36cc:: with SMTP id d195mr80483177pga.157.1564710817342;
        Thu, 01 Aug 2019 18:53:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564710817; cv=none;
        d=google.com; s=arc-20160816;
        b=E5xTRyQ6KDgXYvp20lLAR1+ujvkNoXDWAyDOWOTbk1uuisuq2yemvE7XtXv1Y1hCUB
         T5UF+cZdGOG0b2KsMQlMA4P0sK54uNCI58MvpExYuGGM9BsjHhc2HAUMdlC1HAAmQx+6
         c8kBtF+C2gFUKm3s9QeNzdA5IBgwnTQC2PU2e1uA2m3rOafGV4vf+z3Z0jhY2t1DnVPm
         gyZWLRs0lWSrhhH8/HrpxILveLN/AT7ZnrlWPw53lby1GYY0C7Rt4FjGyPqFL8AQczDs
         /yWAGxs82igytWY8po0JMqOI7NoLuq0MZkIOcn6RepnHEilsPLR2RQKZkeHO6vzzlxDb
         w9xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=VKzEuSkmyrWV8LhwIH3JFAo5TpB9gh8PzM9j2uJXmIA=;
        b=eiC71kdvpRL0BXFAhJRqOMdDTFVc+R1U/CM4b7S6/2dS1YglMuGgc0cnFNo+nFuWM8
         Z1xFR7z4IMzl3Hzv5pRQ/pcelk/MNHKYh5S5DZRdiVPxF21251vVV9wNa9eqMvy3jSKD
         ndjPMi2xUhID7RnVDfXm4l9kXFn19jIc7/aHKU5h5j+MYGcpUEa7Lf3xi/D0ng3sjIth
         RaLQas4svMPtsGrDEwrKHob5UUvjVuHwvE5gGOsimnBM8Y+4ljR5AsiWtSxuUBbzFNo6
         ZJxtgFgwktOm4ewsXip0Avb85D2+v8GFopeEYNWHvNuK4i4C7UfNjuzYzgyYFXWE7Eed
         20ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ljI7lFF3;
       spf=pass (google.com: domain of 3ojddxqokcm00x6ahuda6bz77z4x.v75416dg-553etv3.7az@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oJdDXQoKCM00x6AHuDA6Bz77z4x.v75416DG-553Etv3.7Az@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n9sor49356620pgl.53.2019.08.01.18.53.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 18:53:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ojddxqokcm00x6ahuda6bz77z4x.v75416dg-553etv3.7az@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ljI7lFF3;
       spf=pass (google.com: domain of 3ojddxqokcm00x6ahuda6bz77z4x.v75416dg-553etv3.7az@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oJdDXQoKCM00x6AHuDA6Bz77z4x.v75416DG-553Etv3.7Az@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=VKzEuSkmyrWV8LhwIH3JFAo5TpB9gh8PzM9j2uJXmIA=;
        b=ljI7lFF3O1uGnDJgLjRw0nWAvDTSYyuHT002SegNqoGSSb9OLyCXLW4bvQwWX+qe6V
         V8wJyCYEPbFnkif6rt8y681avtdd4OXMPubBiEaIx1Lnxy6Lk4ro3uR/f0txJInnuZ0M
         yX2RYvNbUC3w9m+LKYUPbcjYgI+2S4RRgGV7dSs1rDRHmfuvkjs3QRY5Nom+99Lvujqy
         RVIFe5Kp3hVYnZpoOnuzgjOxx+c/yhMqr7N4KhLSFDHkeelY9Dec413o9Wt3oqVtk2ZU
         c8kH6QeWOT6aag7/h4j+Lzfi5RMbgcZlAgILtJrvzfZm0aWW409BAvH+WhXeRAiyeeoi
         zuTA==
X-Google-Smtp-Source: APXvYqzcvYNu3kUvzm7uEj+DWVq5JRNiJA6B1G5NwHfF9cgJ8y3vPHN7XgvR2puOfpuYvp6BotAWHMYLYz5iAEeA
X-Received: by 2002:a63:f807:: with SMTP id n7mr125813928pgh.119.1564710816388;
 Thu, 01 Aug 2019 18:53:36 -0700 (PDT)
Date: Thu,  1 Aug 2019 18:53:31 -0700
Message-Id: <20190802015332.229322-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
Subject: [PATCH 1/2] mm/zsmalloc.c: Migration can leave pages in ZS_EMPTY indefinitely
From: Henry Burns <henryburns@google.com>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In zs_page_migrate() we call putback_zspage() after we have finished
migrating all pages in this zspage. However, the return value is ignored.
If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
freeing the last object in the zspage, putback_zspage() will leave the page
in ZS_EMPTY for potentially an unbounded amount of time.

To fix this, we need to do the same thing as zs_page_putback() does:
schedule free_work to occur.  To avoid duplicated code, move the
sequence to a new putback_zspage_deferred() function which both
zs_page_migrate() and zs_page_putback() call.

Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/zsmalloc.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1cda3fe0c2d9..efa660a87787 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1901,6 +1901,22 @@ static void dec_zspage_isolation(struct zspage *zspage)
 	zspage->isolated--;
 }
 
+static void putback_zspage_deferred(struct zs_pool *pool,
+				    struct size_class *class,
+				    struct zspage *zspage)
+{
+	enum fullness_group fg;
+
+	fg = putback_zspage(class, zspage);
+	/*
+	 * Due to page_lock, we cannot free zspage immediately
+	 * so let's defer.
+	 */
+	if (fg == ZS_EMPTY)
+		schedule_work(&pool->free_work);
+
+}
+
 static void replace_sub_page(struct size_class *class, struct zspage *zspage,
 				struct page *newpage, struct page *oldpage)
 {
@@ -2070,7 +2086,7 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * the list if @page is final isolated subpage in the zspage.
 	 */
 	if (!is_zspage_isolated(zspage))
-		putback_zspage(class, zspage);
+		putback_zspage_deferred(pool, class, zspage);
 
 	reset_page(page);
 	put_page(page);
@@ -2115,15 +2131,9 @@ static void zs_page_putback(struct page *page)
 
 	spin_lock(&class->lock);
 	dec_zspage_isolation(zspage);
-	if (!is_zspage_isolated(zspage)) {
-		fg = putback_zspage(class, zspage);
-		/*
-		 * Due to page_lock, we cannot free zspage immediately
-		 * so let's defer.
-		 */
-		if (fg == ZS_EMPTY)
-			schedule_work(&pool->free_work);
-	}
+	if (!is_zspage_isolated(zspage))
+		putback_zspage_deferred(pool, class, zspage);
+
 	spin_unlock(&class->lock);
 }
 
-- 
2.22.0.770.g0f2c4a37fd-goog

