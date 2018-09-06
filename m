Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4417E6B78C5
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:12:19 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p127-v6so7002486ywg.1
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:12:19 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id k16-v6si1269065ybp.437.2018.09.06.06.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Sep 2018 06:12:18 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:12:12 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: linux-next test error
Message-ID: <20180906131212.GG2331@thunk.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
 <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
 <20180906083800.GC19319@quack2.suse.cz>
 <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, Matthew Wilcox <willy@infradead.org>

On Thu, Sep 06, 2018 at 05:56:31PM +0530, Souptick Joarder wrote:
> > Yes, I'd start with converting ext4_page_mkwrite() - that should be pretty
> > straightforward - and we can leave block_page_mkwrite() as is for now. I
> > don't think allocating other VM_FAULT_ codes is going to cut it as
> > generally the filesystem may need to communicate different error codes back
> > and you don't know in advance which are interesting.

Changing the return values of ext4_page_mkwrite() and
ext4_filemap_fault() is definitely safe.  If you want to start
changing the type of "ret" to vm_fault_t and introduce a new variable
"err", now you have to be super careful not to screw things up.  (I
believe one of the earlier patches didn't get that right.)

> As block_page_mkwrite() is getting called from 2 places in ext4 and nilfs and
> both places fault handler code convert errno to VM_FAULT_CODE using
> block_page_mkwrite_return(), is it required to migrate block_page_mkwrite()
> to use vm_fault_t return type and further complicate the API or better to
> leave this API in current state ??

So I don't see the point of changing return value block_page_mkwrite()
(although to be honest I haven't see the value of the vm_fault_t
change at all in the first place, at least not compared to the pain it
has caused) but no, I don't think it's worth it.

The API for block_page_mkwrite() can simply be defined as "0 on
success, < 0 on error".  You can add documentation that it's up to
caller of block_page_mkwrite() to call block_page_mkwrite_return() to
translate the error to a vm_fault_t.

> > One solution for passing error codes we could use with vm_fault_t is a
> > scheme similar to ERR_PTR. So we can store full error code in vm_fault_t
> > and still have a plenty of space for the special VM_FAULT_ return codes...
> > With that scheme converting block_page_mkwrite() would be trivial.
> >
> I didn't get this part. Any reference code will be helpful ?

So what we do for functions that need to either return an error or a
pointer is to call encode the error as a "pointer" by using ERR_PTR(),
and the caller can determine whether or not it is a valid pointer or
an error code by using IS_ERR_VALUE() and turning it back into an
error by using PTR_ERR().   See include/linux/err.h.

Similarly, all valid vm_fault_t's composed of VM_FAULT_xxx are
positive integers, and all errors are passed using the kernel's
convention of using a negative error code.  So going through lots of
machinations to return both an error code and a vm_fault_t *really*
wasn't necessary.

The issue, as near as I can understand things, for why we're going
through all of this churn, was there was a concern that in the mm
code, that all of the places which received a vm_fault_t would
sometimes see a negative error code.  The proposal here is to just
*accept* that this will happen, and just simply have them *check* to
see if it's a negative error code, and convert it to the appropriate
vm_fault_t in that case.  It puts the onus of the change on the mm
layer, where as the "blast radius" of the vm_fault_t "cleanup" is
spread out across a large number of subsystems.

Which I wouldn't mind, if it wasn't causing pain.  But it *is* causing
pain.

And it's common kernel convention to overload an error and a pointer
using the exact same trick.  We do it *all* over the place, and quite
frankly, it's less error prone than changing functions to return a
pointer and an error.  No one has said, "let's do to the ERR_PTR
convention what we've done to the vm_fault_t -- it's too confusing
that a pointer might be an error, since people might forget to check
for it."  If they did that, it would be NACK'ed right, left and
center.  But yet it's a good idea for vm_fault_t?

	     	      	     	      - Ted
