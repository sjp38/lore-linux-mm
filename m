Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EDD2C6B0087
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 08:13:33 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so1380598pab.40
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 05:13:33 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id ci1si39393187pbb.85.2014.09.18.05.13.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Sep 2014 05:13:32 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Thu, 18 Sep 2014 20:13:25 +0800
Subject: RE: [PATCH] arm64:free_initrd_mem should also free the memblock
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB4D6F21@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB029@CNBJMBX05.corpusers.net>
 <20140915183334.GA30737@arm.com>
 <20140915184023.GF12361@n2100.arm.linux.org.uk>
 <20140915185027.GC30737@arm.com>
 <35FD53F367049845BC99AC72306C23D103D6DB49160C@CNBJMBX05.corpusers.net>
 <20140917162822.GB15261@e104818-lin.cambridge.arm.com>
 <20140917181254.GW12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB49161B@CNBJMBX05.corpusers.net>,<20140918095914.GB5182@n2100.arm.linux.org.uk>
In-Reply-To: <20140918095914.GB5182@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

hi=20

(a)
We have pages which are allocated on demand, which are then marked with
the PG_reserved flag to indicate that they are something special.  These
get counted in the statistics as "reserved" pages.  These pages may be
freed at a later time.  These never appear in memblock.

(b)
We have pages which cover the kernel text/data.  These are never freed
once the system is running.  Memblock records a chunk of memory reserved
at boot time for the kernel, so that memblock does not try to allocate
from that region.
(c)
We also have pages which cover the DT and initrd images.  Again, we need
to mark them reserved in memblock so that it doesn't try to allocate from
those regions while we're bringing the kernel up.  However, once the
kernel is running, these areas are freed into the normal memory kernel
memory allocators, but they remain in memblock.


generically to say, the reserved memory i want to know  means all the physi=
cal memory whose
struct page are never placed into buddy system ,
this means memblock.reserve  should include (b) , but not include (a) and (=
c) .

use debugfs to print all struct page which has  PG_reserved is a good idea =
.
But there is a little problem here :
the struct page which has PG_reserved set maybe come from (a) or (b) ,
if memblock.reserve also mark both (a) (b) as reserved ,
we will assume it come from (b) , even it come from (a) ,
this is wrong .

but this special case is very rare , should not a serious problem .

i will think of your new idea for reserved memory debug .

Thanks !




________________________________________
From: Russell King - ARM Linux [linux@arm.linux.org.uk]
Sent: Thursday, September 18, 2014 5:59 PM
To: Wang, Yalin
Cc: Catalin Marinas; Will Deacon; 'linux-mm@kvack.org'; 'linux-kernel@vger.=
kernel.org'; 'linux-arm-kernel@lists.infradead.org'
Subject: Re: [PATCH] arm64:free_initrd_mem should also free the memblock

On Thu, Sep 18, 2014 at 05:38:54PM +0800, Wang, Yalin wrote:
> Hi Russell,
>
> mm..
> I see your meaning,
> But how to debug reserved memory,
> I mean how to know which physical memory are reserved in kernel if
> Not use /sys/kernel/debug/memblock/reserved  debug file ?

What are you trying to do when you say "debug reserved memory" ?
Let's first sort out what you mean by "reserved memory".

We have pages which are allocated on demand, which are then marked with
the PG_reserved flag to indicate that they are something special.  These
get counted in the statistics as "reserved" pages.  These pages may be
freed at a later time.  These never appear in memblock.

We have pages which cover the kernel text/data.  These are never freed
once the system is running.  Memblock records a chunk of memory reserved
at boot time for the kernel, so that memblock does not try to allocate
from that region.

We also have pages which cover the DT and initrd images.  Again, we need
to mark them reserved in memblock so that it doesn't try to allocate from
those regions while we're bringing the kernel up.  However, once the
kernel is running, these areas are freed into the normal memory kernel
memory allocators, but they remain in memblock.

So, even if you solve the third case, your picture of reserved memory
from memblock is still very much incomplete, and adding memblock calls
to all the sites which allocate and then reserve the pages is (a) going
to add unnecessary overhead, and (b) is going to add quite a bit of
complexity all over the kernel.

Let me re-iterate.  memblock is a stepping stone for bringing the kernel
up.  It is used early in boot to provide trivial memory allocation, and
once the main kernel memory allocators are initialised (using allocations
from memblock), memblock becomes mostly redundant - memblocks idea of
reserved areas becomes completely redundant and unnecessary since that
information is now tracked by the main kernel allocators.

It's useful to leave memblock reserved memory in place, because then you
have a picture at early kernel boot which you can then compare with the
page arrays, and see what's changed between early boot and the current
kernels state.  Yes, there is no code to dump out the page array - when
you realise that dumping the page array (which is 262144 entries per
gigabyte of memory) in some generic way becomes quite cumbersome.  The
array itself is around 8MB per gigabyte of memory.

If you want this information, it's probably best to write a custom debugfs
entry which scans the page array, and dumps the regions of reserved memory
(in other words, detects where the PG_reserved flag changes state between
two consecutive pages.)

With such a dump, you can then compare it with the memblock reserved
debugfs file, and check whether the initrd was properly freed, etc.  If
you dump it in the same format as the memblock reserved debugfs, you
can compare the two using diff(1).

The other advantage of this approach is that you're not asking lots of
places in the kernel to gain additional calls to change the state of
something that is never otherwise used.

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
