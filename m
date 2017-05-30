Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9C76B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 17:43:37 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r58so34271779qtb.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 14:43:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a184si14060165qkc.122.2017.05.30.14.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 14:43:36 -0700 (PDT)
Date: Tue, 30 May 2017 17:43:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 07/15] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v3
Message-ID: <20170530214332.GA6273@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-8-jglisse@redhat.com>
 <20170530164355.GA25891@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170530164355.GA25891@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>

On Tue, May 30, 2017 at 10:43:55AM -0600, Ross Zwisler wrote:
> On Wed, May 24, 2017 at 01:20:16PM -0400, Jerome Glisse wrote:
> > HMM (heterogeneous memory management) need struct page to support migration
> > from system main memory to device memory.  Reasons for HMM and migration to
> > device memory is explained with HMM core patch.
> > 
> > This patch deals with device memory that is un-addressable memory (ie CPU
> > can not access it). Hence we do not want those struct page to be manage
> > like regular memory. That is why we extend ZONE_DEVICE to support different
> > types of memory.
> > 
> > A persistent memory type is define for existing user of ZONE_DEVICE and a
> > new device un-addressable type is added for the un-addressable memory type.
> > There is a clear separation between what is expected from each memory type
> > and existing user of ZONE_DEVICE are un-affected by new requirement and new
> > use of the un-addressable type. All specific code path are protect with
> > test against the memory type.
> > 
> > Because memory is un-addressable we use a new special swap type for when
> > a page is migrated to device memory (this reduces the number of maximum
> > swap file).
> > 
> > The main two additions beside memory type to ZONE_DEVICE is two callbacks.
> > First one, page_free() is call whenever page refcount reach 1 (which means
> > the page is free as ZONE_DEVICE page never reach a refcount of 0). This
> > allow device driver to manage its memory and associated struct page.
> > 
> > The second callback page_fault() happens when there is a CPU access to
> > an address that is back by a device page (which are un-addressable by the
> > CPU). This callback is responsible to migrate the page back to system
> > main memory. Device driver can not block migration back to system memory,
> > HMM make sure that such page can not be pin into device memory.
> > 
> > If device is in some error condition and can not migrate memory back then
> > a CPU page fault to device memory should end with SIGBUS.
> > 
> > Changed since v2:
> >   - s/DEVICE_UNADDRESSABLE/DEVICE_PRIVATE
> > Changed since v1:
> >   - rename to device private memory (from device unaddressable)
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> <>
> > @@ -35,18 +37,88 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
> >  }
> >  #endif
> >  
> > +/*
> > + * Specialize ZONE_DEVICE memory into multiple types each having differents
> > + * usage.
> > + *
> > + * MEMORY_DEVICE_PUBLIC:
> > + * Persistent device memory (pmem): struct page might be allocated in different
> > + * memory and architecture might want to perform special actions. It is similar
> > + * to regular memory, in that the CPU can access it transparently. However,
> > + * it is likely to have different bandwidth and latency than regular memory.
> > + * See Documentation/nvdimm/nvdimm.txt for more information.
> > + *
> > + * MEMORY_DEVICE_PRIVATE:
> > + * Device memory that is not directly addressable by the CPU: CPU can neither
> > + * read nor write _UNADDRESSABLE memory. In this case, we do still have struct
> 		     _PRIVATE
> 
> Just noticed that one holdover from the DEVICE_UNADDRESSABLE naming.
> 

Thanks for catching that, Andrew can you change it yourself to _PRIVATE
s/_UNADDRESSABLE/_PRIVATE

Or should i repost fixed patch ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
