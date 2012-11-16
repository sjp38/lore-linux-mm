Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2049C6B006C
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 04:34:30 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1983104pbc.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 01:34:29 -0800 (PST)
Message-ID: <50A6089B.7010708@gmail.com>
Date: Fri, 16 Nov 2012 17:34:19 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils> <20121102014336.GA1727@redhat.com> <alpine.LNX.2.00.1211021606580.11106@eggly.anvils> <alpine.LNX.2.00.1211051729590.963@eggly.anvils> <20121106135402.GA3543@redhat.com> <alpine.LNX.2.00.1211061521230.6954@eggly.anvils> <50A30ADD.9000209@gmail.com> <alpine.LNX.2.00.1211131935410.30540@eggly.anvils> <50A49C46.9040406@gmail.com> <alpine.LNX.2.00.1211151126440.9273@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1211151126440.9273@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/16/2012 03:56 AM, Hugh Dickins wrote:
> Offtopic...
>
> On Thu, 15 Nov 2012, Jaegeuk Hanse wrote:
>> Another question. Why the function shmem_fallocate which you add to kernel
>> need call shmem_getpage?
> Because shmem_getpage(_gfp) is where shmem's
> page lookup and allocation complexities are handled.
>
> I assume the question behind your question is: why does shmem actually
> allocate pages for its fallocate, instead of just reserving the space?
>
> I did play with just reserving the space, with more special entries in
> the radix_tree to note the reservations made.  It should be doable for
> the vm_enough_memory and sbinfo->used_blocks reservations.
>
> What absolutely deterred me from taking that path was the mem_cgroup
> case: shmem and swap and memcg are not easy to get working right together,
> and nobody would thank me for complicating memcg just for shmem_fallocate.
>
> By allocating pages, the pre-existing memcg code just works; if we used
> reservations instead, we would have to track their memcg charges in some
> additional new way.  I see no justification for that complication.

Hi Hugh

Some questions about your shmem/tmpfs: misc and fallocate patchset.

- Since shmem_setattr can truncate tmpfs files, why need add another 
similar codes in function shmem_fallocate? What's the trick?
- in tmpfs: support fallocate preallocation patch changelog:
   "Christoph Hellwig: What for exactly?  Please explain why 
preallocating on tmpfs would make any sense.
   Kay Sievers: To be able to safely use mmap(), regarding SIGBUS, on 
files on the /dev/shm filesystem.  The glibc fallback loop for -ENOSYS 
[or -EOPNOTSUPP] on fallocate is just ugly."
   Could shmem/tmpfs fallocate prevent one process truncate the file 
which the second process mmap() and get SIGBUS when the second process 
access mmap but out of current size of file?

Regards,
Jaegeuk

> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
