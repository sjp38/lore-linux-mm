Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF6976B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 22:05:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b64so10397073pfl.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 19:05:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u185si12185105pfu.339.2018.04.23.19.04.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 19:04:58 -0700 (PDT)
Received: from mail-wr0-f172.google.com (mail-wr0-f172.google.com [209.85.128.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CE166217CE
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:04:57 +0000 (UTC)
Received: by mail-wr0-f172.google.com with SMTP id z73-v6so46233409wrb.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 19:04:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d5b4dc70-6f17-d2be-a519-5ebc3f812f57@gmail.com>
References: <20180420155542.122183-1-edumazet@google.com> <9ed6083f-d731-945c-dbcd-f977c5600b03@kernel.org>
 <d5b4dc70-6f17-d2be-a519-5ebc3f812f57@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 23 Apr 2018 19:04:36 -0700
Message-ID: <CALCETrWOLU+P_jVpuOUQT2e_5ZShAP3OM0yJZMbC=pv5La9Cvg@mail.gmail.com>
Subject: Re: [PATCH net-next 0/4] mm,tcp: provide mmap_hook to solve lockdep issue
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Soheil Hassas Yeganeh <soheil@google.com>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Apr 23, 2018 at 2:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> Hi Andy
>
> On 04/23/2018 02:14 PM, Andy Lutomirski wrote:

>> I would suggest that you rework the interface a bit.  First a user would=
 call mmap() on a TCP socket, which would create an empty VMA.  (It would s=
et vm_ops to point to tcp_vm_ops or similar so that the TCP code could reco=
gnize it, but it would have no effect whatsoever on the TCP state machine. =
 Reading the VMA would get SIGBUS.)  Then a user would call a new ioctl() o=
r setsockopt() function and pass something like:
>
>
>>
>> struct tcp_zerocopy_receive {
>>   void *address;
>>   size_t length;
>> };
>>
>> The kernel would verify that [address, address+length) is entirely insid=
e a single TCP VMA and then would do the vm_insert_range magic.
>
> I have no idea what is the proper API for that.
> Where the TCP VMA(s) would be stored ?
> In TCP socket, or MM layer ?

MM layer.  I haven't tested this at all, and the error handling is
totally wrong, but I think you'd do something like:

len =3D get_user(...);

down_read(&current->mm->mmap_sem);

vma =3D find_vma(mm, start);
if (!vma || vma->vm_start > start)
  return -EFAULT;

/* This is buggy.  You also need to check that the file is a socket.
This is probably trivial. */
if (vma->vm_file->private_data !=3D sock)
  return -EINVAL;

if (len > vma->vm_end - start)
  return -EFAULT;  /* too big a request. */

and now you'd do the vm_insert_page() dance, except that you don't
have to abort the whole procedure if you discover that something isn't
aligned right.  Instead you'd just stop and tell the caller that you
didn't map the full requested size.  You might also need to add some
code to charge the caller for the pages that get pinned, but that's an
orthogonal issue.

You also need to provide some way for user programs to signal that
they're done with the page in question.  MADV_DONTNEED might be
sufficient.

In the mmap() helper, you might want to restrict the mapped size to
something reasonable.  And it might be nice to hook mremap() to
prevent user code from causing too much trouble.

With my x86-writer-of-TLB-code hat on, I expect the major performance
costs to be the generic costs of mmap() and munmap() (which only
happen once per socket instead of once per read if you like my idea),
the cost of a TLB miss when the data gets read (really not so bad on
modern hardware), and the cost of the TLB invalidation when user code
is done with the buffers.  The latter is awful, especially in
multithreaded programs.  In fact, it's so bad that it might be worth
mentioning in the documentation for this code that it just shouldn't
be used in multithreaded processes.  (Also, on non-PCID hardware,
there's an annoying situation in which a recently-migrated thread that
removes a mapping sends an IPI to the CPU that the thread used to be
on.  I thought I had a clever idea to get rid of that IPI once, but it
turned out to be wrong.)

Architectures like ARM that have superior TLB handling primitives will
not be hurt as badly if this is used my a multithreaded program.

>
>
> And I am not sure why the error handling would be better (point 4), unles=
s we can return smaller @length than requested maybe ?

Exactly.  If I request 10MB mapped and only the first 9MB are aligned
right, I still want the first 9 MB.

>
> Also how the VMA space would be accounted (point 3) when creating an empt=
y VMA (no pages in there yet)

There's nothing to account.  It's the same as mapping /dev/null or
similar -- the mm core should take care of it for you.
