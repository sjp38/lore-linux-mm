Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5006B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:32:31 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id b12so5743520lbj.25
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 22:32:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xt5si22278700lbb.12.2014.09.15.22.32.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 22:32:29 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Tue, 16 Sep 2014 15:31:34 +1000
Subject: [PATCH 0/4] Remove possible deadlocks in nfs_release_page()
Message-ID: <20140916051911.22257.24658.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

Because nfs_release_page() submits a 'COMMIT' nfs request and waits
for it to complete, and does this during memory reclaim, it is
susceptible to deadlocks if memory allocation happens anywhere in
sending the COMMIT message.  If the NFS server is on the same host
(i.e. loop-back NFS), then any memory allocations in the NFS server
can also cause deadlocks.

nfs_release_page() already has some code to avoid deadlocks in some
circumstances, but these are not sufficient for loopback NFS.

This patch set changes the approach to deadlock avoidance.  Rather
than detecting cases that could deadlock and avoiding the COMMIT, it
always tries the COMMIT, but only waits a short time (1 second).
This avoid any deadlock possibility at the expense of not waiting
longer than 1 second even if no deadlock is pending.

nfs_release_page() does not *need* to wait longer - all callers that
matter handle a failure gracefully - they move on to other pages.

This set:
 - adds some "_timeout()" functions to "wait_on_bit".  Only a
   wait_on_page version is actually used.
 - exports page wake_up support.  NFS knows that the COMMIT is complete
   when PG_private is clear.  So nfs_release_page will use
   wait_on_page_bit_killable_timeout to wait for the bit to clear,
   and needs access to wake_up_page()
 - changes nfs_release_page() to use
    wait_on_page_bit_killable_timeout()
 - removes the other deadlock avoidance mechanisms from
   nfs_release_page, so that PF_FSTRANS is again only used
   by XFS.

As such, it needs buy-in from sched people, mm people, and NFS people.
Assuming I get that buy-in, suggests for how these patches can flow
into mainline would be appreciated ... I daren't hope they can all go
in through one tree....

Thanks,
NeilBrown


---

NeilBrown (4):
      SCHED: add some "wait..on_bit...timeout()" interfaces.
      MM: export page_wakeup functions
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()


 fs/nfs/file.c                   |   22 ++++++++++++----------
 fs/nfs/write.c                  |    2 ++
 include/linux/pagemap.h         |   12 ++++++++++--
 include/linux/wait.h            |    5 ++++-
 kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c                    |   21 +++++++++++++++------
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 9 files changed, 79 insertions(+), 33 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
