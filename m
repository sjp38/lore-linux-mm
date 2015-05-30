Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 42DAD6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 08:03:35 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so34990510wic.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:34 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id cr5si13697362wjb.214.2015.05.30.05.03.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 05:03:31 -0700 (PDT)
Received: by wivl4 with SMTP id l4so38535661wiv.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:31 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH 0/4] sunrpc: clean up "swapper" xprt handling
Date: Sat, 30 May 2015 08:03:09 -0400
Message-Id: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

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

Jeff Layton (4):
  sunrpc: keep a count of swapfiles associated with the rpc_clnt
  sunrpc: make xprt->swapper an atomic_t
  sunrpc: if we're closing down a socket, clear memalloc on it first
  sunrpc: lock xprt before trying to set memalloc on the sockets

 fs/nfs/file.c                | 11 ++------
 include/linux/sunrpc/clnt.h  |  1 +
 include/linux/sunrpc/sched.h | 16 +++++++++++
 include/linux/sunrpc/xprt.h  |  5 ++--
 net/sunrpc/clnt.c            | 67 ++++++++++++++++++++++++++++++++++++++------
 net/sunrpc/xprtsock.c        | 59 +++++++++++++++++++++++++++++---------
 6 files changed, 125 insertions(+), 34 deletions(-)

-- 
2.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
