Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D6E876B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 00:06:36 -0400 (EDT)
Message-ID: <1349841989.2759.317.camel@ul30vt.home>
Subject: Re: [PATCH v3 10/10] mm: kill vma flag VM_RESERVED and
 mm->reserved_vm counter
From: Alex Williamson <alex.williamson@redhat.com>
Date: Tue, 09 Oct 2012 22:06:29 -0600
In-Reply-To: <1349823616.2759.308.camel@ul30vt.home>
References: <20120731103724.20515.60334.stgit@zurg>
	 <20120731104239.20515.702.stgit@zurg>
	 <1349776921.21172.4091.camel@edumazet-glaptop>
	 <CA+55aFzCCSE3bnPL7pquYq9pW6YLs_2QZR7r9kZEgwxxc7rzYg@mail.gmail.com>
	 <1349792507.2759.283.camel@ul30vt.home>
	 <1349823616.2759.308.camel@ul30vt.home>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>

On Tue, 2012-10-09 at 17:00 -0600, Alex Williamson wrote:
> On Tue, 2012-10-09 at 08:21 -0600, Alex Williamson wrote:
> > On Tue, 2012-10-09 at 21:12 +0900, Linus Torvalds wrote:
> > > On Tue, Oct 9, 2012 at 7:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >
> > > > It seems drivers/vfio/pci/vfio_pci.c uses VM_RESERVED
> > > 
> > > Yeah, I just pushed out what I think is the right (trivial) fix.
> > 
> > Thank you, looks correct to me as well.
> 
> Well, that might still be correct, but it's actually b3b9c293 (mm, x86,
> pat: rework linear pfn-mmap tracking) that breaks vfio.  As soon as I
> add that commit our use of mmap'd device areas stops working, both
> mapping them through the iommu and through kvm.  kvm hits the BUG_ON
> from !kvm_is_mmio_pfn in virt/kvm/kvm_main.c:hva_to_pfn.  Thanks,

It looks like vfio was for some reason relying on the cow special case
in remap_pfn_range() to set vma->vm_pgoff.  Since we're not doing a
is_cow_mapping, vm_pgoff is no longer updated in that function after
b3b9c293.  I'll add a vfio patch to fix this.  Thanks,

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
