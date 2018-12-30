Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 075288E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 00:25:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id u197so30199925qka.8
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 21:25:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l6sor33972477qve.32.2018.12.29.21.25.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 21:25:03 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: kmemleak not play well with low memory situation
Message-ID: <0b2ecfe8-b98b-755c-5b5d-00a09a0d9e57@lca.pw>
Date: Sun, 30 Dec 2018 00:25:01 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>

When in low memory situation with swapping, kmemleak quickly disable itself due
to cannot allocate a kmemleak_object structure. If kmemleak could hold a bit
longer, the system will trigger OOM soon to free up the memory. This is a bit
tricky to solve because in __alloc_pages_slowpath() even though it has
GFP_NOFAIL, it would fail allocation due to no GFP_DIRECT_RECLAIM,

/* Caller is not willing to reclaim, we can't balance anything */
if (!can_direct_reclaim)
	goto nopage;

if (WARN_ON_ONCE(!can_direct_reclaim))
	goto fail;

If adding GFP_DIRECT_RECLAIM to kmemleak_alloc(), it will trigger endless
warnings in slab_pre_alloc_hook(),

might_sleep_if(gfpflags_allow_blocking(flags));
