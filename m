Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 518FA6B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 23:48:48 -0500 (EST)
Received: by mail-gh0-f169.google.com with SMTP id r1so709637ghr.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 20:48:47 -0800 (PST)
Date: Fri, 16 Nov 2012 20:48:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
In-Reply-To: <50A6089B.7010708@gmail.com>
Message-ID: <alpine.LNX.2.00.1211162018010.1164@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com> <alpine.LNX.2.00.1211021606580.11106@eggly.anvils> <alpine.LNX.2.00.1211051729590.963@eggly.anvils> <20121106135402.GA3543@redhat.com> <alpine.LNX.2.00.1211061521230.6954@eggly.anvils> <50A30ADD.9000209@gmail.com>
 <alpine.LNX.2.00.1211131935410.30540@eggly.anvils> <50A49C46.9040406@gmail.com> <alpine.LNX.2.00.1211151126440.9273@eggly.anvils> <50A6089B.7010708@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Further offtopic..

On Fri, 16 Nov 2012, Jaegeuk Hanse wrote:
> Some questions about your shmem/tmpfs: misc and fallocate patchset.
> 
> - Since shmem_setattr can truncate tmpfs files, why need add another similar
> codes in function shmem_fallocate? What's the trick?

I don't know if I understand you.  In general, hole-punching is different
from truncation.  Supporting the hole-punch mode of the fallocate system
call is different from supporting truncation.  They're closely related,
and share code, but meet different specifications.

> - in tmpfs: support fallocate preallocation patch changelog:
>   "Christoph Hellwig: What for exactly?  Please explain why preallocating on
> tmpfs would make any sense.
>   Kay Sievers: To be able to safely use mmap(), regarding SIGBUS, on files on
> the /dev/shm filesystem.  The glibc fallback loop for -ENOSYS [or
> -EOPNOTSUPP] on fallocate is just ugly."
>   Could shmem/tmpfs fallocate prevent one process truncate the file which the
> second process mmap() and get SIGBUS when the second process access mmap but
> out of current size of file?

Again, I don't know if I understand you.  fallocate does not prevent
truncation or races or SIGBUS.  I believe that Kay meant that without
using fallocate to allocate the memory in advance, systemd found it hard
to protect itself from the possibility of getting a SIGBUS, if access to
a shmem mapping happened to run out of memory/space in the middle.

I never grasped why writing the file in advance was not good enough:
fallocate happened to be what they hoped to use, and it was hard to
deny it, given that tmpfs already supported hole-punching, and was
about to convert to the fallocate interface for that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
