Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4014EC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05D67204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FVvuA3zJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05D67204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 875D18E0005; Wed, 26 Jun 2019 08:23:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8261D8E0002; Wed, 26 Jun 2019 08:23:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ED358E0005; Wed, 26 Jun 2019 08:23:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF978E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:23:02 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so2339860qkj.10
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:23:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=rHwJaORfU9mZJNEEo+jfWN6v6wx9eIm8a8mlUMvLB5Q=;
        b=TGm7zVHo+GjD3H/hDxUXH67c5kF1FNVVqztAAPoZSqQU28Qzq7Go+Y9GHmGS39quLg
         pUJfMBDlPQw4BpCq9ZG+uQsTUSUWa3FRGxMkzaDOHBQl6q4nlirzyKFASVP8gyi95qSb
         UpuBWGdT59oG4EOvw5K2Lq8IJSOtd8yuI4mWUmbsdXu7v6tMIo+1Z3tHctyo/H+ip2I1
         yphn47bu+btWXcvBt8TLMN0HkHpVDkSPRfBFbDaWmTlsYi9pyfXs13o1nnUPtYPQ5qfl
         NnQ93QXhmPfhOdjTcDSn7sN7yZ1M7q9GqSGXzMah3PN15efnhldi9zOQib5yGQuhY0mi
         Gy2Q==
X-Gm-Message-State: APjAAAWoDLWcCx8aapuZqGwctrm+etuXqG+Aae7VywXz/9AVUOC+C8qc
	32oSedQzjDLgcSJI7Ab09T9nVm7eR3GUcywB89A/yf6z/QkvvXwJrkoxcwTIP9NQLSUtkW8ut0l
	GD8AQ/I6cxoq/sWAQlohdzgKuOGP37QWMo1n3HZgagn35mB7dgBgJ2pztjIA2E//Wmg==
X-Received: by 2002:a0c:929b:: with SMTP id b27mr3153477qvb.193.1561551782064;
        Wed, 26 Jun 2019 05:23:02 -0700 (PDT)
X-Received: by 2002:a0c:929b:: with SMTP id b27mr3153439qvb.193.1561551781519;
        Wed, 26 Jun 2019 05:23:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551781; cv=none;
        d=google.com; s=arc-20160816;
        b=xkcBY7G9iC1CcfnHglgpDD+IZcpQZOeihhfnUft1VH1aXN4Cq46XNSNucUyIYYZIKJ
         OJzagzZWs3V+LdhesB9NeOPt8EHF+9PDAl/ZCnzOX8O8XkwwsfC8BDevcBL8eSj4jVpE
         vPBvSe0hJzgxtkngwWIdsVF8he4FEe0/Ckt+4H80tVP5UrfusaIZi61PuxWunDu4qawu
         gtGkV0iCayeXMuz6A5ZZlSmm5RhiA55+HH7DNeDd+2FjVPH10d+vdjPw/cqj4/Wnin/P
         OZqXdWO24a0rMpohu41EIbDLxqwaaxy7CML472ObUFKsZTh6w8GDi81RN1bBLG7/oG77
         xw+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=rHwJaORfU9mZJNEEo+jfWN6v6wx9eIm8a8mlUMvLB5Q=;
        b=G1adrAbNV+M3SsL0bIImMdanjqAAcNI+60Q4uF3gHFftZBX8Q8OH0xF0tbbw1T7fcI
         QbX4JmxzDuSaldowXQuv5bA28cPDDoLi8aFtWmDMTDCn9DigIDcpFOl6Ypn2+NL3aHLX
         DnWfBIsHqt1smV4za8/vKczCl8GL1uicEvAorh3BDK/uYov0qyAWVT2Zm7z5TIzfWOPG
         SgkA9E63j91NYAlAvZBTLupuyfBYFTKjBOt1w/Dz9p9v/apAQV2FKow+NOfqQoOAQmPg
         Ja5OmFt83PSgZkaq8DoEUYdRGD1Pd6W2sUqe7WSCuXpOlm+aVn7HjnHBUx7PGX/NFoLb
         oaMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FVvuA3zJ;
       spf=pass (google.com: domain of 3pwmtxqukckgmtdmzowwotm.kwutqvcf-uusdiks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pWMTXQUKCKgMTdMZOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m22sor23989599qtn.56.2019.06.26.05.23.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:23:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pwmtxqukckgmtdmzowwotm.kwutqvcf-uusdiks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FVvuA3zJ;
       spf=pass (google.com: domain of 3pwmtxqukckgmtdmzowwotm.kwutqvcf-uusdiks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pWMTXQUKCKgMTdMZOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=rHwJaORfU9mZJNEEo+jfWN6v6wx9eIm8a8mlUMvLB5Q=;
        b=FVvuA3zJQGuPor4RQmsHdaCKO/pAXJhuQF83hlbKY9iIKR6vfjKfGQ/ETMWnRE81jd
         jePQNF4HBcVZjtFylu5myNQmiHspuGu9vfYpwq5mpUvkM54IRChAsDca97Pj2Fp3pkv4
         RHLK9CR+MwadHsI9+rV6E5kxw8AXWSeQ3M3Zpo479Mioq8UM+sXQYEnXweDwXIcoKLa5
         A/50ckDH7jQn0d13rdkD9sSTML6D67dq+1/2WiASn/N4iuwHh1mRPjrr2ilO4kETxctr
         8+fkMMy7Gg4tHSwDW2ZwA0yQoCOBBiJBjW4RPPmxsnRWtL80rNEknMJ0Y12jLKm/bc0j
         AAnQ==
X-Google-Smtp-Source: APXvYqzl4LpGQmdrj0fZiOBsmG1D5EzH0t7qS8z3VuqQjCIlUkPj6pS/tt/JbkNeDbNPZCT8uxsjq+PytA==
X-Received: by 2002:ac8:197a:: with SMTP id g55mr3301594qtk.320.1561551781196;
 Wed, 26 Jun 2019 05:23:01 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:20:15 +0200
Message-Id: <20190626122018.171606-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 0/4] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com, 
	andreyknvl@google.com
Cc: linux-kernel@vger.kernel.org, Marco Elver <elver@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch series adds proper validation of an object in ksize() --
ksize() has been unconditionally unpoisoning the entire memory region
associated with an allocation. This can lead to various undetected bugs.

To correctly address this for all allocators, and a requirement that we
still need access to an unchecked ksize(), we introduce __ksize(), and
then refactor the common logic in ksize() to slab_common.c.

Furthermore, we introduce __kasan_check_{read,write}, which can be used
even if KASAN is disabled in a compilation unit (as is the case for
slab_common.c). See inline comment for why __kasan_check_read() is
chosen to check validity of an object inside ksize().

Previous version:
http://lkml.kernel.org/r/20190624110532.41065-1-elver@google.com

v2:
* Complete rewrite of patch, refactoring ksize() and relying on
  kasan_check_read for validation.

Marco Elver (4):
  mm/kasan: Introduce __kasan_check_{read,write}
  lib/test_kasan: Add test for double-kzfree detection
  mm/slab: Refactor common ksize KASAN logic into slab_common.c
  mm/kasan: Add object validation in ksize()

 include/linux/kasan-checks.h | 35 ++++++++++++++++++++++------
 include/linux/kasan.h        |  7 ++++--
 include/linux/slab.h         |  1 +
 lib/test_kasan.c             | 17 ++++++++++++++
 mm/kasan/common.c            | 14 +++++------
 mm/kasan/generic.c           | 13 ++++++-----
 mm/kasan/kasan.h             | 10 +++++++-
 mm/kasan/tags.c              | 12 ++++++----
 mm/slab.c                    | 28 +++++-----------------
 mm/slab_common.c             | 45 ++++++++++++++++++++++++++++++++++++
 mm/slob.c                    |  4 ++--
 mm/slub.c                    | 14 ++---------
 12 files changed, 135 insertions(+), 65 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

