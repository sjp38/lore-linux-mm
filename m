Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 927E46B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 20:48:22 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2940568pbc.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 17:48:21 -0800 (PST)
Message-ID: <50A83E5E.9060300@gmail.com>
Date: Sun, 18 Nov 2012 09:48:14 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils> <20121102014336.GA1727@redhat.com> <alpine.LNX.2.00.1211021606580.11106@eggly.anvils> <alpine.LNX.2.00.1211051729590.963@eggly.anvils> <20121106135402.GA3543@redhat.com> <alpine.LNX.2.00.1211061521230.6954@eggly.anvils> <50A30ADD.9000209@gmail.com> <alpine.LNX.2.00.1211131935410.30540@eggly.anvils> <50A49C46.9040406@gmail.com> <alpine.LNX.2.00.1211151126440.9273@eggly.anvils> <50A6089B.7010708@gmail.com> <alpine.LNX.2.00.1211162018010.1164@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1211162018010.1164@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/17/2012 12:48 PM, Hugh Dickins wrote:
> Further offtopic..

Hi Hugh,

- I see you add this in vfs.txt:
   +  fallocate: called by the VFS to preallocate blocks or punch a hole.
   I want to know if it's necessary to add it to man page since users 
still don't know fallocate can punch a hole from man fallocate.
- in function shmem_fallocate:
+               else if (shmem_falloc.nr_unswapped > 
shmem_falloc.nr_falloced)
+                       error = -ENOMEM;
If this changelog "shmem_fallocate() compare counts and give up once the 
reactivated pages have started to coming back to writepage 
(approximately: some zones would in fact recycle faster than others)." 
describe why need this change? If the answer is yes, I have two questions.
1) how can guarantee it really don't need preallocation if just one or a 
few pages always reactivated, in this scene, nr_unswapped maybe grow 
bigger enough than shmem_falloc.nr_falloced
2) why return -ENOMEM, it's not really OOM, is it a trick or ...?

Regards,
Jaegeuk

>
> On Fri, 16 Nov 2012, Jaegeuk Hanse wrote:
>> Some questions about your shmem/tmpfs: misc and fallocate patchset.
>>
>> - Since shmem_setattr can truncate tmpfs files, why need add another similar
>> codes in function shmem_fallocate? What's the trick?
> I don't know if I understand you.  In general, hole-punching is different
> from truncation.  Supporting the hole-punch mode of the fallocate system
> call is different from supporting truncation.  They're closely related,
> and share code, but meet different specifications.
>
>> - in tmpfs: support fallocate preallocation patch changelog:
>>    "Christoph Hellwig: What for exactly?  Please explain why preallocating on
>> tmpfs would make any sense.
>>    Kay Sievers: To be able to safely use mmap(), regarding SIGBUS, on files on
>> the /dev/shm filesystem.  The glibc fallback loop for -ENOSYS [or
>> -EOPNOTSUPP] on fallocate is just ugly."
>>    Could shmem/tmpfs fallocate prevent one process truncate the file which the
>> second process mmap() and get SIGBUS when the second process access mmap but
>> out of current size of file?
> Again, I don't know if I understand you.  fallocate does not prevent
> truncation or races or SIGBUS.  I believe that Kay meant that without
> using fallocate to allocate the memory in advance, systemd found it hard
> to protect itself from the possibility of getting a SIGBUS, if access to
> a shmem mapping happened to run out of memory/space in the middle.
>
> I never grasped why writing the file in advance was not good enough:
> fallocate happened to be what they hoped to use, and it was hard to
> deny it, given that tmpfs already supported hole-punching, and was
> about to convert to the fallocate interface for that.
>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
