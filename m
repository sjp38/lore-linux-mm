Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BCB3C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3CB6208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mJDejJWU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3CB6208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1E0D6B0007; Wed, 11 Sep 2019 22:31:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5346B0008; Wed, 11 Sep 2019 22:31:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90F0F6B000A; Wed, 11 Sep 2019 22:31:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7846B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:31:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 11C56181AC9C6
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:20 +0000 (UTC)
X-FDA: 75924691920.18.trail26_45d066bb16c54
X-HE-Tag: trail26_45d066bb16c54
X-Filterd-Recvd-Size: 3716
Received: from mail-yw1-f73.google.com (mail-yw1-f73.google.com [209.85.161.73])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:19 +0000 (UTC)
Received: by mail-yw1-f73.google.com with SMTP id k63so19619286ywg.7
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:31:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=VTFLG8eFeKeX5rA9A/RF+SH0kKZbbcZcTGiLOknhM8o=;
        b=mJDejJWULbF2e6+PZwAkN+YGqXTd60leJIfoP5qWwNzJgFkWguAYWTXbJHoH179vfN
         MNo0gETMkGUgE9ahWgfnQnCguxv1zyWyfPQ2DrDntXMldyLa/Eo2kA3/Uq3jteAPcB55
         nTHNFlL0yZ/2vjoKxpDKIwjz1eYcjWO8Lf3MSwzODBLqcW4yQhjRRDjxezY2S4aWPYGy
         xHY7O/sD6nsAljyk2+jSMl+/UwCn8y3E9kB9WBwDIk9tP0gLmlthNDbAH9+ML/wDsIgQ
         EidIO4tIrVes2jrRn+rlnMICcIwA3NOOhfV+FnqdnFh1yhMGwgu7Mfk8vPa0cj1OJJTB
         AYhw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=VTFLG8eFeKeX5rA9A/RF+SH0kKZbbcZcTGiLOknhM8o=;
        b=oQ+ONbr/93FntIzq69d0IoXn8d1zt0R2jauGGPO8GZqUqZErJoZ5A9vfSweEp5dUuH
         YawMFQWfyovYlu7di65l9H45zLv6uCM2U1drB2JYEd771ai5K2TmQMDoSxtc2hNZJhyz
         pOyKaxcDYnhQYQaEWVsK04U8rQGuJjot3FHlamH2XSkASo3JceZbmJokDAc827bcTBsN
         Z71XGbz5ua50TkBLfq3NLEz4RyRDpJ6bIZtCzX6uP4ZqPqEZqG7PSdfMH7933kafXq2W
         vJZyARZ/TePh0VpvtoOsjPFcxddJRP9FzefxDtdITbWmIfB+NvXb3hKktVUXEeD7YMlv
         q6VA==
X-Gm-Message-State: APjAAAWhJ9bgOGuWApq+0FcbgNj4J9OoYMbMQVPhZxD66b1gccLXe93+
	rl9E54568gJrOVI3zLSuEoJRsjlBMWo=
X-Google-Smtp-Source: APXvYqwFp1R2W1Gg2Sjd02Xx4oKgaWAgWIlzHHZq+eTFExQ7YKzFQaF9vo3upTYjh4PTecTa61D2xskYkN4=
X-Received: by 2002:a81:4e8d:: with SMTP id c135mr28278227ywb.149.1568255478967;
 Wed, 11 Sep 2019 19:31:18 -0700 (PDT)
Date: Wed, 11 Sep 2019 20:31:11 -0600
In-Reply-To: <20190912023111.219636-1-yuzhao@google.com>
Message-Id: <20190912023111.219636-4-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912004401.jdemtajrspetk3fh@box> <20190912023111.219636-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v2 4/4] mm: lock slub page when listing objects
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

Though I have no idea what the side effect of such race would be,
apparently we want to prevent the free list from being changed
while debugging the objects.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index baa60dd73942..1c9726c28f0b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4608,11 +4608,15 @@ static void process_slab(struct loc_track *t, struct kmem_cache *s,
 	void *p;
 	unsigned long *map;
 
+	slab_lock(page);
+
 	map = get_map(s, page);
 	for_each_object(p, s, addr, page->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			add_location(t, s, get_track(s, p, alloc));
 	put_map(map);
+
+	slab_unlock(page);
 }
 
 static int list_locations(struct kmem_cache *s, char *buf,
-- 
2.23.0.162.g0b9fbb3734-goog


