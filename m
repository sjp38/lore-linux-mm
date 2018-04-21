Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E64F6B0003
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 12:55:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18so3937921pgv.14
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 09:55:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n25sor1952524pgc.411.2018.04.21.09.55.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 09:55:10 -0700 (PDT)
Subject: Re: [PATCH net-next 0/4] mm,tcp: provide mmap_hook to solve lockdep
 issue
References: <20180420155542.122183-1-edumazet@google.com>
 <20180421090722.GA11998@infradead.org>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <f9d07a33-4fad-62a8-898a-ebf6ed47a721@gmail.com>
Date: Sat, 21 Apr 2018 09:55:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180421090722.GA11998@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Soheil Hassas Yeganeh <soheil@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org



On 04/21/2018 02:07 AM, Christoph Hellwig wrote:
> On Fri, Apr 20, 2018 at 08:55:38AM -0700, Eric Dumazet wrote:
>> This patch series provide a new mmap_hook to fs willing to grab
>> a mutex before mm->mmap_sem is taken, to ensure lockdep sanity.
>>
>> This hook allows us to shorten tcp_mmap() execution time (while mmap_sem
>> is held), and improve multi-threading scalability. 
> 
> Missing CC to linu-fsdevel and linux-mm that will have to decide.
> 
> We've rejected this approach multiple times before, so you better
> make a really good argument for it.
> 

Well, tcp code needs to hold socket lock before mm->mmap_sem, so current
mmap hook can not fit. Or we need to revisit all code doing copyin/copyout while
holding a socket lock. (Not feasible really)


> introducing a multiplexer that overloads a single method certainly
> doesn't help making that case.

Well, if you refer to multiple hooks instead of a single one, I basically
thought that since only TCP needs this hook at the moment,
it was not worth adding extra 8-bytes loads for all other mmap() users.

I have no issue adding more hooks and more memory pressure if this is the blocking factor.

We need two actions at this moment, (to lock the socket or release it)
and a third one would allow us to build the array of pages
before grabbing mmap_sem (as I mentioned in the last patch changelog)
