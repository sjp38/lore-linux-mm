Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F57FC606C8
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE1ED218A3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:38:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YfLFUrl+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE1ED218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B3A8E002F; Mon,  8 Jul 2019 14:38:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31BB48E0027; Mon,  8 Jul 2019 14:38:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2326D8E002F; Mon,  8 Jul 2019 14:38:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01EA28E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 14:38:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g30so17146869qtm.17
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 11:38:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=R3lVu/iKD/K+MkjqEazvwur7I01jMg1dkzaZer2S9oA=;
        b=rYtB9ahJ9JQaRSEqyU9kPCVSkFfWSY4e6TSd9jtMeS5y30lQblrOGU/tP8ONwtJqhX
         8z8ozR0U6KCaH7Zc1NXnZrOQaBcLJQAeWGY3xZHxu0B/wEv+f2YhmSq7LyzmbkJOsKkf
         d9raiVbL++mJQhMTvgEVILmD7a9vCWV8GtlHgfyt640WWiE3RxDuqsi5JSuErIsLoQfV
         lqQU7MqIw7XW8Uyj3nw1u3+yz4gwPAUH6ob0D6NQvGpii/Mj9XBf0qMQOiN7ID8mNPo6
         ImoOpxljXuiGgwGfozNzPod1rr+jBRCI2DykqddrcDOVXgJubSR6mDzcvmGS/qGQISop
         upeg==
X-Gm-Message-State: APjAAAUaaLKnd9fSGDq04QiowXeuA8zvR198COKRgn71J/dru40FmXQW
	Vtm63Z4YwSpGlYG5VCje2J81cmIlQfCr8nVwpw3UlmCm6fqBHNlo2ea6MVY6uiu8y06rzTYEVNJ
	uTOkaAK8WDRAwMFHs1s+jIzQBAnFDqBbCH6GBzCNnmkAd7ZwiiL4fX0cUE8LQgz9ZDQ==
X-Received: by 2002:ae9:f303:: with SMTP id p3mr15313208qkg.320.1562611108667;
        Mon, 08 Jul 2019 11:38:28 -0700 (PDT)
X-Received: by 2002:ae9:f303:: with SMTP id p3mr15313184qkg.320.1562611108023;
        Mon, 08 Jul 2019 11:38:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562611108; cv=none;
        d=google.com; s=arc-20160816;
        b=tlHxF0ClEoCOo19KysJsyDMm5j4N4+D5Vw9ukPnLNdsTCSmkxP7fefKSq0Jn86uHJy
         mNL2I8YLug3loZwXD91gw9dAdt+dkGFU6BjhRowHlaMYuhxwkmgNDzpGQvzdzJXB0VN3
         Fx4jg7DsDp2A7EFko7suJeZBk5OhMH7OYoiA8QzpJXrB78JSoCNt0j+62+FJUFPllUoq
         hQ45MeWXOjGQLviGP5C/bFZ3gdvDOyfBawHZaf0qfEETcbx7is+TdfmsxLheggUc0uwp
         fFxYU4NlXDMUNqThgJevbksuZTgUwuaxgBdCFO8jZIj7PJKeulJSHtMOvlQqFxvvcth7
         KrVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=R3lVu/iKD/K+MkjqEazvwur7I01jMg1dkzaZer2S9oA=;
        b=AxXhmx1wP5UtuP2+twsG3R2DSfPQ6Bj0QuvRNfv1TGBEqRa7PcyCUkGdPv7XfpS6ij
         +ESoUI1yPn9ISUeZhrRWTAlirpIRAsxxG55S2Meljb/9c/GxpPvwmhf7bkGb6mwUhpeW
         AM+tWDpudatCaSlkoec1lJFX498wCCFL1TQTB9wP3UIipMXbd+PgFoZ8aIOMAMF6ndgs
         5WAjQlXNJyI6whvIJsfxYunTggR723XEZ5byr8fuZye6dX3P+VrPOE/713QO743VgPPN
         x3N22JuL74B2W9ybbsj4ADpJyGQ+oKi2PwZb1MBWbH3W8o/blOEf5mvGxmZi8qq33GL3
         qwDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YfLFUrl+;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor15353266qvc.38.2019.07.08.11.38.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 11:38:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YfLFUrl+;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R3lVu/iKD/K+MkjqEazvwur7I01jMg1dkzaZer2S9oA=;
        b=YfLFUrl+20e4r98mXvMBY+vubLWsf8qJEBjalOL+ZNXGcDJ8h6mD0JYgGd2qtlWy9R
         KjOBwepDq37okiS+qjuYomP8An36emcMIcuLAkDo3hy5tXg1uKH7R1uc66K3pjIJbbag
         tfrYWS7Wqx33+mYX9dd1Yx7385QxPTehGonBm+4IVYjtX9ulp468eIYUMTuMGZGut+mU
         vP+FeUzUYIE5ZMcnPXjoSpW/tBhQbcmlCjRhMOazoqZQlSj45dSl0tJDvs4N7w7dS3wL
         5XGrvlG5lQZwPf1npJjwIwwuASX4IF045nkLCzB2SPh6VBG+NA9ZIrZSwqAZ0UaIKXqc
         1trg==
X-Google-Smtp-Source: APXvYqxQ+GsKisl7JGXz4BZrXRf7Ul/53FWI6HeLxHv3uBB453gcAzlClCptgbI9Oj1fEazcQKom0gai0+TLra1rvZ0=
X-Received: by 2002:a05:6214:1447:: with SMTP id b7mr12745932qvy.89.1562611107655;
 Mon, 08 Jul 2019 11:38:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190707050058.CO3VsTl8T%akpm@linux-foundation.org> <CAK8P3a2KVPsX-3VZdVXAa1yAJDevMwQ9VQdx5j8tyMDydb76FQ@mail.gmail.com>
In-Reply-To: <CAK8P3a2KVPsX-3VZdVXAa1yAJDevMwQ9VQdx5j8tyMDydb76FQ@mail.gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 8 Jul 2019 11:38:11 -0700
Message-ID: <CAHbLzkr8h0t+2xs6f7htKZFdKDbsD5F4z-AAt+CDa-uVwSkQ1Q@mail.gmail.com>
Subject: Re: mmotm 2019-07-06-22-00 uploaded
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>, 
	Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux-Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>, rdunlap@infradead.org, 
	Yang Shi <yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 7:29 AM Arnd Bergmann <arnd@arndb.de> wrote:
>
> On Sun, Jul 7, 2019 at 7:05 AM <akpm@linux-foundation.org> wrote:
>
> > * mm-move-mem_cgroup_uncharge-out-of-__page_cache_release.patch
> > * mm-shrinker-make-shrinker-not-depend-on-memcg-kmem.patch
> > * mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix.patch
> > * mm-thp-make-deferred-split-shrinker-memcg-aware.patch
>
> mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix.patch fixes
> the compile-time error when memcg_expand_shrinker_maps() is not
> declared, but now we get a linker error instead because the
> function is still not built into the kernel:
>
> mm/vmscan.o: In function `prealloc_shrinker':
> vmscan.c:(.text+0x328): undefined reference to `memcg_expand_shrinker_maps'

Sorry for chiming in late, I just came back from vacation.

The below patch should fix the issue, which is for linux-next
2019-07-08 on top of Andrew's fix. And, this patch fixed the redundant
#ifdef CONFIG_MEMCG problem pointed out by Randy. Copied Randy too.

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b7a1f98..5c4b15eb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -128,9 +128,8 @@ struct mem_cgroup_per_node {

        struct mem_cgroup_reclaim_iter  iter[DEF_PRIORITY + 1];

-#ifdef CONFIG_MEMCG
        struct memcg_shrinker_map __rcu *shrinker_map;
-#endif
+
        struct rb_node          tree_node;      /* RB tree node */
        unsigned long           usage_in_excess;/* Set to the value by which */
                                                /* the soft limit is exceeded*/
@@ -1296,6 +1295,8 @@ static inline bool
mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
 extern int memcg_expand_shrinker_maps(int new_id);
+extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
+                                  int nid, int shrinker_id);

 #ifdef CONFIG_MEMCG_KMEM
 int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
@@ -1363,8 +1364,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
        return memcg ? memcg->kmemcg_id : -1;
 }

-extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
-                                  int nid, int shrinker_id);
 #else

 static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
@@ -1405,9 +1404,6 @@ static inline void memcg_get_cache_ids(void)
 static inline void memcg_put_cache_ids(void)
 {
 }
-
-static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
-                                         int nid, int shrinker_id) { }
 #endif /* CONFIG_MEMCG_KMEM */

 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2ce3bda..dca063b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -313,6 +313,7 @@ void memcg_put_cache_ids(void)
 EXPORT_SYMBOL(memcg_kmem_enabled_key);

 struct workqueue_struct *memcg_kmem_cache_wq;
+#endif

 static int memcg_shrinker_map_size;
 static DEFINE_MUTEX(memcg_shrinker_map_mutex);
@@ -436,14 +437,6 @@ void memcg_set_shrinker_bit(struct mem_cgroup
*memcg, int nid, int shrinker_id)
        }
 }

-#else /* CONFIG_MEMCG_KMEM */
-static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
-{
-       return 0;
-}
-static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
-#endif /* CONFIG_MEMCG_KMEM */
-
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
>
>       Arnd
>

