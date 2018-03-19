Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A63A6B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 20:57:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e185so1012869wmg.5
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 17:57:01 -0700 (PDT)
Received: from mail.kmu-office.ch (mail.kmu-office.ch. [2a02:418:6a02::a2])
        by mx.google.com with ESMTPS id a137si1734676wme.38.2018.03.18.17.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 17:56:59 -0700 (PDT)
From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] mm/memblock: cast constant ULLONG_MAX to phys_addr_t
Date: Mon, 19 Mar 2018 01:56:45 +0100
Message-Id: <20180319005645.29051-1-stefan@agner.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com
Cc: pasha.tatashin@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stefan Agner <stefan@agner.ch>

This fixes a warning shown when phys_addr_t is 32-bit int
when compiling with clang:
  mm/memblock.c:927:15: warning: implicit conversion from 'unsigned long long'
        to 'phys_addr_t' (aka 'unsigned int') changes value from
        18446744073709551615 to 4294967295 [-Wconstant-conversion]
                                  r->base : ULLONG_MAX;
                                            ^~~~~~~~~~
  ./include/linux/kernel.h:30:21: note: expanded from macro 'ULLONG_MAX'
  #define ULLONG_MAX      (~0ULL)
                           ^~~~~

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 mm/memblock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b6ba6b7adadc..696829a198ba 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -924,7 +924,7 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
 			r = &type_b->regions[idx_b];
 			r_start = idx_b ? r[-1].base + r[-1].size : 0;
 			r_end = idx_b < type_b->cnt ?
-				r->base : ULLONG_MAX;
+				r->base : (phys_addr_t)ULLONG_MAX;
 
 			/*
 			 * if idx_b advanced past idx_a,
@@ -1040,7 +1040,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
 			r = &type_b->regions[idx_b];
 			r_start = idx_b ? r[-1].base + r[-1].size : 0;
 			r_end = idx_b < type_b->cnt ?
-				r->base : ULLONG_MAX;
+				r->base : (phys_addr_t)ULLONG_MAX;
 			/*
 			 * if idx_b advanced past idx_a,
 			 * break out to advance idx_a
-- 
2.16.2
