Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id E62386B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 16:22:40 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hs14so7376254lab.3
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 13:22:40 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id wn2si23703012lbb.96.2014.10.13.13.22.38
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 13:22:39 -0700 (PDT)
Date: Mon, 13 Oct 2014 23:22:37 +0300 (EEST)
From: mroos@linux.ee
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141012.132012.254712930139255731.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee>
References: <20141011.221510.1574777235900788349.davem@davemloft.net> <20141012.132012.254712930139255731.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> From: David Miller <davem@davemloft.net>
> Date: Sat, 11 Oct 2014 22:15:10 -0400 (EDT)
> 
> > 
> > I'm getting tons of the following on sparc64:
> > 
> > [603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> > [603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> > [603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0

> In all of the cases, the address is 4-byte aligned but not 8-byte
> aligned.  And they are vmalloc addresses.
> 
> Which made me suspect the percpu commit:
> 
> ====================
> commit bf0dea23a9c094ae869a88bb694fbe966671bf6d
> Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date:   Thu Oct 9 15:26:27 2014 -0700
> 
>     mm/slab: use percpu allocator for cpu cache
> ====================
> 
> And indeed, reverting this commit fixes the problem.

I tested Joonsoo Kim's fix and it gets rid of the kernel unaligned 
access messages, yes.

But the instability on UltraSparc II era machines still remains - 
occassional Bus Errors during kernel compilation, messages like this:

sh[11771]: segfault at ffd6a4d1 ip 00000000f7cc5714 (rpc 00000000f7cc562c) sp 00000000ffd69d90 error 30002 in libc-2.19.so[f7c44000+16a000]

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
