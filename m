Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 596BB6B00BB
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:10:51 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wp18so8247573obc.8
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:10:51 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id h85si1441443oic.73.2015.02.18.16.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 16:10:50 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH -part1 0/3] mm: improve handling of mm->exe_file
Date: Wed, 18 Feb 2015 16:10:38 -0800
Message-Id: <1424304641-28965-1-git-send-email-dbueso@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net

From: Davidlohr Bueso <dave@stgolabs.net>

This series is the first in a few where I'm planning on removing
the mmap_sem need for exe_file serialization. This is absurd and
needs to have its own locking. Anyway, this is the final goal, and
this series is just the first of a few that deals with unifying users
of exe_file.

For now we only deal with audit and tomoyo, the most obvious naughty
users, which only take the mmap_sem for exe_file. Over the years,
relying on the mmap_sem for exe_file has made some callers increasingly
messy and it is not as straightforward.

Essentially, we want to convert:

down_read(&mm->mmap_sem);
do_something_with(mm->exe_file);
up_read(&mm->mmap_sem);

to:

exe_file = get_mm_exe_file(mm); <--- mmap_sem is only held here.
do_something_with(mm->exe_file);
fput(exe_file);

On its own, these patches already have value in that we reduce mmap_sem hold
times and critical region. Once all users are standardized, converting the
lock rules will be much easier.

Thanks!

Davidlohr Bueso (3):
  kernel/audit: consolidate handling of mm->exe_file
  kernel/audit: robustify handling of mm->exe_file
  security/tomoyo: robustify handling of mm->exe_file

 kernel/audit.c           |  9 +--------
 kernel/audit.h           | 20 ++++++++++++++++++++
 kernel/auditsc.c         |  9 +--------
 security/tomoyo/common.c | 41 ++++++++++++++++++++++++++++++++++++++---
 security/tomoyo/common.h |  1 -
 security/tomoyo/util.c   | 22 ----------------------
 6 files changed, 60 insertions(+), 42 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
