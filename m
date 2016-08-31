Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7281A82F64
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:36:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so11791980pfb.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:36:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b64si1687753pfa.51.2016.08.31.14.36.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 14:36:09 -0700 (PDT)
Date: Wed, 31 Aug 2016 15:36:07 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/9] re-enable DAX PMD support
Message-ID: <20160831213607.GA6921@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160830230150.GA12173@linux.intel.com>
 <1472674799.2092.19.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1472674799.2092.19.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "jack@suse.com" <jack@suse.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, Aug 31, 2016 at 08:20:48PM +0000, Kani, Toshimitsu wrote:
> On Tue, 2016-08-30 at 17:01 -0600, Ross Zwisler wrote:
> > On Tue, Aug 23, 2016 at 04:04:10PM -0600, Ross Zwisler wrote:
> > > 
> > > DAX PMDs have been disabled since Jan Kara introduced DAX radix
> > > tree based locking.  This series allows DAX PMDs to participate in
> > > the DAX radix tree based locking scheme so that they can be re-
> > > enabled.
> > > 
> > > Changes since v1:
> > >  - PMD entry locking is now done based on the starting offset of
> > > the PMD entry, rather than on the radix tree slot which was
> > > unreliable. (Jan)
> > >  - Fixed the one issue I could find with hole punch.  As far as I
> > > can tell hole punch now works correctly for both PMD and PTE DAX
> > > entries, 4k zero pages and huge zero pages.
> > >  - Fixed the way that ext2 returns the size of holes in
> > > ext2_get_block(). (Jan)
> > >  - Made the 'wait_table' global variable static in respnse to a
> > > sparse warning.
> > >  - Fixed some more inconsitent usage between the names 'ret' and
> > > 'entry' for radix tree entry variables.
> > > 
> > > Ross Zwisler (9):
> > >   ext4: allow DAX writeback for hole punch
> > >   ext2: tell DAX the size of allocation holes
> > >   ext4: tell DAX the size of allocation holes
> > >   dax: remove buffer_size_valid()
> > >   dax: make 'wait_table' global variable static
> > >   dax: consistent variable naming for DAX entries
> > >   dax: coordinate locking for offsets in PMD range
> > >   dax: re-enable DAX PMD support
> > >   dax: remove "depends on BROKEN" from FS_DAX_PMD
> > > 
> > >  fs/Kconfig          |   1 -
> > >  fs/dax.c            | 297 +++++++++++++++++++++++++++++-----------
> > > ------------
> > >  fs/ext2/inode.c     |   3 +
> > >  fs/ext4/inode.c     |   7 +-
> > >  include/linux/dax.h |  29 ++++-
> > >  mm/filemap.c        |   6 +-
> > >  6 files changed, 201 insertions(+), 142 deletions(-)
> > > 
> > > -- 
> > > 2.9.0
> > 
> > Ping on this series?  Any objections or comments?
> 
> Hi Ross,
> 
> I am seeing a major performance loss in fio mmap test with this patch-
> set applied.  This happens with or without my patches [1] applied on
> top of yours.  Without my patches, dax_pmd_fault() falls back to the
> pte handler since an mmap'ed address is not 2MB-aligned.
> 
> I have attached three test results.
>  o rc4.log - 4.8.0-rc4 (base)
>  o non-pmd.log - 4.8.0-rc4 + your patchset (fall back to pte)
>  o pmd.log - 4.8.0-rc4 + your patchset + my patchset (use pmd maps)
> 
> My test steps are as follows.
> 
> mkfs.ext4 -O bigalloc -C 2M /dev/pmem0
> mount -o dax /dev/pmem0 /mnt/pmem0
> numactl --preferred block:pmem0 --cpunodebind block:pmem0 fio test.fio
> 
> "test.fio"
> ---
> [global]
> bs=4k
> size=2G
> directory=/mnt/pmem0
> ioengine=mmap
> [randrw]
> rw=randrw
> ---
> 
> Can you please take a look?

Yep, thanks for the report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
