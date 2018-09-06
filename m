Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 373166B78B7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:26:46 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e6-v6so2228835ljl.9
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:26:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91-v6sor1869750lfs.27.2018.09.06.05.26.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 05:26:44 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004f6b5805751a8189@google.com> <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org> <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
 <20180906083800.GC19319@quack2.suse.cz>
In-Reply-To: <20180906083800.GC19319@quack2.suse.cz>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 6 Sep 2018 17:56:31 +0530
Message-ID: <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
Subject: Re: linux-next test error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, Matthew Wilcox <willy@infradead.org>

On Thu, Sep 6, 2018 at 2:08 PM Jan Kara <jack@suse.cz> wrote:
>
> On Thu 06-09-18 00:54:50, Souptick Joarder wrote:
> > On Wed, Sep 5, 2018 at 7:05 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
> > >
> > > On Wed, Sep 05, 2018 at 03:20:16PM +0530, Souptick Joarder wrote:
> > > >
> > > > "fs: convert return type int to vm_fault_t" is still under
> > > > review/discusson and not yet merge
> > > > into linux-next. I am not seeing it into linux-next tree.Can you
> > > > please share the commit id ?
> > >
> > > It's at: 83c0adddcc6ed128168e7b87eaed0c21eac908e4 in the Linux Next
> > > branch.
> > >
> > > Dmitry, can you try reverting this commit and see if it makes the
> > > problem go away?
> > >
> > > Souptick, can we just NACK this patch and completely drop it from all
> > > trees?
> >
> > Ok, I will correct it and post v3.
> >
> > >
> > > I think we need to be a *lot* more careful about this vm_fault_t patch
> > > thing.  If you can't be bothered to run xfstests, we need to introduce
> > > a new function which replaces block_page_mkwrite() --- and then let
> > > each file system try to convert over to it at their own pace, after
> > > they've done regression testing.
> > >
> > >                                                 - Ted
> >
> > Chris has his opinion,
> >
> > block_page_mkwrite is only called by ext4 and nilfs2 anyway, so
> > converting both callers over should not be a problem, as long as
> > it actually is done properly.
> >
> > Matthew's opinion in other mail thread -
> >
> > > +vm_fault_t block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> > > +                      get_block_t get_block, int *err)
> >
> > I don't like returning both the errno and the vm_fault_t.  To me that's a
> > sign we need to rethink this interface.
> >
> > I have two suggestions.  First, we could allocate a new VM_FAULT_NOSPC
> > bit.  Second, we could repurpose one of the existing bits, such as
> > VM_FAULT_RETRY for this purpose.
> >
> > > -int ext4_page_mkwrite(struct vm_fault *vmf)
> > > +vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf)
> >
> > I also think perhaps we could start by _not_ converting block_page_mkwrite().
> > Just convert ext4_page_mkwrite(), and save converting block_page_mkwrite()
> > for later.
>

> Yes, I'd start with converting ext4_page_mkwrite() - that should be pretty
> straightforward - and we can leave block_page_mkwrite() as is for now. I
> don't think allocating other VM_FAULT_ codes is going to cut it as
> generally the filesystem may need to communicate different error codes back
> and you don't know in advance which are interesting.

Then I need to take care of ext4_page_mkwrite() and ext4_filemap_fault()
to migrate to use vm_fault_t return type. Everything else can be removed
from this patch and it will go as a separate patch.

As block_page_mkwrite() is getting called from 2 places in ext4 and nilfs and
both places fault handler code convert errno to VM_FAULT_CODE using
block_page_mkwrite_return(), is it required to migrate block_page_mkwrite()
to use vm_fault_t return type and further complicate the API or better to
leave this API in current state ??

>
> One solution for passing error codes we could use with vm_fault_t is a
> scheme similar to ERR_PTR. So we can store full error code in vm_fault_t
> and still have a plenty of space for the special VM_FAULT_ return codes...
> With that scheme converting block_page_mkwrite() would be trivial.
>
I didn't get this part. Any reference code will be helpful ?
