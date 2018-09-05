Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8584B6B74B8
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 15:21:57 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id p8-v6so1756165ljg.10
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:21:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n74-v6sor1119551lfi.35.2018.09.05.12.21.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 12:21:56 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004f6b5805751a8189@google.com> <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com> <20180905133459.GF23909@thunk.org>
In-Reply-To: <20180905133459.GF23909@thunk.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 6 Sep 2018 00:54:50 +0530
Message-ID: <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
Subject: Re: linux-next test error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, Matthew Wilcox <willy@infradead.org>

On Wed, Sep 5, 2018 at 7:05 PM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> On Wed, Sep 05, 2018 at 03:20:16PM +0530, Souptick Joarder wrote:
> >
> > "fs: convert return type int to vm_fault_t" is still under
> > review/discusson and not yet merge
> > into linux-next. I am not seeing it into linux-next tree.Can you
> > please share the commit id ?
>
> It's at: 83c0adddcc6ed128168e7b87eaed0c21eac908e4 in the Linux Next
> branch.
>
> Dmitry, can you try reverting this commit and see if it makes the
> problem go away?
>
> Souptick, can we just NACK this patch and completely drop it from all
> trees?

Ok, I will correct it and post v3.

>
> I think we need to be a *lot* more careful about this vm_fault_t patch
> thing.  If you can't be bothered to run xfstests, we need to introduce
> a new function which replaces block_page_mkwrite() --- and then let
> each file system try to convert over to it at their own pace, after
> they've done regression testing.
>
>                                                 - Ted

Chris has his opinion,

block_page_mkwrite is only called by ext4 and nilfs2 anyway, so
converting both callers over should not be a problem, as long as
it actually is done properly.

Matthew's opinion in other mail thread -

> +vm_fault_t block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> +                      get_block_t get_block, int *err)

I don't like returning both the errno and the vm_fault_t.  To me that's a
sign we need to rethink this interface.

I have two suggestions.  First, we could allocate a new VM_FAULT_NOSPC
bit.  Second, we could repurpose one of the existing bits, such as
VM_FAULT_RETRY for this purpose.

> -int ext4_page_mkwrite(struct vm_fault *vmf)
> +vm_fault_t ext4_page_mkwrite(struct vm_fault *vmf)

I also think perhaps we could start by _not_ converting block_page_mkwrite().
Just convert ext4_page_mkwrite(), and save converting block_page_mkwrite()
for later.

Which approach Shall I take ??
