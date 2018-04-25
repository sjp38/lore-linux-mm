Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 833076B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:44:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so9278256pfm.20
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:44:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor3831426pgc.50.2018.04.25.09.44.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 09:44:13 -0700 (PDT)
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org>
 <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
 <20180425160413.GC8546@bombadil.infradead.org>
 <CALCETrWaekirEe+rKiPB-Zim6ZHKL-n7nfk9wrsHra_FtrS=DA@mail.gmail.com>
 <155a86d5-a910-c366-f521-216a0582bad8@gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <38aa7986-b367-882d-2669-d8525a520310@gmail.com>
Date: Wed, 25 Apr 2018 09:44:11 -0700
MIME-Version: 1.0
In-Reply-To: <155a86d5-a910-c366-f521-216a0582bad8@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>



On 04/25/2018 09:35 AM, Eric Dumazet wrote:
> 
> 
> On 04/25/2018 09:22 AM, Andy Lutomirski wrote:
> 
>> In general, I suspect that the zerocopy receive mechanism will only
>> really be a win in single-threaded applications that consume large
>> amounts of receive bandwidth on a single TCP socket using lots of
>> memory and don't do all that much else.
> 
> This was dully noted in the original patch submission.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=309c446cb45f6663932c8e6d0754f4ac81d1b5cd
> 
> Our intent at Google is to use it for some specific 1MB+ receives, not as a generic and universal mechanism.
> 
> The major benefit is really the 4KB+ MTU, allowing to pack exactly 4096 bytes of payload per page.
> 

Some perf numbers with 10 concurrent threads in tcp_mmap with zero copy enabled :
(tcp_mmap uses 512 KB chunks, not 1MB ones)

received 32768 MB (100 % mmap'ed) in 28.3054 s, 9.71116 Gbit
  cpu usage user:0.039 sys:1.946, 60.5774 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 28.2504 s, 9.73004 Gbit
  cpu usage user:0.052 sys:1.941, 60.8215 usec per MB, 65536 c-switches
received 32768 MB (99.9998 % mmap'ed) in 28.2508 s, 9.72993 Gbit
  cpu usage user:0.056 sys:1.915, 60.1501 usec per MB, 65539 c-switches
received 32768 MB (100 % mmap'ed) in 28.2544 s, 9.72866 Gbit
  cpu usage user:0.053 sys:1.966, 61.615 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 115.985 s, 2.36995 Gbit
  cpu usage user:0.057 sys:2.492, 77.7893 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 62.633 s, 4.38871 Gbit
  cpu usage user:0.048 sys:2.076, 64.8193 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 59.4608 s, 4.62285 Gbit
  cpu usage user:0.047 sys:1.965, 61.4014 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 119.364 s, 2.30285 Gbit
  cpu usage user:0.057 sys:2.757, 85.8765 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 121.37 s, 2.2648 Gbit
  cpu usage user:0.05 sys:2.224, 69.397 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 121.382 s, 2.26457 Gbit
  cpu usage user:0.049 sys:2.163, 67.5049 usec per MB, 65538 c-switches
received 32768 MB (100 % mmap'ed) in 39.7636 s, 6.91281 Gbit
  cpu usage user:0.055 sys:2.053, 64.3311 usec per MB, 65536 c-switches
received 32768 MB (100 % mmap'ed) in 21.2803 s, 12.917 Gbit
  cpu usage user:0.043 sys:2.057, 64.0869 usec per MB, 65537 c-switches

When zero copy is not enabled :

received 32768 MB (0 % mmap'ed) in 49.4301 s, 5.56094 Gbit
  cpu usage user:0.036 sys:6.747, 207.001 usec per MB, 65546 c-switches
received 32768 MB (0 % mmap'ed) in 49.431 s, 5.56084 Gbit
  cpu usage user:0.042 sys:5.262, 161.865 usec per MB, 65540 c-switches
received 32768 MB (0 % mmap'ed) in 84.7254 s, 3.24434 Gbit
  cpu usage user:0.045 sys:5.154, 158.661 usec per MB, 65548 c-switches
received 32768 MB (0 % mmap'ed) in 84.7274 s, 3.24426 Gbit
  cpu usage user:0.043 sys:6.528, 200.531 usec per MB, 65542 c-switches
received 32768 MB (0 % mmap'ed) in 35.3133 s, 7.78398 Gbit
  cpu usage user:0.032 sys:5.066, 155.579 usec per MB, 65540 c-switches
received 32768 MB (0 % mmap'ed) in 35.3137 s, 7.78389 Gbit
  cpu usage user:0.034 sys:6.358, 195.068 usec per MB, 65536 c-switches
received 32768 MB (0 % mmap'ed) in 98.8568 s, 2.78057 Gbit
  cpu usage user:0.042 sys:6.519, 200.226 usec per MB, 65550 c-switches
received 32768 MB (0 % mmap'ed) in 98.8638 s, 2.78037 Gbit
  cpu usage user:0.042 sys:5.243, 161.285 usec per MB, 65545 c-switches
received 32768 MB (0 % mmap'ed) in 108.282 s, 2.53853 Gbit
  cpu usage user:0.059 sys:5.938, 183.014 usec per MB, 65538 c-switches
received 32768 MB (0 % mmap'ed) in 108.314 s, 2.53778 Gbit
  cpu usage user:0.04 sys:6.096, 187.256 usec per MB, 65548 c-switches
received 32768 MB (0 % mmap'ed) in 29.4351 s, 9.33845 Gbit
  cpu usage user:0.041 sys:6.03, 185.272 usec per MB, 65536 c-switches
received 32768 MB (0 % mmap'ed) in 44.3993 s, 6.19104 Gbit
  cpu usage user:0.034 sys:5.115, 157.135 usec per MB, 65535 c-switches
received 32768 MB (0 % mmap'ed) in 79.7203 s, 3.44803 Gbit
  cpu usage user:0.046 sys:5.214, 160.522 usec per MB, 65540 c-switches
