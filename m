Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEB546B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 15:10:45 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k123so7014041qke.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 12:10:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v21si166007qth.49.2017.10.18.12.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 12:10:44 -0700 (PDT)
Date: Wed, 18 Oct 2017 21:10:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: hugetlbfs: prevent UFFDIO_COPY to fill
 beyond the end of i_size
Message-ID: <20171018191039.GL17239@redhat.com>
References: <20171016223914.2421-1-aarcange@redhat.com>
 <20171016223914.2421-2-aarcange@redhat.com>
 <20171016161443.5365a280c44dc80e8c11298c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171016161443.5365a280c44dc80e8c11298c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, Oct 16, 2017 at 04:14:43PM -0700, Andrew Morton wrote:
> On Tue, 17 Oct 2017 00:39:14 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > kernel BUG at fs/hugetlbfs/inode.c:484!
> > RIP: 0010:[<ffffffff815f8520>]  [<ffffffff815f8520>] remove_inode_hugepages+0x3d0/0x410
> > Call Trace:
> >  [<ffffffff815f95b9>] hugetlbfs_setattr+0xd9/0x130
> >  [<ffffffff81526312>] notify_change+0x292/0x410
> >  [<ffffffff816cc6b6>] ? security_inode_need_killpriv+0x16/0x20
> >  [<ffffffff81503c65>] do_truncate+0x65/0xa0
> >  [<ffffffff81504035>] ? do_sys_ftruncate.constprop.3+0xe5/0x180
> >  [<ffffffff8150406a>] do_sys_ftruncate.constprop.3+0x11a/0x180
> >  [<ffffffff8150410e>] SyS_ftruncate+0xe/0x10
> >  [<ffffffff81999f27>] tracesys+0xd9/0xde
> > 
> > This oops was caused by the lack of i_size check in
> > hugetlb_mcopy_atomic_pte. mmap() can still succeed beyond the end of
> > the i_size after vmtruncate zapped vmas in those ranges, but the
> > faults must not succeed, and that includes UFFDIO_COPY.
> > 
> > We could differentiate the retval to userland to represent a SIGBUS
> > like a page fault would do (vs SIGSEGV), but it doesn't seem very
> > useful and we'd need to pick a random retval as there's no meaningful
> > syscall retval that would differentiate from SIGSEGV and SIGBUS,
> > there's just -EFAULT.
> > 
> > Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> No cc:stable?  The patch applies to 4.13 textually...

Yes, I should have CC'ed stable.

Last time I CC'ed stable I didn't submit it in the right way, I should
have added cc:stable to the commit body, this time. I can resend with
cc:stable if you prefer.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
