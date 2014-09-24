Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id F2F956B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:03:06 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id p9so9285704lbv.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:03:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si20825243laa.119.2014.09.23.19.03.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:03:05 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 0/5]  Remove possible deadlocks in nfs_release_page() - V3
Message-ID: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

This set includes acked-by's from Andrew and Peter so it should be
OK for all five patches to go upstream through the NFS tree.

I split the congestion tracking patch out from the wait-for-PG_private
patch as they are conceptually separate.

This set continues to perform well in my tests and addresses all
issues that have been raised.

Thanks a lot,
NeilBrown


---

NeilBrown (5):
      SCHED: add some "wait..on_bit...timeout()" interfaces.
      MM: export page_wakeup functions
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS: avoid waiting at all in nfs_release_page when congested.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()


 fs/nfs/file.c                   |   29 +++++++++++++++++++----------
 fs/nfs/write.c                  |    7 +++++++
 include/linux/pagemap.h         |   12 ++++++++++--
 include/linux/wait.h            |    5 ++++-
 kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c                    |   21 +++++++++++++++------
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 9 files changed, 91 insertions(+), 33 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
