Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3557C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A84E82173E
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:39:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="HKq8Duys"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A84E82173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A8D6B000C; Mon, 20 May 2019 17:39:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ECAE6B000D; Mon, 20 May 2019 17:39:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4A66B000E; Mon, 20 May 2019 17:39:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D502A6B000C
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:39:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so27307664edc.4
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:39:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=DucpRdkRgOoCBrOy6KiJUJJfWEr/7+ZCIIaJ4AvhfB0=;
        b=qQMSbpPIVHRZc12ws2w8r9iwPsH4DSRxyZYUJZMysomKr/U0pdl4e3mgkB5PwDBjDI
         IBhGnSTt8cHYtKO9LUiO+Lc5quy3RYfTSC/GH0FFBElrngDGPwF9OjqEo6XgbLdbmrs2
         nI0ywifhDlfFxJMWzDWRqxb0nJVCtaF7eUzhS8Q/K2UJ+EQ4kahb71vvMsWRsGV/cQIa
         N3J/fpcjWaeUqWOLAkOb/WbwXQxLpS4p34F25pPGtckstTVzb5f6wFnvHhmCTuIhD0s6
         4QalpwB7mhh8UQrFyXYUICOllrQrjmtaNu0dfPUUnJ1DpnyUYGYxrZaVrCnLN8dok5qa
         7QeQ==
X-Gm-Message-State: APjAAAWJKyh+qhbshE25olOSzdv3x6n7uYBeM9whpHqaOeMEeoFnTYX2
	+N2aacKWGRGWbgc0KyYdWKTFu+/heKYJRowGa3S9oR9Wx7v1bFRNPMtiHaMghtGGfDjJGFVkzvf
	FDf+u6KHdn1A/9XYatnH7ooKGE5cln5VFpKuQVRwGG0ZRN1hbUaSISvWMClgJaSBwbA==
X-Received: by 2002:a50:896a:: with SMTP id f39mr77625606edf.293.1558388393325;
        Mon, 20 May 2019 14:39:53 -0700 (PDT)
X-Received: by 2002:a50:896a:: with SMTP id f39mr77625562edf.293.1558388392539;
        Mon, 20 May 2019 14:39:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388392; cv=none;
        d=google.com; s=arc-20160816;
        b=yZnf3aLsrIf6VwaYcB0Dh8YvAgzK8fmguxfKvK82MK2IvWF9oxgNAKUmXX/SDJK0xO
         UxDcEfSYJhcm1XQFXRBGPS8gVWTKMSYyFdWJriqeLeqRySq8m3n7K5AqyAVIpOaJB/h4
         3svfw6sbRmsM4rUHNw+y45Yjbmg7ugNAWEg0Y23OLs6tN+Z3lqgSMybfPglt/Tuyi8HP
         +rmaQT3gXYMmIT8B2CZvkaAGWgvA3FZLOEVysfJaOVulK8lO+FGAYttkjPzU3th4F4/a
         0BycCD7q7uA2MBO1WJtHx1A43NAjKSgG2KINh8KvF0QsoIrBa53XYaDH5IUbz/qDNIrV
         uAAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=DucpRdkRgOoCBrOy6KiJUJJfWEr/7+ZCIIaJ4AvhfB0=;
        b=vIXLVJ26i3L6KoCsKSgeG0RV4ZL8pgzIxQn28rXct0DplXxI8yLcfm5ESZqyIYnBF3
         Cs5RkpBOjLLYQkKn+UXIrsnsqNbIsfmi7skwj3/OCGzu3MM3Vwzo/WC+QzgemLQ8MZEM
         icrfsVxFSwnkxxm1ANFrmDMkjU1MzXysbhi9bEQZyo5BQUqWNtk8dAzK9wGA8wnjY6bH
         rcA0WvY8s8IetZ7k8ORGppqpb3Az2lnGBJcLHIyWuPxS+K0VrQiJZ4CUf9dOE1LhdjE3
         XKpE3qYQgY1onb2fJIrDGFdayvpx06YRQS0UtRmlwM+IsbwvwHe5NhmvD/zxPKfzeMEa
         moEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=HKq8Duys;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b51sor2213149ede.8.2019.05.20.14.39.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:39:52 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=HKq8Duys;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DucpRdkRgOoCBrOy6KiJUJJfWEr/7+ZCIIaJ4AvhfB0=;
        b=HKq8DuysKW6hx7l8Yig0NV9UpMzIOK98ALTyHYlWExOE6Pc4XsceN9CwZTMEZ+y6cw
         Cotb3dp0LmPi/TnfsGu9Mc8wGpsj9yCkmJXIekv1AWGWZdRazvo+2R7pulay1RKnKq5x
         V5EN38iDPb1UvcB2ERZ4RtefPoEDwb5qTXLcw=
X-Google-Smtp-Source: APXvYqzzZ2kpVp8haHdbToY3y03B93IZ2fARLhOO1vyR6C1AaG3mgxQcALaUAvLZsqLVYAWfP3KDjg==
X-Received: by 2002:a50:b865:: with SMTP id k34mr79563563ede.16.1558388391895;
        Mon, 20 May 2019 14:39:51 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id v27sm3285772eja.68.2019.05.20.14.39.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:39:51 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to fail
Date: Mon, 20 May 2019 23:39:42 +0200
Message-Id: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just a bit of paranoia, since if we start pushing this deep into
callchains it's hard to spot all places where an mmu notifier
implementation might fail when it's not allowed to.

Inspired by some confusion we had discussing i915 mmu notifiers and
whether we could use the newly-introduced return value to handle some
corner cases. Until we realized that these are only for when a task
has been killed by the oom reaper.

An alternative approach would be to split the callback into two
versions, one with the int return value, and the other with void
return value like in older kernels. But that's a lot more churn for
fairly little gain I think.

Summary from the m-l discussion on why we want something at warning
level: This allows automated tooling in CI to catch bugs without
humans having to look at everything. If we just upgrade the existing
pr_info to a pr_warn, then we'll have false positives. And as-is, no
one will ever spot the problem since it's lost in the massive amounts
of overall dmesg noise.

v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
the problematic case (Michal Hocko).

v3: Rebase on top of Glisse's arg rework.

v4: More rebase on top of Glisse reworking everything.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>
Reviewed-by: Christian König <christian.koenig@amd.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index ee36068077b6..c05e406a7cd7 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -181,6 +181,9 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
 					!mmu_notifier_range_blockable(range) ? "non-" : "");
+				if (!mmu_notifier_range_blockable(range))
+					pr_warn("%pS callback failure not allowed\n",
+						mn->ops->invalidate_range_start);
 				ret = _ret;
 			}
 		}
-- 
2.20.1

