Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id AFA8B6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:26:31 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so212701832wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:26:31 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id u10si2132771wjw.212.2015.09.22.14.26.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 14:26:30 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so180673150wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:26:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150922211716.GA32623@linux.intel.com>
References: <1442950582-10140-1-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4hubJDhWResqaG_aQLSLUVEOujk=EEDVQ1BF+sAdK45LA@mail.gmail.com>
	<20150922211716.GA32623@linux.intel.com>
Date: Tue, 22 Sep 2015 14:26:30 -0700
Message-ID: <CAPcyv4gCPURvPz2es+dMKx4fsusAmmF92=pudd6ddXOpqLZqgQ@mail.gmail.com>
Subject: Re: [PATCH v2] dax: fix NULL pointer in __dax_pmd_fault()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>

On Tue, Sep 22, 2015 at 2:17 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Tue, Sep 22, 2015 at 01:51:04PM -0700, Dan Williams wrote:
>> [ adding Andrew ]
>>
>> On Tue, Sep 22, 2015 at 12:36 PM, Ross Zwisler
>> <ross.zwisler@linux.intel.com> wrote:
>> > The following commit:
>> >
>> > commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for
>> >         DAX")
>> >
>> > moved some code in __dax_pmd_fault() that was responsible for zeroing
>> > newly allocated PMD pages.  The new location didn't properly set up
>> > 'kaddr', though, so when run this code resulted in a NULL pointer BUG.
>> >
>> > Fix this by getting the correct 'kaddr' via bdev_direct_access().
>> >
>> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> > Reported-by: Dan Williams <dan.j.williams@intel.com>
>>
>> Taking into account the comment below,
>>
>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>>
>> > ---
>> >  fs/dax.c | 13 ++++++++++++-
>> >  1 file changed, 12 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/fs/dax.c b/fs/dax.c
>> > index 7ae6df7..bcfb14b 100644
>> > --- a/fs/dax.c
>> > +++ b/fs/dax.c
>> > @@ -569,8 +569,20 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>> >         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
>> >                 goto fallback;
>> >
>> > +       sector = bh.b_blocknr << (blkbits - 9);
>> > +
>> >         if (buffer_unwritten(&bh) || buffer_new(&bh)) {
>> >                 int i;
>> > +
>> > +               length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
>> > +                                               bh.b_size);
>> > +               if (length < 0) {
>> > +                       result = VM_FAULT_SIGBUS;
>> > +                       goto out;
>> > +               }
>> > +               if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
>> > +                       goto fallback;
>> > +
>>
>> Hmm, we don't need the PG_PMD_COLOUR check since we aren't using the
>> pfn in this path, right?
>
> I think we care, because we'll end up bailing anyway at the later
> PG_PMD_COLOUR check before we actually insert the pfn via
> vmf_insert_pfn_pmd().  If we don't check the alignment we'll do 2 MiB worth of
> zeroing to the media, then later fall back to PTE faults.

Ok, good point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
