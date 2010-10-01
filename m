Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B5CFB6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 01:05:00 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o9154thY014354
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:56 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by wpaz5.hot.corp.google.com with ESMTP id o9154sWr018993
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:54 -0700
Received: by pzk3 with SMTP id 3so713694pzk.37
        for <linux-mm@kvack.org>; Thu, 30 Sep 2010 22:04:54 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/2] Reduce mmap_sem hold times during file backed page faults
Date: Thu, 30 Sep 2010 22:04:42 -0700
Message-Id: <1285909484-30958-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Linus, I would appreciate your comments on this since you shot down the
previous proposal. I hope you'll find this approach is sane, but I would
be interested to hear if you have specific objections.

mmap_sem is very coarse grained (per process) and has long read-hold times
(disk latencies); this breaks down rapidly for workloads that use both
read and write mmap_sem acquires. This short patch series tries to reduce
mmap_sem hold times when faulting in file backed VMAs.

First patch creates a single place to lock the page in filemap_fault().
There should be no behavior differences.

Second patch modifies that lock_page() so that, if trylock_page() fails,
we consider releasing the mmap_sem while waiting for page to be unlocked.
This is controlled by a new FAULT_FLAG_RELEASE flag. If the mmap_sem gets
released, we return the VM_FAULT_RELEASED status; the caller is then expected
to re-acquire mmap_sem and retry the page fault. Chances are that the same
page will be accessed and will now be unlocked, so the mmap_sem hold time
will be short.

Michel Lespinasse (2):
  Unique path for locking page in filemap_fault()
  Release mmap_sem when page fault blocks on disk transfer.

 arch/x86/mm/fault.c |   35 ++++++++++++++++++++++++++---------
 include/linux/mm.h  |    2 ++
 mm/filemap.c        |   38 +++++++++++++++++++++++++++++---------
 mm/memory.c         |    3 ++-
 4 files changed, 59 insertions(+), 19 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
