Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 644356B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:58:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u13-v6so1771615wre.1
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:58:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7-v6sor757114wrf.63.2018.04.27.08.58.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Apr 2018 08:58:18 -0700 (PDT)
From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 0/2] tcp: mmap: rework zerocopy receive
Date: Fri, 27 Apr 2018 08:58:07 -0700
Message-Id: <20180427155809.79094-1-edumazet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ka-Cheong Poon <ka-cheong.poon@oracle.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

syzbot reported a lockdep issue caused by tcp mmap() support.

I implemented Andy Lutomirski nice suggestions to resolve the
issue and increase scalability as well.

First patch is adding a new getsockopt() operation and changes mmap()
behavior.

Second patch changes tcp_mmap reference program.

v4: tcp mmap() support depends on CONFIG_MMU, as kbuild bot told us.

v3: change TCP_ZEROCOPY_RECEIVE to be a getsockopt() option
    instead of setsockopt(), feedback from Ka-Cheon Poon

v2: Added a missing page align of zc->length in tcp_zerocopy_receive()
    Properly clear zc->recv_skip_hint in case user request was completed.

Eric Dumazet (2):
  tcp: add TCP_ZEROCOPY_RECEIVE support for zerocopy receive
  selftests: net: tcp_mmap must use TCP_ZEROCOPY_RECEIVE

 include/uapi/linux/tcp.h               |   8 +
 net/ipv4/af_inet.c                     |   2 +
 net/ipv4/tcp.c                         | 196 +++++++++++++------------
 net/ipv6/af_inet6.c                    |   2 +
 tools/testing/selftests/net/tcp_mmap.c |  64 ++++----
 5 files changed, 154 insertions(+), 118 deletions(-)

-- 
2.17.0.441.gb46fe60e1d-goog
