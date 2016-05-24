Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44E106B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 14:28:10 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 85so45273850ioq.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 11:28:10 -0700 (PDT)
Received: from g4t3428.houston.hpe.com (g4t3428.houston.hpe.com. [15.241.140.76])
        by mx.google.com with ESMTPS id m1si641612otm.164.2016.05.24.11.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 11:28:09 -0700 (PDT)
Date: Tue, 24 May 2016 23:57:59 +0530
From: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Subject: [PATCH v3 0/2] KASAN double-free detection
Message-ID: <20160524182759.GA4747@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, aryabinin@virtuozzo.com, glider@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ynorov@caviumnetworks.com, kuthonuzo.luruo@hpe.com

Hello Alexander/Andrey/Dmitry/Reviewers,

Submitting v3 for your review/consideration. First patch provides more
reliable double-free detection for KASAN. Second patch provides new
double-free tests for 'test_kasan'.

Major changes from v2:
o object lock/unlock simplified to use generic bit spinlock apis instead of
  custom CAS loop. A 'safety valve' is provided for lock in case an
  out-of-bounds write flips lock bit.

o test_kasan concurrent double-free test simplified to use
  on_each_cpu_mask() instead of custom threads.
 
v2 link: https://lkml.org/lkml/2016/5/6/210

Patchset is based on linux-next 'next-20160524'.

Thanks,

Kuthonuzo

Kuthonuzo Luruo (2):
  mm, kasan: improve double-free detection
  kasan: add double-free tests

 include/linux/kasan.h |    7 +++-
 lib/test_kasan.c      |   47 ++++++++++++++++++++++++++
 mm/kasan/kasan.c      |   88 ++++++++++++++++++++++++++++++++++---------------
 mm/kasan/kasan.h      |   44 +++++++++++++++++++++++-
 mm/kasan/quarantine.c |    2 +
 mm/kasan/report.c     |   28 ++++++++++++++--
 mm/slab.c             |    3 +-
 mm/slub.c             |    2 +-
 8 files changed, 185 insertions(+), 36 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
