Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3343D6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:16:25 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so59350374pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:25 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id m6si46866984pfj.88.2016.08.09.23.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:16:21 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hh10so2255337pac.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:16 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 0/5] Reduce memory waste by page extension user
Date: Wed, 10 Aug 2016 15:16:19 +0900
Message-Id: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Joonsoo Kim (5):
  mm/debug_pagealloc: clean-up guard page handling code
  mm/debug_pagealloc: don't allocate page_ext if we don't use guard page
  mm/page_owner: move page_owner specific function to page_owner.c
  mm/page_ext: support extra space allocation by page_ext user
  mm/page_owner: don't define fields on struct page_ext by hard-coding

 include/linux/page_ext.h   |   8 +--
 include/linux/page_owner.h |   2 +
 mm/page_alloc.c            |  44 +++++++------
 mm/page_ext.c              |  41 +++++++++---
 mm/page_owner.c            | 152 ++++++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c                |  79 -----------------------
 6 files changed, 190 insertions(+), 136 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
