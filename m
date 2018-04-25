Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 071EA6B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:01:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f19so8875165pgv.4
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 06:01:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15sor4003231pgr.203.2018.04.25.06.01.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 06:01:40 -0700 (PDT)
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
Date: Wed, 25 Apr 2018 06:01:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180425062859.GA23914@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>



On 04/24/2018 11:28 PM, Christoph Hellwig wrote:
> On Tue, Apr 24, 2018 at 10:27:21PM -0700, Eric Dumazet wrote:
>> When adding tcp mmap() implementation, I forgot that socket lock
>> had to be taken before current->mm->mmap_sem. syzbot eventually caught
>> the bug.
>>
>> Since we can not lock the socket in tcp mmap() handler we have to
>> split the operation in two phases.
>>
>> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
>>   This operation does not involve any TCP locking.
>>
>> 2) setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
>>  the transfert of pages from skbs to one VMA.
>>   This operation only uses down_read(&current->mm->mmap_sem) after
>>   holding TCP lock, thus solving the lockdep issue.
>>
>> This new implementation was suggested by Andy Lutomirski with great details.
> 
> Thanks, this looks much more sensible to me.
> 

Thanks Christoph

Note the high cost of zap_page_range(), needed to avoid -EBUSY being returned
from vm_insert_page() the second time TCP_ZEROCOPY_RECEIVE is used on one VMA.

Ideally a vm_replace_page() would avoid this cost ?

     6.51%  tcp_mmap  [kernel.kallsyms]  [k] unmap_page_range                                         
     5.90%  tcp_mmap  [kernel.kallsyms]  [k] vm_insert_page                                           
     4.85%  tcp_mmap  [kernel.kallsyms]  [k] _raw_spin_lock                                           
     4.50%  tcp_mmap  [kernel.kallsyms]  [k] mark_page_accessed                                       
     3.51%  tcp_mmap  [kernel.kallsyms]  [k] page_remove_rmap                                         
     2.99%  tcp_mmap  [kernel.kallsyms]  [k] page_add_file_rmap                                       
     2.53%  tcp_mmap  [kernel.kallsyms]  [k] release_pages                                            
     2.38%  tcp_mmap  [kernel.kallsyms]  [k] put_page                                                 
     2.37%  tcp_mmap  [kernel.kallsyms]  [k] smp_call_function_single                                 
     2.28%  tcp_mmap  [kernel.kallsyms]  [k] __get_locked_pte                                         
     2.25%  tcp_mmap  [kernel.kallsyms]  [k] do_tcp_setsockopt.isra.35                                
     2.21%  tcp_mmap  [kernel.kallsyms]  [k] page_clear_age                         
