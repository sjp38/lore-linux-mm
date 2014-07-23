Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 808C86B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 20:02:42 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so480024pdb.31
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:02:42 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id qq2si565722pbb.105.2014.07.22.17.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 17:02:41 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so480001pdb.31
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:02:41 -0700 (PDT)
Date: Tue, 22 Jul 2014 17:01:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] shmem: fix faulting into a hole, not taking i_mutex: fix
Message-ID: <alpine.LSU.2.11.1407221658290.32060@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Sasha reports various nasty trinity crashes when shmem_fault() tries
to finish_wait(), we guess from rare cases when the wait_queue_head
on shmem_fallocate()'s stack has already gone.  Fix those by using
TASK_UNINTERRUPIBLE instead of TASK_KILLABLE in prepare_to_wait(),
that's much simpler and safer: TASK_KILLABLE was a nice aspiration,
but not worth any more hassle.

Reported-and-tested-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Andrew, please fold this into
shmem-fix-faulting-into-a-hole-not-taking-i_mutex.patch
before sending the fixes on to Linus - thanks.

 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm/mm/shmem.c	2014-07-22 16:35:49.683985586 -0700
+++ linux/mm/shmem.c	2014-07-22 16:36:35.459984108 -0700
@@ -1283,7 +1283,7 @@ static int shmem_fault(struct vm_area_st
 
 			shmem_falloc_waitq = shmem_falloc->waitq;
 			prepare_to_wait(shmem_falloc_waitq, &shmem_fault_wait,
-					TASK_KILLABLE);
+					TASK_UNINTERRUPTIBLE);
 			spin_unlock(&inode->i_lock);
 			schedule();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
