Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8A266B0009
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 17:41:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m68so12799813pfm.20
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:41:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u11sor3459599pgc.1.2018.04.26.14.41.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 14:41:02 -0700 (PDT)
Subject: Re: [PATCH v2 net-next 0/2] tcp: mmap: rework zerocopy receive
References: <20180425214307.159264-1-edumazet@google.com>
 <CACSApvZF8CJqcRx7FGkMGitBiC6m0=_FT9XRZ=VV07U62wGM3Q@mail.gmail.com>
 <a2c405e1-0ebc-dd33-fb0d-575bf06a1ff6@gmail.com>
 <CALCETrVBQD1tPUzc_t7HmoPfApTdFW+x-0DqL8+XHjrmEpYMXQ@mail.gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <2a8ea6bd-02dd-14dd-c797-2d8cba626f79@gmail.com>
Date: Thu, 26 Apr 2018 14:40:59 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrVBQD1tPUzc_t7HmoPfApTdFW+x-0DqL8+XHjrmEpYMXQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>



On 04/26/2018 02:16 PM, Andy Lutomirski wrote:
> At the risk of further muddying the waters, there's another minor tweak
> that could improve performance on certain workloads.  Currently you mmap()
> a range for a given socket and then getsockopt() to receive.  If you made
> it so you could mmap() something once for any number of sockets (by
> mmapping /dev/misc/tcp_zero_receive or whatever), then the performance of
> the getsockopt() bit would be identical, but you could release the mapping
> for many sockets at once with only a single flush.  For some use cases,
> this could be a big win.
> 
> You could also add this later easily enough, too.
> 

I believe I implemented what you just described.

The getsockopt() call checks that the VMA was created by a mmap() to one TCP socket.

It does not check that the vma was created by mmap() on the same socket,
because we do not need this extra check really.

So you presumably could use mmap() to grab 1GB of virtual space, then split it
as you wish for different sockets.

Thanks.
