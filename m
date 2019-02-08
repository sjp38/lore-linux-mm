Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46921C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C50222147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:16:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="TqFW15Vy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C50222147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20FCC8E0073; Thu,  7 Feb 2019 23:16:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F1958E0002; Thu,  7 Feb 2019 23:16:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D4908E0073; Thu,  7 Feb 2019 23:16:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7E3F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 23:16:39 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so2315886qte.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 20:16:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=agY1KFaR2OSgzjqs4vJLxBvVgrMDEjyO83gUymZdJtI=;
        b=rVp5MF+qMv8UJlbmpv8F/88m7tLHIYQN6J2JHANH+P2gT8AcZEwWec7EOa/7uaaznd
         OC2peCWTtrcrYhhI6m+tc6VN270GFqynzTDAILP4YOx+0RsgE1GWu2x7UW0d4e7lo5sK
         5wWf9KW6O8w0ClM9xHIdGvEb8kQ41qkP+wmVKKbJ+cj5pLw7oEY5nCeT3AFxHNqg3yq3
         1nh6vA8UDY/lZ1/mBT4ZCPFTNjeys6bQpmWs9vn6ALd6Yt3ZzbxdLyUDlovE2dBQr0Nl
         7VAu3U7kxgO8dwcZg1n6kuRSuN1czSrMeBezewvl8VaMapNkky/cGqQcSplOXYhS3GuM
         FDxQ==
X-Gm-Message-State: AHQUAuY8CwjrFWRN/ZHQCkKI60Ii07xVmRvhh4MM4HjxJfoQfqUQYBWo
	tFzKv7Lr9R5te+ePCm0ZdvbB9Rz9wqoTRb3M9SFUOaZTm0JoGAYTWUAcpjd/Kb3AQ/3JB8G6ts5
	8pudRuGaweMFDhjVd9y3J2/IxV46WDrD/m5978AZgHitBwmHRppzDEC0qeFW5Eumsd7Rn7WgO/S
	c0V4S9pO/dck/N2GmRCrmlU/9EZUM3L/mVH6MbMnwC6vDQWKDZyJotCGLU5iSmEF7IRu6xA4vn4
	RZNILIhv4Qa0yJy6QdQFHgD+f6uQAeA9rYsHlYpMQbl0WUEyGP2ioeKLOdt4ySk6TdIXWcBY3hC
	33Feb6Gpncd4VVumCeJ74GJ+lap0uc8k5VPisR50hXXyIMVn/oH78DmRP2yBYtzfEbq+RcTBxCI
	+
X-Received: by 2002:ac8:7311:: with SMTP id x17mr13173447qto.109.1549599399555;
        Thu, 07 Feb 2019 20:16:39 -0800 (PST)
X-Received: by 2002:ac8:7311:: with SMTP id x17mr13173414qto.109.1549599398711;
        Thu, 07 Feb 2019 20:16:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549599398; cv=none;
        d=google.com; s=arc-20160816;
        b=K5r56XmagZXiHKyJ8UClImqxugL2KkBcxWQcSUWH/JsBIkgs0m1fruJlzxHULCqL5q
         I6LRSYhBifNKXlHh9kmn0wlHfB+CIKhz+YyODYTPPAUh3x1WYH+O/u+BE9symcHl2kyM
         USWPqw/6USKKv/gZAU92HnlDwuOlc7lUCfubgZV8z7kDnoHYOqiCtU9ACwvbl3r6uFrV
         PFQbrwtLwYzd35N8UnS3UpicBRaf7XCz7/v7v9Ou3SHmWMVDK3JeOypp8iUF8clP1TRX
         pnocv2MuBZhCq8rYy3atW8+Isi+Za8namSLR8qUimbgqkvA2/g9q7Qu8ODi9ZLB3W9SD
         1bJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=agY1KFaR2OSgzjqs4vJLxBvVgrMDEjyO83gUymZdJtI=;
        b=YQ/L4yLUCoOycaQ3xi2+rmoBzwqzpBccfbFOFFhz2CdFcaUWf8o3D6Po7JjLMdiJSS
         rv5nV3AWnYUDTaLgHZ4qXG7+kpC02Hje3i5yKVXF/CJWr3KLD4z3hpRY30qEEA/vkwC4
         MduY1vWdMiWljfYScZXX38WmNLUhnOWYCSOXkoH0r1iupcayK2hp8ohe4V7bWK6S8YEF
         l/0U5pQUS42A/Wm7UT7BNAnjQqhyhn5Nbq6j2CceXqCW+B2YPTMDeiKcxG7AgYMGhg1J
         vDZtdVtNWgsUxctlV9DQhH5fH9up5UfMSV/dEtcKrUDqe3ROltbkxrcVEKYbnjyTtWYo
         0hBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TqFW15Vy;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o29sor945441qve.37.2019.02.07.20.16.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 20:16:38 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TqFW15Vy;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:from:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=agY1KFaR2OSgzjqs4vJLxBvVgrMDEjyO83gUymZdJtI=;
        b=TqFW15Vy36bjFFtgCGjeWab4VUOZvYd6pz4JjZXLvEclNzjTq7+QR5TmWxOIXMZxCf
         t2IynhqY3aFUBHC1gFn1yoftUchN44ZDpK1AkuUJ4wfuQT5ERJt0YEpVt5tkh8b+gz0F
         M/RY8O/9U8a0AhhLiSjjTkRZXvVpOuJ8YHTgvh4Y0faiQRyEFqZqooI/loVC9wjC/Y70
         xKCF07MVQeyaqCzZb6Vr2DWhotJJzRy3dGj6Zh0qrCYulvI5o8WKhw/SUo6WmrJEO9HY
         krmkgMg93sYqeCslsuycMvQkFknKsbCeY7/7TPntmVGLlOElPY6oNliCAjk+ig8rlQhM
         gidA==
X-Google-Smtp-Source: AHgI3IYQnbYc1sJWjOZznmL01VWnie+lPsdeAQO/NHdMQx/8O0cJgvIOH7sqoLwz1zq4RPVnO6mvXg==
X-Received: by 2002:a0c:f7c7:: with SMTP id f7mr14824049qvo.167.1549599398269;
        Thu, 07 Feb 2019 20:16:38 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id i64sm1388706qkf.79.2019.02.07.20.16.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 20:16:37 -0800 (PST)
Subject: CONFIG_KASAN_SW_TAGS=y not play well with kmemleak
From: Qian Cai <cai@lca.pw>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux-MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
 <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
 <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
 <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw>
Message-ID: <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
Date: Thu, 7 Feb 2019 23:16:36 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kmemleak is totally busted with CONFIG_KASAN_SW_TAGS=y because most of tracking
object pointers passed to create_object() have the upper bits set by KASAN.
However, even after applied this patch [1] to fix a few things, it still has
many errors during boot.

https://git.sr.ht/~cai/linux-debug/tree/master/dmesg

What I don't understand is that even the patch did call kasan_reset_tag() in
paint_ptr(), it still complained on objects with upper bits set which indicates
that this line did not run.

return (__s64)(value << shift) >> shift;

[   42.462799] kmemleak: Trying to color unknown object at 0xffff80082df80000 as
Grey
[   42.470524] CPU: 128 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc5+ #17
[   42.477153] Call trace:
[   42.479639]  dump_backtrace+0x0/0x450
[   42.483362]  show_stack+0x20/0x2c
[   42.486733]  __dump_stack+0x20/0x28
[   42.490276]  dump_stack+0xa0/0xfc
[   42.493649]  paint_ptr+0xa8/0xf4
[   42.496934]  kmemleak_not_leak+0xa4/0x15c
[   42.501013]  init_section_page_ext+0x1bc/0x328
[   42.505528]  page_ext_init+0x4dc/0x75c
[   42.509336]  kernel_init_freeable+0x684/0x1104
[   42.513857]  kernel_init+0x18/0x2a4
[   42.517407]  ret_from_fork+0x10/0x18

[1]
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..70343d887f34 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long
ptr, size_t size,
        spin_lock_init(&object->lock);
        atomic_set(&object->use_count, 1);
        object->flags = OBJECT_ALLOCATED;
-       object->pointer = ptr;
+       object->pointer = (unsigned long)kasan_reset_tag((void *)ptr);
        object->size = size;
        object->excess_ref = 0;
        object->min_count = min_count;
@@ -748,11 +748,12 @@ static void paint_it(struct kmemleak_object *object, int
color)
 static void paint_ptr(unsigned long ptr, int color)
 {
        struct kmemleak_object *object;
+       unsigned long addr = (unsigned long)kasan_reset_tag((void *)ptr);

-       object = find_and_get_object(ptr, 0);
+       object = find_and_get_object(addr, 0);
        if (!object) {
                kmemleak_warn("Trying to color unknown object at 0x%08lx as %s\n",
-                             ptr,
+                             addr,
                              (color == KMEMLEAK_GREY) ? "Grey" :
                              (color == KMEMLEAK_BLACK) ? "Black" : "Unknown");
                return;


