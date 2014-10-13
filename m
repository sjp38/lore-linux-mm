Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 58A896B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 19:51:56 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so6495212pdj.9
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 16:51:56 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id hc9si11481293pac.184.2014.10.13.16.51.53
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 16:51:54 -0700 (PDT)
Date: Tue, 14 Oct 2014 08:52:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: unaligned accesses in SLAB etc.
Message-ID: <20141013235219.GA11191@js1304-P5Q-DELUXE>
References: <20141011.221510.1574777235900788349.davem@davemloft.net>
 <20141012.132012.254712930139255731.davem@davemloft.net>
 <alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: David Miller <davem@davemloft.net>, Linux Kernel list <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Mon, Oct 13, 2014 at 11:22:37PM +0300, mroos@linux.ee wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Sat, 11 Oct 2014 22:15:10 -0400 (EDT)
> > 
> > > 
> > > I'm getting tons of the following on sparc64:
> > > 
> > > [603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> > > [603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
> > > [603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
> 
> > In all of the cases, the address is 4-byte aligned but not 8-byte
> > aligned.  And they are vmalloc addresses.
> > 
> > Which made me suspect the percpu commit:
> > 
> > ====================
> > commit bf0dea23a9c094ae869a88bb694fbe966671bf6d
> > Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Date:   Thu Oct 9 15:26:27 2014 -0700
> > 
> >     mm/slab: use percpu allocator for cpu cache
> > ====================
> > 
> > And indeed, reverting this commit fixes the problem.
> 
> I tested Joonsoo Kim's fix and it gets rid of the kernel unaligned 
> access messages, yes.
> 
> But the instability on UltraSparc II era machines still remains - 
> occassional Bus Errors during kernel compilation, messages like this:
> 
> sh[11771]: segfault at ffd6a4d1 ip 00000000f7cc5714 (rpc 00000000f7cc562c) sp 00000000ffd69d90 error 30002 in libc-2.19.so[f7c44000+16a000]

Hello, Meelis.

Thanks for testing.

I'd like to know that your another problem is related to commit
bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").
So, if the commit is reverted, your another problem is also gone completely?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
