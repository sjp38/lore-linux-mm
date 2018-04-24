Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDB5B6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 00:30:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k3so12098966pff.23
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 21:30:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2-v6sor4583443plt.87.2018.04.23.21.30.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 21:30:37 -0700 (PDT)
Subject: Re: [PATCH net-next 0/4] mm,tcp: provide mmap_hook to solve lockdep
 issue
References: <20180420155542.122183-1-edumazet@google.com>
 <9ed6083f-d731-945c-dbcd-f977c5600b03@kernel.org>
 <d5b4dc70-6f17-d2be-a519-5ebc3f812f57@gmail.com>
 <CALCETrWOLU+P_jVpuOUQT2e_5ZShAP3OM0yJZMbC=pv5La9Cvg@mail.gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <e494c904-bdd0-8c6c-0592-c4960dcf2865@gmail.com>
Date: Mon, 23 Apr 2018 21:30:34 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrWOLU+P_jVpuOUQT2e_5ZShAP3OM0yJZMbC=pv5La9Cvg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Soheil Hassas Yeganeh <soheil@google.com>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>



On 04/23/2018 07:04 PM, Andy Lutomirski wrote:
> On Mon, Apr 23, 2018 at 2:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Hi Andy
>>
>> On 04/23/2018 02:14 PM, Andy Lutomirski wrote:
> 
>>> I would suggest that you rework the interface a bit.  First a user would call mmap() on a TCP socket, which would create an empty VMA.  (It would set vm_ops to point to tcp_vm_ops or similar so that the TCP code could recognize it, but it would have no effect whatsoever on the TCP state machine.  Reading the VMA would get SIGBUS.)  Then a user would call a new ioctl() or setsockopt() function and pass something like:
>>
>>
>>>
>>> struct tcp_zerocopy_receive {
>>>   void *address;
>>>   size_t length;
>>> };
>>>
>>> The kernel would verify that [address, address+length) is entirely inside a single TCP VMA and then would do the vm_insert_range magic.
>>
>> I have no idea what is the proper API for that.
>> Where the TCP VMA(s) would be stored ?
>> In TCP socket, or MM layer ?
> 
> MM layer.  I haven't tested this at all, and the error handling is
> totally wrong, but I think you'd do something like:
> 
> len = get_user(...);
> 
> down_read(&current->mm->mmap_sem);
> 
> vma = find_vma(mm, start);
> if (!vma || vma->vm_start > start)
>   return -EFAULT;
> 
> /* This is buggy.  You also need to check that the file is a socket.
> This is probably trivial. */
> if (vma->vm_file->private_data != sock)
>   return -EINVAL;
> 
> if (len > vma->vm_end - start)
>   return -EFAULT;  /* too big a request. */
> 
> and now you'd do the vm_insert_page() dance, except that you don't
> have to abort the whole procedure if you discover that something isn't
> aligned right.  Instead you'd just stop and tell the caller that you
> didn't map the full requested size.  You might also need to add some
> code to charge the caller for the pages that get pinned, but that's an
> orthogonal issue.
> 
> You also need to provide some way for user programs to signal that
> they're done with the page in question.  MADV_DONTNEED might be
> sufficient.
> 
> In the mmap() helper, you might want to restrict the mapped size to
> something reasonable.  And it might be nice to hook mremap() to
> prevent user code from causing too much trouble.
> 
> With my x86-writer-of-TLB-code hat on, I expect the major performance
> costs to be the generic costs of mmap() and munmap() (which only
> happen once per socket instead of once per read if you like my idea),
> the cost of a TLB miss when the data gets read (really not so bad on
> modern hardware), and the cost of the TLB invalidation when user code
> is done with the buffers.  The latter is awful, especially in
> multithreaded programs.  In fact, it's so bad that it might be worth
> mentioning in the documentation for this code that it just shouldn't
> be used in multithreaded processes.  (Also, on non-PCID hardware,
> there's an annoying situation in which a recently-migrated thread that
> removes a mapping sends an IPI to the CPU that the thread used to be
> on.  I thought I had a clever idea to get rid of that IPI once, but it
> turned out to be wrong.)
> 
> Architectures like ARM that have superior TLB handling primitives will
> not be hurt as badly if this is used my a multithreaded program.
> 
>>
>>
>> And I am not sure why the error handling would be better (point 4), unless we can return smaller @length than requested maybe ?
> 
> Exactly.  If I request 10MB mapped and only the first 9MB are aligned
> right, I still want the first 9 MB.
> 
>>
>> Also how the VMA space would be accounted (point 3) when creating an empty VMA (no pages in there yet)
> 
> There's nothing to account.  It's the same as mapping /dev/null or
> similar -- the mm core should take care of it for you.
> 

Thanks Andy, I am working on all this, and initial patch looks sane enough.

 include/uapi/linux/tcp.h |    7 +
 net/ipv4/tcp.c           |  175 +++++++++++++++++++++++------------------------
 2 files changed, 93 insertions(+), 89 deletions(-)


I will test all this before sending for review asap.

( I have not done the compat code yet, this can be done later I guess)
