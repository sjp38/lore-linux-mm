Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3816B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 02:29:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15so12777615pfi.8
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 23:29:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z26si11194055pfl.209.2018.04.24.23.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 23:29:03 -0700 (PDT)
Date: Tue, 24 Apr 2018 23:28:59 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Message-ID: <20180425062859.GA23914@infradead.org>
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180425052722.73022-2-edumazet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, Apr 24, 2018 at 10:27:21PM -0700, Eric Dumazet wrote:
> When adding tcp mmap() implementation, I forgot that socket lock
> had to be taken before current->mm->mmap_sem. syzbot eventually caught
> the bug.
> 
> Since we can not lock the socket in tcp mmap() handler we have to
> split the operation in two phases.
> 
> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
>   This operation does not involve any TCP locking.
> 
> 2) setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
>  the transfert of pages from skbs to one VMA.
>   This operation only uses down_read(&current->mm->mmap_sem) after
>   holding TCP lock, thus solving the lockdep issue.
> 
> This new implementation was suggested by Andy Lutomirski with great details.

Thanks, this looks much more sensible to me.
