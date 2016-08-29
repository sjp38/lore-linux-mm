Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5A782F64
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 16:54:35 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c189so254179658oia.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:54:35 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id l17si26130908otl.28.2016.08.29.13.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 13:54:34 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id f189so213490125oig.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:54:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1472503455.1532.28.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
 <1472497881-9323-2-git-send-email-toshi.kani@hpe.com> <CAPcyv4hJ1DrCkBCwqm02e1D85wtSPwUaSG2S84JaDJwFWA_4hA@mail.gmail.com>
 <1472503455.1532.28.camel@hpe.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Aug 2016 13:54:33 -0700
Message-ID: <CAPcyv4jrziTR-gRbcjNfk=2C7S8pO5doakA9n8pjLJ3DMWg07w@mail.gmail.com>
Subject: Re: [PATCH v4 RESEND 1/2] thp, dax: add thp_get_unmapped_area for pmd mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, Aug 29, 2016 at 1:44 PM, Kani, Toshimitsu <toshi.kani@hpe.com> wrote:
> On Mon, 2016-08-29 at 12:34 -0700, Dan Williams wrote:
>> On Mon, Aug 29, 2016 at 12:11 PM, Toshi Kani <toshi.kani@hpe.com>
>> wrote:
>> >
>> > When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
>> > size.  This feature relies on both mmap virtual address and FS
>> > block (i.e. physical address) to be aligned by the pmd page size.
>> > Users can use mkfs options to specify FS to align block
>> > allocations. However, aligning mmap address requires code changes
>> > to existing applications for providing a pmd-aligned address to
>> > mmap().
>> >
>> > For instance, fio with "ioengine=mmap" performs I/Os with mmap()
>> > [1]. It calls mmap() with a NULL address, which needs to be changed
>> > to provide a pmd-aligned address for testing with DAX pmd mappings.
>> > Changing all applications that call mmap() with NULL is
>> > undesirable.
>> >
>> > Add thp_get_unmapped_area(), which can be called by filesystem's
>> > get_unmapped_area to align an mmap address by the pmd size for
>> > a DAX file.  It calls the default handler, mm->get_unmapped_area(),
>> > to find a range and then aligns it for a DAX file.
>> >
>> > The patch is based on Matthew Wilcox's change that allows adding
>> > support of the pud page size easily.
>  :
>>
>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>
> Great!
>
>> ...with one minor nit:
>>
>>
>> >
>> >  include/linux/huge_mm.h |    7 +++++++
>> >  mm/huge_memory.c        |   43
>> > +++++++++++++++++++++++++++++++++++++++++++
>> >  2 files changed, 50 insertions(+)
>> >
>> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> > index 6f14de4..4fca526 100644
>> > --- a/include/linux/huge_mm.h
>> > +++ b/include/linux/huge_mm.h
>> > @@ -87,6 +87,10 @@ extern bool is_vma_temporary_stack(struct
>> > vm_area_struct *vma);
>> >
>> >  extern unsigned long transparent_hugepage_flags;
>> >
>> > +extern unsigned long thp_get_unmapped_area(struct file *filp,
>> > +               unsigned long addr, unsigned long len, unsigned
>> > long pgoff,
>> > +               unsigned long flags);
>> > +
>> >  extern void prep_transhuge_page(struct page *page);
>> >  extern void free_transhuge_page(struct page *page);
>> >
>> > @@ -169,6 +173,9 @@ void put_huge_zero_page(void);
>> >  static inline void prep_transhuge_page(struct page *page) {}
>> >
>> >  #define transparent_hugepage_flags 0UL
>> > +
>> > +#define thp_get_unmapped_area  NULL
>>
>> Lets make this:
>>
>> static inline unsigned long thp_get_unmapped_area(struct file *filp,
>>                unsigned long addr, unsigned long len, unsigned long
>> pgoff,
>>                unsigned long flags)
>> {
>>     return 0;
>> }
>>
>> ...to get some type checking in the CONFIG_TRANSPARENT_HUGEPAGE=n
>> case.
>>
>
> Per get_unmapped_area() in mm/mmap.c, I think we need to set it to NULL
> when we do not override current->mm->get_unmapped_area.

Ah, ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
