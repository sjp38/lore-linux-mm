Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 153D3C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 06:10:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA90A2067D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 06:10:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jjx4Ou4H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA90A2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 667656B0005; Mon,  9 Sep 2019 02:10:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 618796B0006; Mon,  9 Sep 2019 02:10:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52D7A6B0007; Mon,  9 Sep 2019 02:10:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3C76B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:10:26 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CF49E181AC9BA
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 06:10:25 +0000 (UTC)
X-FDA: 75914357610.05.pin80_3dec84c7eb62b
X-HE-Tag: pin80_3dec84c7eb62b
X-Filterd-Recvd-Size: 4351
Received: from mail-ua1-f73.google.com (mail-ua1-f73.google.com [209.85.222.73])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 06:10:25 +0000 (UTC)
Received: by mail-ua1-f73.google.com with SMTP id s1so1551089uao.2
        for <linux-mm@kvack.org>; Sun, 08 Sep 2019 23:10:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=HBimVA7RGAjl4KbkiJUf9oeSQmHtfBwPI4wgakS4OGg=;
        b=jjx4Ou4H+n3dL6wX5DopdQ6gsDiO5Pt20ywBnO+jQcvRKLntZT3+m/DNjc48s7NnKq
         IfxwwtYzCEkuzk6P7grI9QbTj8DNDgCDEtUIKrufeBKOs7ORlkQDKP1Z84d3EM8HVbC+
         aUpk0yZ09r0wEOdB9uF1Ni5562PujB7fFXioy8EtL9Z+9UpsFIoqedQvz1dS3MmJUraE
         8nkQuqd82JBoZ1dnH7VBJ4Lnipaw//+8EHMDw7vvGYq5yJNI/2a5kUuclXV/12MALszQ
         sOCGqSLbhMAupAvtcdO8zFhotp33LzDbVoJV4ewJI7NmdU7gUFsfkjroKbjO69K+aJ7D
         1V+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:message-id:mime-version:subject:from:to:cc;
        bh=HBimVA7RGAjl4KbkiJUf9oeSQmHtfBwPI4wgakS4OGg=;
        b=JOSfWjMZmBhQuiR5qDYP3jyd0is2MNOuAI/8+5afS+/8cgybvXbuR+3gWP/jxb65ZG
         G/ckhDr4sWa/Fm2mPty7ejGpWXR8xQdCfJ0NtHuEKX/Ul5238eHO59FGxNUGh+5izAd+
         DVLyOyJTrKwCn+63wzIvKpBaAkOGw14bnz5PlUelFNwGlCVrR8wfu2xyDPl6vCfDxzYN
         WHe2fXQBzAh2piZMNyZbkJs/P41zjyTP+woDroDdyhzvlKuvURMmFuzDE2Ms0W/CHiMc
         LGizibvavaZDG6cxWUbSTMYYjxJpo3RaLB8ZjuFBcpjk9pFwU+1rnjjT1/vxUgp1jpn8
         LY7w==
X-Gm-Message-State: APjAAAXZ9w3+tYBzhnlEZmdxDqu1ZdGWzKAFcREfz4f/L2PTSTtrRnrR
	ltKtxeSPfRhQL5w/02yMkBzDnsic6J8=
X-Google-Smtp-Source: APXvYqxF/OVFaAI692aefwVIYjWorhp0G4V6pek3jNvuhrx3bB9EhyLN8VZ+oIxefHKqp7yjq0PX2SF1+44=
X-Received: by 2002:ab0:20a6:: with SMTP id y6mr5661920ual.119.1568009424530;
 Sun, 08 Sep 2019 23:10:24 -0700 (PDT)
Date: Mon,  9 Sep 2019 00:10:16 -0600
Message-Id: <20190909061016.173927-1-yuzhao@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.187.g17f5b7556c-goog
Subject: [PATCH] mm: avoid slub allocation while holding list_lock
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If we are already under list_lock, don't call kmalloc(). Otherwise we
will run into deadlock because kmalloc() also tries to grab the same
lock.

Instead, allocate pages directly. Given currently page->objects has
15 bits, we only need 1 page. We may waste some memory but we only do
so when slub debug is on.

  WARNING: possible recursive locking detected
  --------------------------------------------
  mount-encrypted/4921 is trying to acquire lock:
  (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437

  but task is already holding lock:
  (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb

  other info that might help us debug this:
   Possible unsafe locking scenario:

         CPU0
         ----
    lock(&(&n->list_lock)->rlock);
    lock(&(&n->list_lock)->rlock);

   *** DEADLOCK ***

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..574a53ee31e1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3683,7 +3683,11 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = bitmap_zalloc(page->objects, GFP_ATOMIC);
+	int order;
+	unsigned long *map;
+
+	order = get_order(DIV_ROUND_UP(page->objects, BITS_PER_BYTE));
+	map = (void *)__get_free_pages(GFP_ATOMIC | __GFP_ZERO, order);
 	if (!map)
 		return;
 	slab_err(s, page, text, s->name);
@@ -3698,7 +3702,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 		}
 	}
 	slab_unlock(page);
-	bitmap_free(map);
+	free_pages((unsigned long)map, order);
 #endif
 }
 
-- 
2.23.0.187.g17f5b7556c-goog


