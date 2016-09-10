Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 583BF6B025E
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 10:56:46 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e1so138689471itb.0
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 07:56:46 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id p35si5951550otb.134.2016.09.10.07.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Sep 2016 07:56:45 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id w193so6065206oiw.2
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 07:56:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DM2PR21MB00899C835BC0AF476B6683CDCBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com> <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com> <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org> <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com> <DM2PR21MB00899C835BC0AF476B6683CDCBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 10 Sep 2016 07:56:43 -0700
Message-ID: <CAPcyv4hKHen_YuY+vEqRocuaE11sptGWWF6kkX1nG8jptvRr+Q@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Sat, Sep 10, 2016 at 1:15 AM, Matthew Wilcox <mawilcox@microsoft.com> wrote:
> From: Dan Williams [mailto:dan.j.williams@intel.com]
>> /me grumbles about top-posting...
>
> Let's see if this does any better .. there's lots of new features, but I don't see a 'wrap lines at 80 columns' option.  Unfortunately.

Much appreciated.

[..]
>> So the current dax implementation is still struggling to get right (pmd faulting,
>> dirty entry cleaning, etc) and this seems like a rewrite that sets us up for future
>> features without addressing the current bugs and todo items.  In comparison
>> the iomap conversion work seems incremental and conserving of current
>> development momentum.
>
> I believe your assessment is incorrect.  If converting the current DAX code to
> use iomap forces converting ext2, then it's time to get rid of all the half-measures
> currently in place.  You left off one todo item that this does get us a step closer to
> fixing -- support for DMA to mmaped DAX files.

I didn't leave that off, DMA is solved with devm_memremap_pages().
Now, DMA without the ~1.6% capacity tax for the memmap array is
interesting, but that's a new feature.

> I think it also puts us in a better
> position to fix the 2MB support, locking, and dirtiness tracking.  Oh, and it does
> fix the multivolume support (because the sectors in the radix tree could be
> interpreted as being from the wrong volume).
>
>> I agree with you that continuing to touch ext2 is not a good idea, but I'm not
>> yet convinced that now is the time to go do dax-2.0 when we haven't finished
>> shipping dax-1.0.
>
> dax-1.0 died long ago ... I think we're up to at least DAX version 4 by now.

My point is that I want to address the current slate of problems
before solving new questions like "how do we support non-block based
filesystems?".  We just happened to land DAX in the middle of the
in-progress buffer_head removal effort, so DAX should not stand in the
way of where filesystems were already going.  I'm arguing to complete
all the false starts and half measures that are presently in DAX and
then look to incrementally evolve the interfaces to something new
without regressing any of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
