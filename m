Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E71CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:04:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59C4A20663
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:04:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sYFeD6TH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59C4A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E794B8E0002; Thu, 14 Feb 2019 11:04:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28CF8E0001; Thu, 14 Feb 2019 11:04:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3FA08E0002; Thu, 14 Feb 2019 11:04:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF5458E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:04:00 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i18so4794455ite.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:04:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=LMMCuwulD/4U8krzNsFeJe/3gdpanzjXyzK8S2//JGE=;
        b=bCWF2zPuWnohcDBv/wY1XIMsm1wZDFpWMm6dpIodT/AseFcIN9CldZkDama4s7V1uR
         tQKn/TfI3oU4/c09ZjtnQOpE0y1aJU3ET1Ub5nqusF3o4EgB9YYKXmkTqIQu6BD3Q1hh
         sCOY/8RTNhxdy1S/mHXIspoox56dSjqTABIJ+rJnobReU+W9BTzn9LTcoFIrniIGn49z
         3CGqJ28qr8lr8dpC/we/iF09C2R18NipP6Dm20g45NMJWy/10YJnn7cWTyOBsdT34lYI
         264YArIGeJdfDv7X4fdZEKPDVplk4eNyktzXqGJ9cMsoRYKB0Z1rnrDtXA6Xs1My2pho
         1/+w==
X-Gm-Message-State: AHQUAuayCsDH1WzvTs/lg1bOd1Xr32cY7yDHFlaqyIt5PdBH1h0BjIGl
	Kzzb3mkVZRHRfO6mha/AR4g45hNekH4W90wa/85gDziIDtw/rmzj49myrZPMs8NpVGDFLL9TgD3
	EldCm4PvOyaxwj9ddn3PsZhci3oJId5FLFOxH00pvsmbbd3QeTyrOKJdphUf1zSujwR+iyA5OxA
	72XKND5d16m3zp7NGvH6IEHR1ksc04Jr3lQ/xMjGWPSo+Itr2pypcuXVZt/4j1T0uhx3MtpzbF0
	+mpm4Viky8oYdMbgTt5IX22I5694/1kh0GtfXnmU7wKuw861tFiVTJaKBlh2jWXCwTbRoHsjFqv
	UQJm+qhA6kKZbv02S0KNXhUazAfId2uLBCh7hSlHNC4gugqABJdcVdq0IIrCR4wD3CGReK9uOXH
	m
X-Received: by 2002:a5d:8946:: with SMTP id b6mr2409223iot.231.1550160240488;
        Thu, 14 Feb 2019 08:04:00 -0800 (PST)
X-Received: by 2002:a5d:8946:: with SMTP id b6mr2409167iot.231.1550160239693;
        Thu, 14 Feb 2019 08:03:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550160239; cv=none;
        d=google.com; s=arc-20160816;
        b=MDeRpok3iaNEwIhqs6LgusxIBDs6b1ueb/OH/8UqXqSpX11EurJ4C9WXr5rRrWqDni
         djPVUC2rP09gl1JaYp7hgv7g9i3yU1ldHKaUQyx5XoK3rfmfCBBO88H31YSKhdeu96sW
         SHJ6JuYbt4VkYZETlhcqU1BCZAv2LRRS0/vkV0D+DJrznf1vHizRWYdIYs78wDadvdNW
         yxTA3pzpx5tpoMcNpKvmF1uQZLf31kGEyXOJbD3WOlZ3Soxl8n1m3iugzRC2BA3z7iSG
         u+9wJtJcEhVpQf3qfcZC5ykXpAscS2S6SRBQrPgBgB4ci/h8Fhds61t63xoycwOdiNfq
         LC/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=LMMCuwulD/4U8krzNsFeJe/3gdpanzjXyzK8S2//JGE=;
        b=h0PKJVFJjal7QEhnTd0z/Hu5wvIoBxbffNzEjX4B65xNhAM/0XbQNA1FBH45wtvzy2
         zlUFshUbQXRXfP/xhzW0FEQK3UYISWZAKX1MZ8qVFABWyQvJMJwigg22yTgiCe/oJ4Gg
         HgAgiK1UD7T8/cFrPql6AUqQejHDWSOE2y4KwNKU/U7EUrECH5GtKnSFkORNTFgE59lZ
         jK5NRFNzZMLDVfGblP+iKr0oGYwnAlJHnuzqZbpTo/tsg399be0zW7p8TvfZw3kc8kR4
         ZsWL5AwYJ224nG3qgE5JsjF7PODliQ38RxWNBR6whAxwyFLInW+vXJCGEWfu7yh0QfQl
         lp7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sYFeD6TH;
       spf=pass (google.com: domain of 3b5flxaukcbi1s55zy66y3w.u64305cf-442dsu2.69y@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3b5FlXAUKCBI1s55zy66y3w.u64305CF-442Dsu2.69y@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t134sor4837825ita.12.2019.02.14.08.03.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 08:03:59 -0800 (PST)
Received-SPF: pass (google.com: domain of 3b5flxaukcbi1s55zy66y3w.u64305cf-442dsu2.69y@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sYFeD6TH;
       spf=pass (google.com: domain of 3b5flxaukcbi1s55zy66y3w.u64305cf-442dsu2.69y@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3b5FlXAUKCBI1s55zy66y3w.u64305CF-442Dsu2.69y@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=LMMCuwulD/4U8krzNsFeJe/3gdpanzjXyzK8S2//JGE=;
        b=sYFeD6THGVUp5WphhWTj1Ubt/fdAYefIIH++4LXXYYHZD+T88HZIwTslFAMpi3MQDE
         DY2SuwPu8hWWzDRJ3GDmA+O2/ZbrHmR26sRL45JKqqqMKiyiimyeeHoFTDuuT3Ccbkpj
         29UPAnOO5IZ3GiHcxZQaaLlB/uhP3kRznkQHpdjLTk7N0u7eg2m93CWCUrNnv05LwQ4Z
         HNTB+/GAE6sWq7rRvpfoMOVjBYXnCvGDJHfOYl+EEl3Xk7XPjjh+2zhq0qVSe11J4KR7
         G1SXinUEoYGbWhtsLgeUQAmy81PurKEE3cgr5vJMoe+47MDvsY7VppV/2MQB4XY6LHac
         OPag==
X-Google-Smtp-Source: AHgI3IYn2V6oFFy2kAe3b//vB9567tnSNHvUsoy5juN0lM0WfW1jir1J3r8aK4geTP5uVA1GoJWcIyo6Vg==
X-Received: by 2002:a24:d82:: with SMTP id 124mr2780889itx.10.1550160239377;
 Thu, 14 Feb 2019 08:03:59 -0800 (PST)
Date: Thu, 14 Feb 2019 17:03:47 +0100
Message-Id: <20190214160347.13647-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
Subject: [PATCH net v2] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
From: Jann Horn <jannh@google.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, jannh@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, 
	Mel Gorman <mgorman@techsingularity.net>, alexander.duyck@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
number of references that we might need to create in the fastpath later,
the bump-allocation fastpath only has to modify the non-atomic bias value
that tracks the number of extra references we hold instead of the atomic
refcount. The maximum number of allocations we can serve (under the
assumption that no allocation is made with size 0) is nc->size, so that's
the bias used.

However, even when all memory in the allocation has been given away, a
reference to the page is still held; and in the `offset < 0` slowpath, the
page may be reused if everyone else has dropped their references.
This means that the necessary number of references is actually
`nc->size+1`.

Per Alexander Duyck's request, use PAGE_FRAG_CACHE_MAX_SIZE instead of
nc->size for the bias in the hope of making the generated code slightly
faster.

Luckily, from a quick grep, it looks like the only path that can call
page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
requires CAP_NET_ADMIN in the init namespace and is only intended to be
used for kernel testing and fuzzing.

To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
`offset < 0` path, below the virt_to_page() call, and then repeatedly call
writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
with a vector consisting of 15 elements containing 1 byte each.

Signed-off-by: Jann Horn <jannh@google.com>
---
sending to davem as specified by akpm

changed in v2:
 - use PAGE_FRAG_CACHE_MAX_SIZE instead of nc->size for refcount bias
   (Alexander Duyck)

 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..7f79b78bc829 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size - 1);
+		page_ref_add(page, PAGE_FRAG_CACHE_MAX_SIZE);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = PAGE_FRAG_CACHE_MAX_SIZE + 1;
 		nc->offset = size;
 	}
 
@@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
+		set_page_count(page, PAGE_FRAG_CACHE_MAX_SIZE + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = PAGE_FRAG_CACHE_MAX_SIZE + 1;
 		offset = size - fragsz;
 	}
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

