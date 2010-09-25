Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DDFC76B0047
	for <linux-mm@kvack.org>; Sat, 25 Sep 2010 19:33:17 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 25 Sep 2010 16:33:09 -0700
Message-ID: <m1sk0x9z62.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [PATCH 0/3] Generic support for revoking mappings
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


During hotplug or rmmod if a device or file is mmaped, it's mapping
needs to be removed and future access need to return SIGBUS almost like
truncate.  This case is rare enough that it barely gets tested, and
making a generic implementation warranted.  I have tried with sysfs but
a complete and generic implementation does not seem possible without mm
support.

It looks like a fully generic implementation with mm knowledge
is shorter and easier to get right than what I have in sysfs today.

So here is that fully generic implementation.

Eric W. Biederman (3):
      mm: Introduce revoke_mappings.
      mm: Consolidate vma destruction into remove_vma.
      mm: Cause revoke_mappings to wait until all close methods have completed.
---
 include/linux/fs.h |    2 +
 include/linux/mm.h |    2 +
 mm/Makefile        |    2 +-
 mm/mmap.c          |   34 +++++-----
 mm/nommu.c         |    5 ++
 mm/revoke.c        |  192 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 219 insertions(+), 18 deletions(-)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
