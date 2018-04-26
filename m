Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8F5B6B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:51:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n5so13012908pgq.3
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:51:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor4241944pfa.144.2018.04.26.07.51.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 07:51:00 -0700 (PDT)
From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 0/2] tcp: mmap: rework zerocopy receive
Date: Thu, 26 Apr 2018 07:50:54 -0700
Message-Id: <20180426145056.220325-1-edumazet@google.com>
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

v3: change TCP_ZEROCOPY_RECEIVE to be a getsockopt() option
    instead of setsockopt(), feedback from Ka-Cheon Poon

v2: Added a missing page align of zc->length in tcp_zerocopy_receive()
    Properly clear zc->recv_skip_hint in case user request was completed.

Eric Dumazet (2):
  tcp: add TCP_ZEROCOPY_RECEIVE support for zerocopy receive
  selftests: net: tcp_mmap must use TCP_ZEROCOPY_RECEIVE

 include/uapi/linux/tcp.h               |   8 ++
 net/ipv4/tcp.c                         | 192 +++++++++++++------------
 tools/testing/selftests/net/tcp_mmap.c |  64 +++++----
 3 files changed, 146 insertions(+), 118 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog
