Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id DC42C900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:44:08 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so105317146wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:08 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id r1si31146232wic.9.2015.06.03.07.44.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 07:44:06 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so105315453wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:05 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2 0/5] sunrpc: clean up "swapper" xprt handling
Date: Wed,  3 Jun 2015 10:43:47 -0400
Message-Id: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

v2:
- don't take xprt lock unless we need to manipulate the memalloc flag
- add new xprt operations for swap enable/disable

This series is a (small) overhaul of the swap-over-NFS code. The main
impetus is to fix the problem reported by Jerome Marchand. We currently
hold the rcu_read_lock when calling xs_swapper and that's just plain
wrong. The first patch in this series should fix that problem, and also
clean up a bit of a layering violation.

The other focus of this set is to change how the swapper refcounting
works. Right now, it's only tracked in the rpc_xprt, and there seem to
be some gaps in its coverage -- places where we should taking or
dropping references but aren't. This changes it so that the clnt tracks
the number of swapfiles that it has, and the xprt tracks the number of
"swappable" clients.

It also ensures that we only call sk_set_memalloc once per socket. I
believe that's the correct thing to do as the main reason for the
memalloc_socks counter is to track whether we have _any_
memalloc-enabled sockets.

There is still some work to be done here as I think there remains some
potential for races between swapon/swapoff, and reconnect or migration
events. That will take some careful thought that I haven't the time to
spend on at the moment. I don't think this set will make those races
any worse though.

Jeff Layton (5):
  sunrpc: keep a count of swapfiles associated with the rpc_clnt
  sunrpc: make xprt->swapper an atomic_t
  sunrpc: if we're closing down a socket, clear memalloc on it first
  sunrpc: lock xprt before trying to set memalloc on the sockets
  sunrpc: turn swapper_enable/disable functions into rpc_xprt_ops

 fs/nfs/file.c                   | 11 +-----
 include/linux/sunrpc/clnt.h     |  1 +
 include/linux/sunrpc/sched.h    | 16 ++++++++
 include/linux/sunrpc/xprt.h     | 17 ++++++++-
 net/sunrpc/clnt.c               | 67 +++++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/transport.c | 15 +++++++-
 net/sunrpc/xprtsock.c           | 84 +++++++++++++++++++++++++++++++++--------
 7 files changed, 174 insertions(+), 37 deletions(-)

-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
