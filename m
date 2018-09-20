Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2B738E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 17:19:29 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id s69-v6so9993168ota.13
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 14:19:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93-v6sor14547166ote.14.2018.09.20.14.19.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 14:19:28 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
 <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
 <fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com> <20180920224953.GA53363@tiger-server>
In-Reply-To: <20180920224953.GA53363@tiger-server>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Sep 2018 14:19:17 -0700
Message-ID: <CAPcyv4g6OS=_uSjJenn5WVmpx7zCRCbzJaBr_m0Bq=qyEyVagg@mail.gmail.com>
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>

On Thu, Sep 20, 2018 at 7:11 AM Yi Zhang <yi.z.zhang@linux.intel.com> wrote:
>
> On 2018-09-19 at 09:20:25 +0200, David Hildenbrand wrote:
> > Am 19.09.18 um 04:53 schrieb Dan Williams:
> > >
> > > Should we consider just not setting PageReserved for
> > > devm_memremap_pages()? Perhaps kvm is not be the only component making
> > > these assumptions about this flag?
> >
> > I was asking the exact same question in v3 or so.
> >
> > I was recently going through all PageReserved users, trying to clean up
> > and document how it is used.
> >
> > PG_reserved used to be a marker "not available for the page allocator".
> > This is only partially true and not really helpful I think. My current
> > understanding:
> >
> > "
> > PG_reserved is set for special pages, struct pages of such pages should
> > in general not be touched except by their owner. Pages marked as
> > reserved include:
> > - Kernel image (including vDSO) and similar (e.g. BIOS, initrd)
> > - Pages allocated early during boot (bootmem, memblock)
> > - Zero pages
> > - Pages that have been associated with a zone but were not onlined
> >   (e.g. NVDIMM/pmem, online_page_callback used by XEN)
> > - Pages to exclude from the hibernation image (e.g. loaded kexec images)
> > - MCA (memory error) pages on ia64
> > - Offline pages
> > Some architectures don't allow to ioremap RAM pages that are not marked
> > as reserved. Allocated pages might have to be set reserved to allow for
> > that - if there is a good reason to enforce this. Consequently,
> > PG_reserved part of a user space table might be the indicator for the
> > zero page, pmem or MMIO pages.
> > "
> >
> > Swapping code does not care about PageReserved at all as far as I
> > remember. This seems to be fine as it only looks at the way pages have
> > been mapped into user space.
> >
> > I don't really see a good reason to set pmem pages as reserved. One
> > question would be, how/if to exclude them from the hibernation image.
> > But that could also be solved differently (we would have to double check
> > how they are handled in hibernation code).
> >
> >
> > A similar user of PageReserved to look at is:
> >
> > drivers/vfio/vfio_iommu_type1.c:is_invalid_reserved_pfn()
> >
> > It will not mark pages dirty if they are reserved. Similar to KVM code.
> Yes, kvm is not the only one user of the dax reserved page.
> >
> > >
> > > Why is MEMORY_DEVICE_PUBLIC memory specifically excluded?
> > >
> > > This has less to do with "dax" pages and more to do with
> > > devm_memremap_pages() established ranges. P2PDMA is another producer
> > > of these pages. If either MEMORY_DEVICE_PUBLIC or P2PDMA pages can be
> > > used in these kvm paths then I think this points to consider clearing
> > > the Reserved flag.
>
> Thanks Dan/David's comments.
> for MEMORY_DEVICE_PUBLIC memory, since host driver could manager the
> memory resource to share to guest, Jerome says we could ignore it at
> this time.
>
> And p2pmem, it seems mapped in a PCI bar space which should most likely
> a mmio. I think kvm should treated as a reserved page.

Ok, but the question you left unanswered is whether it would be better
for devm_memremap_pages() to clear the PageReserved flag for
MEMORY_DEVICE_{FS,DEV}_DAX rather than introduce a local kvm-only hack
for what looks like a global problem.
