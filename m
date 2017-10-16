Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8426B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 19:14:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 22so3844725wrb.9
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 16:14:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m192si6092123wmb.206.2017.10.16.16.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 16:14:46 -0700 (PDT)
Date: Mon, 16 Oct 2017 16:14:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] userfaultfd: hugetlbfs: prevent UFFDIO_COPY to fill
 beyond the end of i_size
Message-Id: <20171016161443.5365a280c44dc80e8c11298c@linux-foundation.org>
In-Reply-To: <20171016223914.2421-2-aarcange@redhat.com>
References: <20171016223914.2421-1-aarcange@redhat.com>
	<20171016223914.2421-2-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, 17 Oct 2017 00:39:14 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> kernel BUG at fs/hugetlbfs/inode.c:484!
> RIP: 0010:[<ffffffff815f8520>]  [<ffffffff815f8520>] remove_inode_hugepages+0x3d0/0x410
> Call Trace:
>  [<ffffffff815f95b9>] hugetlbfs_setattr+0xd9/0x130
>  [<ffffffff81526312>] notify_change+0x292/0x410
>  [<ffffffff816cc6b6>] ? security_inode_need_killpriv+0x16/0x20
>  [<ffffffff81503c65>] do_truncate+0x65/0xa0
>  [<ffffffff81504035>] ? do_sys_ftruncate.constprop.3+0xe5/0x180
>  [<ffffffff8150406a>] do_sys_ftruncate.constprop.3+0x11a/0x180
>  [<ffffffff8150410e>] SyS_ftruncate+0xe/0x10
>  [<ffffffff81999f27>] tracesys+0xd9/0xde
> 
> This oops was caused by the lack of i_size check in
> hugetlb_mcopy_atomic_pte. mmap() can still succeed beyond the end of
> the i_size after vmtruncate zapped vmas in those ranges, but the
> faults must not succeed, and that includes UFFDIO_COPY.
> 
> We could differentiate the retval to userland to represent a SIGBUS
> like a page fault would do (vs SIGSEGV), but it doesn't seem very
> useful and we'd need to pick a random retval as there's no meaningful
> syscall retval that would differentiate from SIGSEGV and SIGBUS,
> there's just -EFAULT.
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

No cc:stable?  The patch applies to 4.13 textually...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
