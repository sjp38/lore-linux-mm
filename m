Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86E296B0026
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 17:43:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so11583759pgv.12
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 14:43:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q15sor3887310pgf.13.2018.04.25.14.43.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 14:43:16 -0700 (PDT)
From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/2] tcp: mmap: rework zerocopy receive
Date: Wed, 25 Apr 2018 14:43:05 -0700
Message-Id: <20180425214307.159264-1-edumazet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

syzbot reported a lockdep issue caused by tcp mmap() support.

I implemented Andy Lutomirski nice suggestions to resolve the
issue and increase scalability as well.

First patch is adding a new setsockopt() operation and changes mmap()
behavior.

Second patch changes tcp_mmap reference program.

v2:
 Added a missing page align of zc->length in tcp_zerocopy_receive()
 Properly clear zc->recv_skip_hint in case user request was completed.

Eric Dumazet (2):
  tcp: add TCP_ZEROCOPY_RECEIVE support for zerocopy receive
  selftests: net: tcp_mmap must use TCP_ZEROCOPY_RECEIVE

 include/uapi/linux/tcp.h               |   8 ++
 net/ipv4/tcp.c                         | 189 +++++++++++++------------
 tools/testing/selftests/net/tcp_mmap.c |  63 +++++----
 3 files changed, 142 insertions(+), 118 deletions(-)

-- 
2.17.0.441.gb46fe60e1d-goog
