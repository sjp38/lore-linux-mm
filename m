Date: Mon, 14 Oct 2002 05:45:00 -0700 (PDT)
Message-Id: <20021014.054500.89132620.davem@redhat.com>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support,
 2.5.42-F8
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0210141334100.17808-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0210141334100.17808-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   - TLB flush avoidance: the MAP_FIXED overmapping of larger than 4K cache
     units causes a TLB flush, greatly increasing the overhead of 'basic'
     DB cache operations - both the direct overhead and the secondary costs
     of repopulating the TLB cache are signifiant - and will only increase
     with newer CPUs. remap_file_pages() uses the one-page invalidation
     instruction, which does not destroy the TLB.
   
Maybe on your cpu.

We created the range tlb flushes so that architectures have a chance
of optimizing such operations when possible.

If that isn't happening for small numbers of pages on x86 currently,
that isn't justification for special casing it here in this non-linear
mappings code.

If someone does a remap of 1GB of address space, I sure want the
option of doing a full MM flush if that is cheaper on my platform.

Currently, this part smells of an x86 performance hack, which might
even be suboptimal on x86 for remapping of huge ranges.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
