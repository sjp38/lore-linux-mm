Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D85B66B0254
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:46:58 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so33080419wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:46:58 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id ir10si4818033wjb.206.2015.09.17.08.46.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 08:46:57 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so123739313wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:46:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917154131.GA27791@linux.intel.com>
References: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAA9_cmd9D=7YgZrCf+w3HcckoqcfmCLEHhhm9j+kv+V0ijUnqw@mail.gmail.com>
	<20150916111218.GB23026@node.dhcp.inet.fi>
	<20150917154131.GA27791@linux.intel.com>
Date: Thu, 17 Sep 2015 08:46:57 -0700
Message-ID: <CAPcyv4gYt7vecbHy6w4igFwutLMSsiV8YWBcRH68p7HRFSJ=EA@mail.gmail.com>
Subject: Re: [PATCH] mm: take i_mmap_lock in unmap_mapping_range() for DAX
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>

On Thu, Sep 17, 2015 at 8:41 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Wed, Sep 16, 2015 at 02:12:18PM +0300, Kirill A. Shutemov wrote:
>> On Tue, Sep 15, 2015 at 04:52:42PM -0700, Dan Williams wrote:
>> > Hi Kirill,
>> >
>> > On Fri, Aug 7, 2015 at 4:53 AM, Kirill A. Shutemov
>> > <kirill.shutemov@linux.intel.com> wrote:
>> > > DAX is not so special: we need i_mmap_lock to protect mapping->i_mmap.
>> > >
>> > > __dax_pmd_fault() uses unmap_mapping_range() shoot out zero page from
>> > > all mappings. We need to drop i_mmap_lock there to avoid lock deadlock.
>> > >
>> > > Re-aquiring the lock should be fine since we check i_size after the
>> > > point.
>> > >
>> > > Not-yet-signed-off-by: Matthew Wilcox <willy@linux.intel.com>
>> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > > ---
>> > >  fs/dax.c    | 35 +++++++++++++++++++----------------
>> > >  mm/memory.c | 11 ++---------
>> > >  2 files changed, 21 insertions(+), 25 deletions(-)
>> > >
>> > > diff --git a/fs/dax.c b/fs/dax.c
>> > > index 9ef9b80cc132..ed54efedade6 100644
>> > > --- a/fs/dax.c
>> > > +++ b/fs/dax.c
>> > > @@ -554,6 +554,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>> > >         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
>> > >                 goto fallback;
>> > >
>> > > +       if (buffer_unwritten(&bh) || buffer_new(&bh)) {
>> > > +               int i;
>> > > +               for (i = 0; i < PTRS_PER_PMD; i++)
>> > > +                       clear_page(kaddr + i * PAGE_SIZE);
>> >
>> > This patch, now upstream as commit 46c043ede471, moves the call to
>> > clear_page() earlier in __dax_pmd_fault().  However, 'kaddr' is not
>> > set at this point, so I'm not sure this path was ever tested.
>>
>> Ughh. It's obviously broken.
>>
>> I took fs/dax.c part of the patch from Matthew. And I'm not sure now we
>> would need to move this "if (buffer_unwritten(&bh) || buffer_new(&bh)) {"
>> block around. It should work fine where it was before. Right?
>> Matthew?
>
> Moving the "if (buffer_unwritten(&bh) || buffer_new(&bh)) {" block back seems
> correct to me.  Matthew is out for a while, so we should probably take care of
> this without him.

I'd say leave it at its current location and add a local call to
bdev_direct_access() as I'm not sure you'd want to trigger one of the
failure conditions without having zeroed the page.  I.e. right before
vmf_insert_pfn_pmd() is probably too late.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
