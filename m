Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA7756B0390
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 10:25:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r30so121284061qtc.5
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 07:25:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z88si20928759qtd.288.2017.07.05.07.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 07:25:20 -0700 (PDT)
Date: Wed, 5 Jul 2017 10:25:17 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/5] mm/persistent-memory: match IORES_DESC name and enum
 memory_type one
Message-ID: <20170705142516.GA3305@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com>
 <20170703211415.11283-2-jglisse@redhat.com>
 <CAPcyv4gXso2W0gxaeTsc7g9nTQnkO3WFNZfsdS95NvfYJupnxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gXso2W0gxaeTsc7g9nTQnkO3WFNZfsdS95NvfYJupnxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Jul 03, 2017 at 04:49:18PM -0700, Dan Williams wrote:
> On Mon, Jul 3, 2017 at 2:14 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > Use consistent name between IORES_DESC and enum memory_type, rename
> > MEMORY_DEVICE_PUBLIC to MEMORY_DEVICE_PERSISTENT. This is to free up
> > the public name for CDM (cache coherent device memory) for which the
> > term public is a better match.
> >
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  include/linux/memremap.h | 4 ++--
> >  kernel/memremap.c        | 2 +-
> >  2 files changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> > index 57546a07a558..2299cc2d387d 100644
> > --- a/include/linux/memremap.h
> > +++ b/include/linux/memremap.h
> > @@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >   * Specialize ZONE_DEVICE memory into multiple types each having differents
> >   * usage.
> >   *
> > - * MEMORY_DEVICE_PUBLIC:
> > + * MEMORY_DEVICE_PERSISTENT:
> >   * Persistent device memory (pmem): struct page might be allocated in different
> >   * memory and architecture might want to perform special actions. It is similar
> >   * to regular memory, in that the CPU can access it transparently. However,
> > @@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >   * include/linux/hmm.h and Documentation/vm/hmm.txt.
> >   */
> >  enum memory_type {
> > -       MEMORY_DEVICE_PUBLIC = 0,
> > +       MEMORY_DEVICE_PERSISTENT = 0,
> >         MEMORY_DEVICE_PRIVATE,
> >  };
> >
> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index b9baa6c07918..e82456c39a6a 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
> >         }
> >         pgmap->ref = ref;
> >         pgmap->res = &page_map->res;
> > -       pgmap->type = MEMORY_DEVICE_PUBLIC;
> > +       pgmap->type = MEMORY_DEVICE_PERSISTENT;
> >         pgmap->page_fault = NULL;
> >         pgmap->page_free = NULL;
> >         pgmap->data = NULL;
> 
> I think we need a different name. There's nothing "persistent" about
> the devm_memremap_pages() path. Why can't they share name, is the only
> difference coherence? I'm thinking something like:
> 
> MEMORY_DEVICE_PRIVATE
> MEMORY_DEVICE_COHERENT /* persistent memory and coherent devices */
> MEMORY_DEVICE_IO /* "public", but not coherent */

No that would not work. Device public (in the context of this patchset)
is like device private ie device public page can be anywhere inside a
process address space either as anonymous memory page or as file back
page of regular filesystem (ie vma->ops is not pointing to anything
specific to the device memory).

As such device public is different from how persistent memory is use
and those the cache coherency being the same between the two kind of
memory is not a discerning factor. So i need to distinguish between
persistent memory and device public memory.

I believe keeping enum memory_type close to IORES_DESC naming is the
cleanest way to do that but i am open to other name suggestion.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
