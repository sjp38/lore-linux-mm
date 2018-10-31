Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F135E6B026D
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:27:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d8-v6so11489855pgq.3
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:27:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x15-v6si3674792pll.41.2018.10.31.06.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Oct 2018 06:27:54 -0700 (PDT)
Date: Wed, 31 Oct 2018 06:27:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Message-ID: <20181031132751.GL10491@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com>
 <CANRm+Cy2K08MCWq0mtqor66Uz8g-MaVKb=JDGD0WostFeogKSA@mail.gmail.com>
 <CALMp9eSAP6=3MOjcexZsrtGjg4z6ULjhaJZBOZCkpFKganKfhA@mail.gmail.com>
 <20181029164813.GH28520@bombadil.infradead.org>
 <CAA03e5GT4gR4iN-na0PR_oTrXKVuD8BRcHcR8Y58==eRae3iXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5GT4gR4iN-na0PR_oTrXKVuD8BRcHcR8Y58==eRae3iXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: Jim Mattson <jmattson@google.com>, Wanpeng Li <kernellwp@gmail.com>, kvm@vger.kernel.org, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Wed, Oct 31, 2018 at 01:17:40PM +0000, Marc Orr wrote:
> All that being said, I don't really understand why we wouldn't convert
> this memory allocation from a kmalloc() into a vmalloc(). From my
> point of view, we are still close to bloating vcpu_vmx into an order 3
> allocation, and it's common for vendors to append to both vcpu_vmx
> directly, or more likely to its embedded structs. Though, arguably,
> vendors should not be doing that.
> 
> Most importantly, it just isn't obvious to me why kmalloc() is
> preferred over vmalloc(). From my point of view, vmalloc() does the
> exact same thing as kmalloc(), except that it works when contiguous
> memory is sparse, which seems better to me.

It's ever-so-slightly faster to access kmalloc memory than vmalloc memory;
kmalloc memory comes from the main kernel mapping, generally mapped with
1GB pages while vmalloc memory is necessarily accessed using 4kB pages,
taking an extra two steps in the page table hierarchy.  There's more
software overhead involved too; in addition to allocating the physical
pages (which both kmalloc and vmalloc have to do), vmalloc has to allocate
a vmap_area and a vm_struct to describe the virtual mapping.

The virtual address space can also get fragmented, just like the physical
address space does, potentially leading to the amusing scenario where
you can allocate physically contiguous memory, but not find a contiguous
chunk of vmalloc space to put it in.

For larger allocations, we tend to prefer kvmalloc() which gives us
the best of both worlds, allocating from kmalloc first and vmalloc as a
fallback, but you've got some fun gyrations to go through to do physical
mapping, so that's not entirely appropriate for your case.
