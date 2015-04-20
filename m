Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 787546B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 18:03:01 -0400 (EDT)
Received: by layy10 with SMTP id y10so137553140lay.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 15:03:00 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id a1si15903826lae.45.2015.04.20.15.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 15:02:59 -0700 (PDT)
Received: by laat2 with SMTP id t2so137569632laa.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 15:02:58 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: mempolicy ref-counting question
Date: Tue, 21 Apr 2015 00:02:56 +0200
Message-ID: <87pp6y31bj.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

I'm trying to understand why "git grep mpol_get" doesn't give more hits
than it does. Two of the users (kernel/sched/debug.c and
fs/proc/task_mmu.c) seem to only hold the extra reference while writing
to a seq_file. That leaves just three actual users.

In particular, I'm wondering why __split_vma (and copy_vma) use
vma_dup_policy instead of simply getting an extra reference on the
old. I see there's some cpuset_being_rebound dance in mpol_dup, but I
don't understand why that's needed: In __split_vma, we're holding
mmap_sem, so either update_tasks_nodemask has already visited this mm
via mpol_rebind_mm (which also takes the mmap_sem), so the old vma is
already rebound, or the mpol_rebind_mm call will come later and rebind
the mempolicy of both the old and new vma - why would it matter that the
new vma's policy is rebound immediately?

I'd appreciate it if someone could enlighten me (I'm probably
missing something obvious).

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
