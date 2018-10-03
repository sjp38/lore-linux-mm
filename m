Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFD26B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:56:23 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id s68so4154865ota.11
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:56:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11-v6sor1056878oif.143.2018.10.03.09.56.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 09:56:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180824154542.26872-1-jack@suse.cz> <20181003163557.GA18434@thunk.org>
In-Reply-To: <20181003163557.GA18434@thunk.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 3 Oct 2018 09:56:09 -0700
Message-ID: <CAPcyv4hxxcC6dkeN80MXaHx9A-kw1fn=Yjqi5uGRdFueVRFXbg@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix warning in insert_pfn()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>

On Wed, Oct 3, 2018 at 9:40 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> On Fri, Aug 24, 2018 at 05:45:42PM +0200, Jan Kara wrote:
> > In DAX mode a write pagefault can race with write(2) in the following
> > way:
> >
> > CPU0                            CPU1
> >                                 write fault for mapped zero page (hole)
> > dax_iomap_rw()
> >   iomap_apply()
> >     xfs_file_iomap_begin()
> >       - allocates blocks
> >     dax_iomap_actor()
> >       invalidate_inode_pages2_range()
> >         - invalidates radix tree entries in given range
> >                                 dax_iomap_pte_fault()
> >                                   grab_mapping_entry()
> >                                     - no entry found, creates empty
> >                                   ...
> >                                   xfs_file_iomap_begin()
> >                                     - finds already allocated block
> >                                   ...
> >                                   vmf_insert_mixed_mkwrite()
> >                                     - WARNs and does nothing because there
> >                                       is still zero page mapped in PTE
> >         unmap_mapping_pages()
> >
> > This race results in WARN_ON from insert_pfn() and is occasionally
> > triggered by fstest generic/344. Note that the race is otherwise
> > harmless as before write(2) on CPU0 is finished, we will invalidate page
> > tables properly and thus user of mmap will see modified data from
> > write(2) from that point on. So just restrict the warning only to the
> > case when the PFN in PTE is not zero page.
> >
> > Signed-off-by: Jan Kara <jack@suse.cz>
>
> I don't see this in linux-next.  What's the status of this patch?
>

It's in Andrew's tree. I believe we are awaiting the next -next
release to rebase on latest mmotm.
