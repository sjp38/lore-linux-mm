Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id E7F446B0039
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:32 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so10728795pbc.5
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 5si5469225pbj.5.2013.12.11.14.40.29
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:40:30 -0800 (PST)
Subject: [RFC][PATCH 0/3] re-shrink 'struct page' when SLUB is on.
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Dec 2013 14:40:22 -0800
Message-Id: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>

OK, here's the real reason I was digging around for exactly which
fields in 'struct page' slub uses.

SLUB depends on a 16-byte cmpxchg for an optimization.  For the
purposes of this series, I'm assuming that it is a very important
optimization that we desperately need to keep around.

In order to get guaranteed 16-byte alignment (required by the
hardware on x86), 'struct page' is padded out from 56 to 64
bytes.

Those 8-bytes matter.  We've gone to great lengths to keep
'struct page' small in the past.  It's a shame that we bloat it
now just for alignment reasons when we have extra space.  These
patches attempt _internal_ alignment instead of external
alignment for slub.

I also got a bug report from some folks running a large database
benchmark.  Their old kernel uses slab and their new one uses
slub.  They were swapping and couldn't figure out why.  It turned
out to be the 2GB of RAM that the slub padding wastes on their
system.

On my box, that 2GB cost about $200 to populate back when we
bought it.  I want my $200 back.

This is compile tested and lightly runtime tested.  I'm curious
what people think of it before we push it futher.  This is on top
of my previous patch to create a 'struct slab_page', but doesn't
really rely on it.  It could easily be done independently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
