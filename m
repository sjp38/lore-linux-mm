Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19DF16B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:40:34 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id a193-v6so17844776ioa.23
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:40:34 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o187-v6si16702604iof.241.2018.04.26.06.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 06:40:32 -0700 (PDT)
Subject: Re: [PATCH v2 net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
References: <20180425214307.159264-1-edumazet@google.com>
 <20180425214307.159264-2-edumazet@google.com>
From: Ka-Cheong Poon <ka-cheong.poon@oracle.com>
Message-ID: <d3ad6970-4139-76a9-2417-3df077753aa9@oracle.com>
Date: Thu, 26 Apr 2018 21:40:14 +0800
MIME-Version: 1.0
In-Reply-To: <20180425214307.159264-2-edumazet@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>, Soheil Hassas Yeganeh <soheil@google.com>

On 04/26/2018 05:43 AM, Eric Dumazet wrote:
> When adding tcp mmap() implementation, I forgot that socket lock
> had to be taken before current->mm->mmap_sem. syzbot eventually caught
> the bug.
> 
> Since we can not lock the socket in tcp mmap() handler we have to
> split the operation in two phases.
> 
> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
>    This operation does not involve any TCP locking.
> 
> 2) setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
>   the transfert of pages from skbs to one VMA.
>    This operation only uses down_read(&current->mm->mmap_sem) after
>    holding TCP lock, thus solving the lockdep issue.


A quick question.  Is it a normal practice to return a result
in setsockopt() given that the optval parameter is supposed to
be a const void *?




-- 
K. Poon
ka-cheong.poon@oracle.com
