Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3716B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 18:34:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id o7so134325766oif.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:34:45 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id e129si2081609oib.219.2016.09.09.15.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 15:34:44 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id q188so55600797oia.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:34:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com> <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com> <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org> <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 9 Sep 2016 15:34:43 -0700
Message-ID: <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

/me grumbles about top-posting...

On Fri, Sep 9, 2016 at 1:35 PM, Matthew Wilcox <mawilcox@microsoft.com> wro=
te:
> I feel like we're not only building on shifting sands, but we haven't dec=
ided whether we're building a Pyramid or a Sphinx.
>
> I thought after Storage Summit, we had broad agreement that we were movin=
g to a primary DAX API that was not BH (nor indeed iomap) based.  We would =
still have DAX helpers for block based filesystems (because duplicating all=
 that code between filesystems is pointless), but I now know of three files=
ystems which are not block based that are interested in using DAX.  Jared H=
ulbert's AXFS is a nice public example.
>
> I posted a prototype of this here:
>
> https://groups.google.com/d/msg/linux.kernel/xFFHVCQM7Go/ZQeDVYTnFgAJ
>
> It is, of course, woefully out of date, but some of the principles in it =
are still good (and I'm working to split it into digestible chunks).
>
> The essence:
>
> 1. VFS or VM calls filesystem (eg ->fault())
> 2. Filesystem calls DAX (eg dax_fault())
> 3. DAX looks in radix tree, finds no information.
> 4. DAX calls (NEW!) mapping->a_ops->populate_pfns
> 5a. Filesystem (if not block based) does its own thing to find out the PF=
Ns corresponding to the requested range, then inserts them into the radix t=
ree (possible helper in DAX code)
> 5b. Filesystem (if block based) looks up its internal data structure (eg =
extent tree) and
>    calls dax_create_pfns() (see giant patch from yesterday, only instead =
of
>    passing a get_block_t, the filesystem has already filled in a bh which
>    describes the entire extent that this access happens to land in).
> 6b. DAX takes care of calling bdev_direct_access() from dax_create_pfns()=
.
>
> Now, notice that there's no interaction with the rest of the filesystem h=
ere.  We can swap out BHs and iomaps relatively trivially; there's no call =
for making grand changes, like converting ext2 over to iomap.  The BH or io=
map is only used for communicating the extent from the filesystem to DAX.
>
> Do we have agreement that this is the right way to go?

My $0.02...

So the current dax implementation is still struggling to get right
(pmd faulting, dirty entry cleaning, etc) and this seems like a
rewrite that sets us up for future features without addressing the
current bugs and todo items.  In comparison the iomap conversion work
seems incremental and conserving of current development momentum.

I agree with you that continuing to touch ext2 is not a good idea, but
I'm not yet convinced that now is the time to go do dax-2.0 when we
haven't finished shipping dax-1.0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
