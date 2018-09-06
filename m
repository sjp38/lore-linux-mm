Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34B576B77CB
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 04:38:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k16-v6so3402606ede.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:38:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23-v6si210322edw.115.2018.09.06.01.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 01:38:01 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:38:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: linux-next test error
Message-ID: <20180906083800.GC19319@quack2.suse.cz>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
 <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, Matthew Wilcox <willy@infradead.org>

On Thu 06-09-18 00:54:50, Souptick Joarder wrote:
> On Wed, Sep 5, 2018 at 7:05 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
> >
> > On Wed, Sep 05, 2018 at 03:20:16PM +0530, Souptick Joarder wrote:
> > >
> > > "fs: convert return type int to vm_fault_t" is still under
> > > review/discusson and not yet merge
> > > into linux-next. I am not seeing it into linux-next tree.Can you
> > > please share the commit id ?
> >
> > It's at: 83c0adddcc6ed128168e7b87eaed0c21eac908e4 in the Linux Next
> > branch.
> >
> > Dmitry, can you try reverting this commit and see if it makes the
> > problem go away?
> >
> > Souptick, can we just NACK this patch and completely drop it from all
> > trees?
> 
> Ok, I will correct it and post v3.
> 
> >
> > I think we need to be a *lot* more careful about this vm_fault_t patch
> > thing.  If you can't be bothered to run xfstests, we need to introduce
> > a new function which replaces block_page_mkwrite() --- and then let
> > each file system try to convert over to it at their own pace, after
> > they've done regression testing.
> >
> >                                                 - Ted
> 
> Chris has his opinion,
> 
> block_page_mkwrite is only called by ext4 and nilfs2 anyway, so
> converting both callers over should not be a problem, as long as
> it actually is done properly.
> 
> Matthew's opinion in other mail thread -
> 
> > +vm_fault_t block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +                      get_block_t get_block, int *err)
> 
> I don't like returning both the errno and the vm_fault_t.  To me that's a
> sign we need to rethink this interface.
> 
> I have two suggestions.  First, we could allocate a new VM_FAULT_NOSPC
> bit.  Second, we could repurpose one of the existing bits, such as
> VM_FAULT_RETRY for this purpose.
> 
> > -int ext4_page_mkwrite(struct vm_fault *vmf)
> > +vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf)
> 
> I also think perhaps we could start by _not_ converting block_page_mkwrite().
> Just convert ext4_page_mkwrite(), and save converting block_page_mkwrite()
> for later.

Yes, I'd start with converting ext4_page_mkwrite() - that should be pretty
straightforward - and we can leave block_page_mkwrite() as is for now. I
don't think allocating other VM_FAULT_ codes is going to cut it as
generally the filesystem may need to communicate different error codes back
and you don't know in advance which are interesting.

One solution for passing error codes we could use with vm_fault_t is a
scheme similar to ERR_PTR. So we can store full error code in vm_fault_t
and still have a plenty of space for the special VM_FAULT_ return codes...
With that scheme converting block_page_mkwrite() would be trivial.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
