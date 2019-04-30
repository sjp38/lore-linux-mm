Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD35C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 736B32075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wJdQ1UGK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 736B32075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1906B026A; Tue, 30 Apr 2019 09:25:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8440E6B026B; Tue, 30 Apr 2019 09:25:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 732B06B026C; Tue, 30 Apr 2019 09:25:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53C136B026A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:46 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so11782068qkf.14
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=XhTfun6kQ0RRzRGxeYV1Lxl9M9fvGqRUvmzO5QW1/Iw=;
        b=FYWHAgRNrz+Ystt92oUmP3a8/PjtfFvFjTRAOAKJYOOa7+iBhnYtf18TElSQ1uF+5/
         VovSqFzr9VOoBbCipO4CQg/BoFn4uNVwoScURSCRGC87vzuL4TMOMoOVTpI9NoPQqGiJ
         e2/mu1G7yk2f+kuy5K5ahkJC4imlHNnErCy5bJMxnfMQMVmHpEgJzog1LldsTftz+adF
         mT51BGErTBf5nwVc4iRHKoSGCdSVHlLxRMrdBLvesM3SAbR79Fg2E1j2+1BG1er2SQ9C
         TFQIgtY7uYCRYoH6AYuxSAR19wrhco/JyGqEBHjFz+wkZbYAVIN2Lsm47Q16qpGcLq6D
         +MAg==
X-Gm-Message-State: APjAAAWuSoyULZ81K4v8Sb9fHGonSLKQFPQ//0nxBBpNyZy+0k0WKh53
	Xure0plaz579f5jsJ1iPo/4bCKHJDySHHfadz4E6cskiUKwbb2wtkX6uDQJZJhHRGaX0LAd5B+F
	KeBUThFADTCAZloGCUgsB9vjjXH5PgINHfQcoxZoMjZPmAYmL3S2A/HWTUE3iEw0GaQ==
X-Received: by 2002:ac8:918:: with SMTP id t24mr10424097qth.92.1556630746067;
        Tue, 30 Apr 2019 06:25:46 -0700 (PDT)
X-Received: by 2002:ac8:918:: with SMTP id t24mr10424051qth.92.1556630745511;
        Tue, 30 Apr 2019 06:25:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630745; cv=none;
        d=google.com; s=arc-20160816;
        b=HR1EOyHQg76MyAGg6ozunGadeN87Z0dn0EpDPOHn3D7oDXV76rCfxQRDRl0K6vhbup
         ivojKBHtM+s4lj38jKgFzv6rXIMOnzV8osUy46K253A2KXIdZGhZyeSLUrqjKfmlrtvO
         ibxqs5Jjfme17OFaO+aCYG3os8nmzoqY2tk2AC3SbCxKK79et6uqqCHWIL5SXc4LeUwM
         LyzUHZ+WN3J/QYyRojMJigOlPT9U/NzIJguY+Qx4wvk0cWnuyrXqKvIkcCflqjUDVbjY
         NX1Ng0LBQ++9bbn31tzujzxybMCG6rfLwZBRXnLWCCxW8y/hSAuSthVZA8yd/PHyYhVX
         uAIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=XhTfun6kQ0RRzRGxeYV1Lxl9M9fvGqRUvmzO5QW1/Iw=;
        b=afWfaNbPKG6GA08NdHl0mPzdzsjoEMGUykgFJ6LzoQ2/lvF1Fi32Xefq8YqOO/2wqx
         imc08xOjXdEvRYfMrsHpkIZKYk5F2QhKOIRhf9NhTeESmYmudQ3lp99yMysSrSQ/zkca
         3KGVH4BEW0IaC6p7i1II+AgI+cXSLjwJZZqdVjywnwKimEllKjk0FWI2h0iXE9Iy4Tw7
         M7KDW1avD1l2war+rSFEkhQVn23nrM+VwfrsdaSBmcorWbwgDHtCViMqPikOWI/LbOsK
         90Z08xD4Sw/LLZ0EphpFWKaxkJWYRjBgaL9ooiyrW2N8yTaIDggITz6P3Uva4Hdjx9hB
         t/OA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wJdQ1UGK;
       spf=pass (google.com: domain of 32uzixaokciaerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32UzIXAoKCIAerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i125sor9599200qkc.80.2019.04.30.06.25.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of 32uzixaokciaerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wJdQ1UGK;
       spf=pass (google.com: domain of 32uzixaokciaerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32UzIXAoKCIAerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=XhTfun6kQ0RRzRGxeYV1Lxl9M9fvGqRUvmzO5QW1/Iw=;
        b=wJdQ1UGK5yN+4uNr4h/B5QAZg4CL5PwyVx/Pw0wXlRL/1oGZsU8xxjXpZhWnko4SRI
         fd58gicIFCILzVPy4t7gpYBYkZYkBR3FmblDk49rQtqjc+3RWgZP2PESfhPKYuSabBw/
         B0hXw+/teu1vbGfMkq/9KC8ilccnVzEvxDboYdIBbHp/DJQFCI0D5tDe+o/VISE54DyV
         St7L+ZfiWURBvKb49SaxC44tIWiHtqDmkV/TM32oplri8v6dnEdHN+6rXyhwe32Swezt
         x0OHZZDCsWZFgoiC74TFCi6OtAop9i/h8/+cUKSH3r+foqub7XosNX+XNvDEf+4uDkZz
         /4Vg==
X-Google-Smtp-Source: APXvYqznoxmsWRf0TRsMetoUzYzE4dAnT0nzUuom4UB8P1UAcmj3+/tm6hiTUWLYkHc/SM6nPM/1vvtkZ4BWAaOU
X-Received: by 2002:a37:b683:: with SMTP id g125mr147309qkf.249.1556630745179;
 Tue, 30 Apr 2019 06:25:45 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:05 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <f7a89f69f95e471f161e4000d0e13f57364bc90d.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 09/17] fs, arm64: untag user pointers in copy_mount_options
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

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c9cab307fa77..c27e5713bf04 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2825,7 +2825,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.21.0.593.g511ec345e18-goog

