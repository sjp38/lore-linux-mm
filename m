Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DCDC06B00C8
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:26:28 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so2287218vcb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:26:26 -0800 (PST)
Subject: use of alloc_bootmem for a PCI-e device
From: Jean-Francois Dagenais <jeff.dagenais@gmail.com>
Content-Type: text/plain; charset=us-ascii
Message-Id: <9AF7658D-FEDB-479A-8D4F-A54264363CB4@gmail.com>
Date: Wed, 23 Nov 2011 14:30:30 -0500
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Apple Message framework v1084)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello fellow hackers,

I am maintaining a kernel for an embedded product. We have an FPGA
acquisition device interfaced through PCI-e on different intel =
platforms.
The acquisition device needs an extra large physically contiguous memory
area to autonomously dump acquired data into.

In a previous product, VT-d was available and I made use of it to =
allocate
128MB+ using vmalloc, then mapping it so it forms a contiguous address
chunk from the device side.

We are doing another incarnation of the product on an Atom E6xx which =
has
no such IOMMU and am looking into ways of allocating a huge chunk of =
ram.
Kind of like integrated gfx chips do with RAM, but I don't have the =
assistance
of the BIOS.

Based on suggestions to try using alloc_bootmem, I have started looking =
into
it by first making a platform (under arch/x86/platform) built-in module =
using
"pure_initcall" to get an early hook to allocate this memory. This =
approach
failed because the call would happen after SLUB init.

I then proceeded to hack "mm_init()" in init/main.c so that I do the =
alloc_bootmem
call after "mem_init()" but before "kmem_cache_init()". I successfully =
get the huge
chunk I request, and test that it is really physically contiguous.

My joy was not long lived, it was too easy. Once fully booted, I load a =
module
which tests a patter I wrote in memory to see if the memory got touched =
since
the early init moment, and it did. A crude test, but right away tells me =
the
allocation was not respected.

Any thoughts on how to achieve this?

We are targeting v3.1 64 or 32 bits, testing with 3.2-rc1 on x84_64. I =
noticed this
means "nobootmem.c" is used.

Thanks
/jfd=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
