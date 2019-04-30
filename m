Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD913C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F4BA2075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DQlymDAa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F4BA2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE9B06B026B; Tue, 30 Apr 2019 09:25:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D99EE6B026C; Tue, 30 Apr 2019 09:25:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65536B026D; Tue, 30 Apr 2019 09:25:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9086B026B
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c2so11810537qkm.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=pQaENO1QgY/e9MwQ0ENVfJipTlkpkaPmrD1twTVYLJ0=;
        b=W7pBiSsVHz0EKRNHVP2A/glh1q0ROwb3lWrYdph36IHDV2WpIt+JSumwg8wKVbpma9
         1jax8e8jYF1UgWoHJEwkEx62Labn2V/zARfxPQSEpEZWHviotvwwsjdoj2JlclvrTjvY
         jpuM13vw5DW1YY9iDXy9K+opgpdIQhdOxihg/uBDgNObTaHHJr++G3EkHnNi4/mvZsV6
         KB0y/S2DSIwB3ydtNrE8lzz7q7juA7cvADSQYcy67ldLA2RWQNIOz7kWsOpR+oggA97/
         iyPDupi7x0wqTRVJz1mRZTfA9Tzv1N/DFqbHPEDHDWqdRf7CevElhIn/TtCYYzQc8egg
         GmkQ==
X-Gm-Message-State: APjAAAUo5DjSztOq2msXkASn1bhSuKfhf9qPU7veWM2eSII615ZvgZHI
	uCYpxiI88tTgYCDL0aiLulnBrvwLVeh9rhWayto3+aAE5sYC7uXe1+0j+SC2O+bWZAxUxvrqJBu
	XpfG16dqqaRwmmCoZJWMRv/LuGF7mhbPtGNkpyZ8yLCJBes0ETU8D8KXAcCHqn+srSw==
X-Received: by 2002:a37:b3c5:: with SMTP id c188mr49695802qkf.97.1556630749424;
        Tue, 30 Apr 2019 06:25:49 -0700 (PDT)
X-Received: by 2002:a37:b3c5:: with SMTP id c188mr49695749qkf.97.1556630748697;
        Tue, 30 Apr 2019 06:25:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630748; cv=none;
        d=google.com; s=arc-20160816;
        b=ZuxL2ETZjonQLoFbYmwVgi8GVnQOA+uAUbiihutn/PHWZ+Bqf9ghsf3+yanmss2MRP
         YaqlkqFSDusPrC6qSPaJPLPetQc3VmDhn6nwmfmKEDRn2BbVj7naPHw6nWQH8JPqH5at
         SqMqBhh6nSV/QJ8rahn08DD2XCXCBi0rF4JOfGUsVcxnQlhgpEcFuNkUR+rq/NpPOdto
         OV4FWoTytGihXamQDDyX4rN5YuvWB9kefv+iM0wdRNdTrI3i9Uy/cmYzGtMuKUlLxgaA
         wdRMDE3PblDEsenqUsEz3BjNi6d2WcCC/ScOxtwcbm4q1z9/qiM3sAzkAmpLBwu+2DSv
         BTdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=pQaENO1QgY/e9MwQ0ENVfJipTlkpkaPmrD1twTVYLJ0=;
        b=se5f9ZUEW7NEpnpghy+v4Ync7XvNZBFdbyO1xIsIVM5hpLtYfCbL0caMl7uxQDJWYL
         UVguG5QcYq/ByRvW5fBsFg/yxqs1MApe6qOaePyiUElTczLYiM5t/z1xr5l/euSFwZnZ
         aG2p1IjdBXKnwpMgrphZq8HoibpOwCZMbke2hV0wJZY2Kkg5sH+EQckSwfo2XE8Mas2a
         +2pO/F4msIoSEIAEltCTVhQP228Ro6Kg6Ukb05TJD9AsGKDLNOZeFsYoB8WYUy6TwIB9
         lX7err0w8JBAqZ/RVi0i4bpt7ntfsK2dr1Rzpigjr05ngQctOzjDv/geeFBxhQEJUrs3
         zuCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DQlymDAa;
       spf=pass (google.com: domain of 33ezixaokcimhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=33EzIXAoKCIMhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e39sor26370626qtk.2.2019.04.30.06.25.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 33ezixaokcimhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DQlymDAa;
       spf=pass (google.com: domain of 33ezixaokcimhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=33EzIXAoKCIMhukyl5ru2snvvnsl.jvtspu14-ttr2hjr.vyn@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=pQaENO1QgY/e9MwQ0ENVfJipTlkpkaPmrD1twTVYLJ0=;
        b=DQlymDAakXGN/s4aLv8FvnKDxFM3vFWe0ntwkbEht00uRZJyqzxLv2z+v+0YWcHIgB
         sKEjfbgI8NGPishfLFVkzFtit1j8To4k9tOzAqlClb7eaOmN2puCzEFRoWDOow3x6abM
         kF5rtq7WeiaNC1bvr93O8cSv4wiLQYr7p1i1gibkW3E+uyrFOpeeQawgxMfeq7+k8NA+
         lhqPJjcIYupZYzc0GZblGzb4ejeI2t/6j/U8CyZxFUtArO4WewVdwtuEJHeP7D/0QDFm
         3J0WxXCQ6Yi/AJW67UTm3sBwIOkc0wcf7BPZUgJdkZ1LyiC4qY/JaOc6zgNq+gGsc78b
         WDtw==
X-Google-Smtp-Source: APXvYqzXVakUsCoJZt28GHuUY2fVSxrYrmmdkh7uTay5rLBg9HnfxGjKEfUnDj0v5eIkWQX2umWuPHIlib2dmYL6
X-Received: by 2002:aed:2a0c:: with SMTP id c12mr9957100qtd.232.1556630748252;
 Tue, 30 Apr 2019 06:25:48 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:06 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <7d3b28689d47c0fa1b80628f248dbf78548da25f.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 10/17] fs, arm64: untag user pointers in fs/userfaultfd.c
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

userfaultfd_register() and userfaultfd_unregister() use provided user
pointers for vma lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f5de1e726356..fdee0db0e847 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1325,6 +1325,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
+	uffdio_register.range.start =
+		untagged_addr(uffdio_register.range.start);
+
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
@@ -1514,6 +1517,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
+	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
+
 	ret = validate_range(mm, uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
-- 
2.21.0.593.g511ec345e18-goog

