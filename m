Return-Path: <SRS0=RN4K=XJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE9E5C49ED7
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 00:08:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4830F20692
	for <linux-mm@archiver.kernel.org>; Sat, 14 Sep 2019 00:08:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Rt4uWEX1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4830F20692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991606B0005; Fri, 13 Sep 2019 20:07:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91AE46B0006; Fri, 13 Sep 2019 20:07:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E1DE6B0007; Fri, 13 Sep 2019 20:07:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 57E6F6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 20:07:59 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id F37358121
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 00:07:58 +0000 (UTC)
X-FDA: 75931588236.27.fear43_62c2e175daf55
X-HE-Tag: fear43_62c2e175daf55
X-Filterd-Recvd-Size: 4613
Received: from mail-qt1-f202.google.com (mail-qt1-f202.google.com [209.85.160.202])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 14 Sep 2019 00:07:58 +0000 (UTC)
Received: by mail-qt1-f202.google.com with SMTP id z4so33573515qts.0
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 17:07:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=lp1ovS/BiJIimm2KkXbVRdqzH3DGx1lv+fcqWa50ZBQ=;
        b=Rt4uWEX1WC7qsSkLnMn+ja/K/Z3LuRUh6r6DRsPyhmXDfrHb/YriCW9u2abhjk3VxE
         bxtxaY2Tp7jiu+zQxe96ddm2u+q4E64QCoBM3NhEhMdMZ55Jr7T3N+faJlXo8PveLQp8
         kgcQNWh4O+jcf95NBm8xdqd/NVgkWSn4vxVpwIEqVHINNAMIScoyEFUs+9THwDEPC9D0
         C7h35JMQcp+Xb8IXk1bDu2CcML0EFrI+65MLL8ju5FQTuReB/suY9v5BcpjwMdq+iahb
         5A5DXIbsceoB3nj8e8SXZqwdXH/d57EzYDAYurm8Ataj6pN05YrcFH624rF1ek2xNINK
         u9Tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=lp1ovS/BiJIimm2KkXbVRdqzH3DGx1lv+fcqWa50ZBQ=;
        b=SgRsDjqCi4agGvSJ+DrUi/LvGSjXeI69GskMadW8aK/unde2XC4HtcYXib3yUot1s1
         VXAAjmOfi5Y1IEvoimwDhbRIOg/J+OldJh4Q1YH3Sjh2t9SsoYBbVKqhrzTgbLEg+2ro
         yzGqu+RJnNwX52AuPFZCTeczKko/MpbJl/f1BVpNRJiEOyvsoyEM+eaUXpzc17TJlrko
         BRCkuxN4Z6MrqBktH3h5pzPTGnLSZKKJd48ReWR37lTkxYeKcWNV9DOQLcyvGPULRQNV
         V/KTK+Pq+QIOGHosJy12K6mp15fqlSnWTgxPKcNKJuqb/W+LRiudR+nN2x8vhvWkLp6d
         5R+g==
X-Gm-Message-State: APjAAAWfhXbvzcoNd/rdl/jbaGV10rmhBL8MRzzUN/8MkHymRUdR/Umb
	fPJXvrRdqlsU61Ig2f7uM7p9GdINZKA=
X-Google-Smtp-Source: APXvYqwKncMAj8DEWm2CqFKi79/Wj4WIkkjQ3ekD9OmGLxgKFlWGWM7Vgnh3PbbPWsDEl1d9IrDcRnTxLF0=
X-Received: by 2002:a0c:f8ce:: with SMTP id h14mr22188070qvo.2.1568419677790;
 Fri, 13 Sep 2019 17:07:57 -0700 (PDT)
Date: Fri, 13 Sep 2019 18:07:42 -0600
In-Reply-To: <20190912023111.219636-1-yuzhao@google.com>
Message-Id: <20190914000743.182739-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912023111.219636-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.237.gc6a4ce50a0-goog
Subject: [PATCH v3 1/2] mm: clean up validate_slab()
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The function doesn't need to return any value, and the check can be
done in one pass.

There is a behavior change: before the patch, we stop at the first
invalid free object; after the patch, we stop at the first invalid
object, free or in use. This shouldn't matter because the original
behavior isn't intended anyway.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..445ef8b2aec0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4384,31 +4384,26 @@ static int count_total(struct page *page)
 #endif
 
 #ifdef CONFIG_SLUB_DEBUG
-static int validate_slab(struct kmem_cache *s, struct page *page,
+static void validate_slab(struct kmem_cache *s, struct page *page,
 						unsigned long *map)
 {
 	void *p;
 	void *addr = page_address(page);
 
-	if (!check_slab(s, page) ||
-			!on_freelist(s, page, NULL))
-		return 0;
+	if (!check_slab(s, page) || !on_freelist(s, page, NULL))
+		return;
 
 	/* Now we know that a valid freelist exists */
 	bitmap_zero(map, page->objects);
 
 	get_map(s, page, map);
 	for_each_object(p, s, addr, page->objects) {
-		if (test_bit(slab_index(p, s, addr), map))
-			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
-				return 0;
-	}
+		u8 val = test_bit(slab_index(p, s, addr), map) ?
+			 SLUB_RED_INACTIVE : SLUB_RED_ACTIVE;
 
-	for_each_object(p, s, addr, page->objects)
-		if (!test_bit(slab_index(p, s, addr), map))
-			if (!check_object(s, page, p, SLUB_RED_ACTIVE))
-				return 0;
-	return 1;
+		if (!check_object(s, page, p, val))
+			break;
+	}
 }
 
 static void validate_slab_slab(struct kmem_cache *s, struct page *page,
-- 
2.23.0.237.gc6a4ce50a0-goog


