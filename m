Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f207.google.com (mail-ob0-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 3016C6B0035
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 19:29:36 -0500 (EST)
Received: by mail-ob0-f207.google.com with SMTP id wm4so54417obc.10
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 16:29:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id vb7si2656929pbc.32.2013.12.13.15.59.12
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 15:59:12 -0800 (PST)
Subject: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
From: Dave Hansen <dave@sr71.net>
Date: Fri, 13 Dec 2013 15:59:03 -0800
Message-Id: <20131213235903.8236C539@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>

SLUB depends on a 16-byte cmpxchg for an optimization.  For the
purposes of this series, I'm assuming that it is a very important
optimization that we desperately need to keep around.

In order to get guaranteed 16-byte alignment (required by the
hardware on x86), 'struct page' is padded out from 56 to 64
bytes.

Those 8-bytes matter.  We've gone to great lengths to keep
'struct page' small in the past.  It's a shame that we bloat it
now just for alignment reasons when we have extra space.  Plus,
bloating such a commonly-touched structure *HAS* to have cache
footprint implications.

These patches attempt _internal_ alignment instead of external
alignment for slub.

I also got a bug report from some folks running a large database
benchmark.  Their old kernel uses slab and their new one uses
slub.  They were swapping and couldn't figure out why.  It turned
out to be the 2GB of RAM that the slub padding wastes on their
system.

On my box, that 2GB cost about $200 to populate back when we
bought it.  I want my $200 back.

This set takes me from 16909584K of reserved memory at boot
down to 14814472K, so almost *exactly* 2GB of savings!  It also
helps performance, presumably because it touches 14% fewer
struct page cachelines.  A 30GB dd to a ramfs file:

        dd if=/dev/zero of=bigfile bs=$((1<<30)) count=30

is sped up by about 4.4% in my testing.

This is compile tested and lightly runtime tested.  I'm curious
what people think of it before we push it futher.  I believe this
gets rid of the concerns Christoph had about adding additional
branches in the fast path, although I still disagree that this
has any benefit in practice.

I also wrote up a document describing 'struct page's layout:

	http://tinyurl.com/n6kmedz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
