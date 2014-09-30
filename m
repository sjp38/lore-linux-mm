Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 35B416B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:51 -0400 (EDT)
Received: by mail-oi0-f42.google.com with SMTP id a141so6010oig.1
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:54:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ii2si17021324obb.14.2014.09.29.18.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:54:50 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 0/5] mm: poison critical mm/ structs
Date: Mon, 29 Sep 2014 21:47:14 -0400
Message-Id: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Currently we're seeing a few issues which are unexplainable by looking at the
data we see and are most likely caused by a memory corruption caused
elsewhere.

This is wasting time for folks who are trying to figure out an issue provided
a stack trace that can't really point out the real issue.

This patch introduces poisoning on struct page, vm_area_struct, and mm_struct,
and places checks in busy paths to catch corruption early.

This series was tested, and it detects corruption in vm_area_struct. Right now
I'm working on figuring out the source of the corruption, (which is a long
standing bug) using KASan, but the current code is useful as it is.

Sasha Levin (5):
  mm: add poisoning basics
  mm: constify dump_page and friends
  mm: poison mm_struct
  mm: poison vm_area_struct
  mm: poison page struct

 fs/exec.c                   |  5 +++++
 include/linux/memcontrol.h  |  8 ++++----
 include/linux/mm.h          | 11 ++++++++++-
 include/linux/mm_types.h    | 18 ++++++++++++++++++
 include/linux/mmdebug.h     | 24 ++++++++++++++++++++++--
 include/linux/page-flags.h  | 24 ++++++++++++++++--------
 include/linux/page_cgroup.h |  4 ++--
 include/linux/poison.h      |  6 ++++++
 kernel/fork.c               | 13 +++++++++++++
 lib/Kconfig.debug           |  9 +++++++++
 mm/debug.c                  | 22 ++++++++++++++++++----
 mm/memcontrol.c             |  6 +++---
 mm/mmap.c                   | 21 ++++++++++++++++++++-
 mm/nommu.c                  |  7 +++++++
 mm/page_cgroup.c            |  4 ++--
 mm/vmacache.c               |  5 +++++
 16 files changed, 160 insertions(+), 27 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
