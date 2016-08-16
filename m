Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C93A16B0038
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:51:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so148173683pfg.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:24 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id l190si29675384pfc.25.2016.08.15.19.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 19:51:23 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i6so4664170pfe.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:23 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 0/6] Reduce memory waste by page extension user
Date: Tue, 16 Aug 2016 11:51:13 +0900
Message-Id: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

v2:
Fix rebase mistake (per Vlastimil)
Rename some variable/function to prevent confusion (per Vlastimil)
Fix header dependency (per Sergey)

This patchset tries to reduce memory waste by page extension user.

First case is architecture supported debug_pagealloc. It doesn't
requires additional memory if guard page isn't used. 8 bytes per
page will be saved in this case.

Second case is related to page owner feature. Until now, if page_ext
users want to use it's own fields on page_ext, fields should be
defined in struct page_ext by hard-coding. It has a following problem.

struct page_ext {
 #ifdef CONFIG_A
	int a;
 #endif
 #ifdef CONFIG_B
	int b;
 #endif
};

Assume that kernel is built with both CONFIG_A and CONFIG_B.
Even if we enable feature A and doesn't enable feature B at runtime,
each entry of struct page_ext takes two int rather than one int.
It's undesirable waste so this patch tries to reduce it. By this patchset,
we can save 20 bytes per page dedicated for page owner feature
in some configurations.

Thanks.

Joonsoo Kim (6):
  mm/debug_pagealloc: clean-up guard page handling code
  mm/debug_pagealloc: don't allocate page_ext if we don't use guard page
  mm/page_owner: move page_owner specific function to page_owner.c
  mm/page_ext: rename offset to index
  mm/page_ext: support extra space allocation by page_ext user
  mm/page_owner: don't define fields on struct page_ext by hard-coding

 include/linux/page_ext.h   |   8 +--
 include/linux/page_owner.h |   2 +
 mm/page_alloc.c            |  44 +++++++------
 mm/page_ext.c              |  45 +++++++++----
 mm/page_owner.c            | 156 ++++++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c                |  79 -----------------------
 6 files changed, 196 insertions(+), 138 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
