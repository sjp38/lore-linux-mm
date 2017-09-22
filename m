Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49E7E6B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 05:52:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r74so930884wme.5
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 02:52:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a195sor1145944wme.13.2017.09.22.02.52.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 02:52:35 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v2 0/2] KSM: Replace jhash2 with xxhash
Date: Fri, 22 Sep 2017 12:52:23 +0300
Message-Id: <20170922095225.343-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, borntraeger@de.ibm.com, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

(Resend, added cc kvm@vger.kernel.org)

ksm use jhash2 for hashing pages,
in 4.14 xxhash has been merged to mainline kernel.

xxhash much faster then jhash2 on big inputs (32 byte+)

xxhash has 2 versions, one with 32-bit hash and
one with 64-bit hash.

64-bit version works faster then 32-bit on 64-bit arch.

So lets get better from two worlds,
create arch dependent xxhash() function that will use
fastest algo for current arch.
This a first patch.

Performance info and ksm update can be found in second patch.

Changelog:
  v1 -> v2:
    - Move xxhash() to xxhash.h/c and separate patches

Timofey Titovets (2):
  xxHash: create arch dependent 32/64-bit xxhash()
  KSM: Replace jhash2 with xxhash

 include/linux/xxhash.h | 24 ++++++++++++++++++++++++
 lib/xxhash.c           | 10 ++++++++++
 mm/Kconfig             |  1 +
 mm/ksm.c               | 14 +++++++-------
 4 files changed, 42 insertions(+), 7 deletions(-)

--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
