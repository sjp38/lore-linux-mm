Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82E3A6B0007
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 17:17:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so13699601pgq.3
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:17:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 92-v6si14191647plw.299.2018.04.26.14.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 14:17:07 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0FAC3217D9
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 21:17:07 +0000 (UTC)
Received: by mail-wm0-f52.google.com with SMTP id b21so186490wme.4
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:17:06 -0700 (PDT)
MIME-Version: 1.0
References: <20180425214307.159264-1-edumazet@google.com> <CACSApvZF8CJqcRx7FGkMGitBiC6m0=_FT9XRZ=VV07U62wGM3Q@mail.gmail.com>
 <a2c405e1-0ebc-dd33-fb0d-575bf06a1ff6@gmail.com>
In-Reply-To: <a2c405e1-0ebc-dd33-fb0d-575bf06a1ff6@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 26 Apr 2018 21:16:55 +0000
Message-ID: <CALCETrVBQD1tPUzc_t7HmoPfApTdFW+x-0DqL8+XHjrmEpYMXQ@mail.gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] tcp: mmap: rework zerocopy receive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, Andrew Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

At the risk of further muddying the waters, there's another minor tweak
that could improve performance on certain workloads.  Currently you mmap()
a range for a given socket and then getsockopt() to receive.  If you made
it so you could mmap() something once for any number of sockets (by
mmapping /dev/misc/tcp_zero_receive or whatever), then the performance of
the getsockopt() bit would be identical, but you could release the mapping
for many sockets at once with only a single flush.  For some use cases,
this could be a big win.

You could also add this later easily enough, too.
