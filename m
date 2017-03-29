Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 156CF6B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 17:17:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u3so19910903pgn.12
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 14:17:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n64si115039pgn.27.2017.03.29.14.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 14:17:12 -0700 (PDT)
Date: Wed, 29 Mar 2017 14:17:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] mm/hugetlb: Don't call region_abort if
 region_chg fails
Message-Id: <20170329141711.50c183a7bb1bfa75e24d4426@linux-foundation.org>
In-Reply-To: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com>
References: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, 29 Mar 2017 14:08:02 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Resending because of typo in Andrew's e-mail when first sent
> 
> Changes to hugetlbfs reservation maps is a two step process.  The first
> step is a call to region_chg to determine what needs to be changed, and
> prepare that change.  This should be followed by a call to call to
> region_add to commit the change, or region_abort to abort the change.
> 
> The error path in hugetlb_reserve_pages called region_abort after a
> failed call to region_chg.  As a result, the adds_in_progress counter
> in the reservation map is off by 1.  This is caught by a VM_BUG_ON
> in resv_map_release when the reservation map is freed.
> 
> syzkaller fuzzer found this bug, that resulted in the following:

I'll change the above to

: syzkaller fuzzer (when using an injected kmalloc failure) found this bug,
: that resulted in the following:

it's important, because this bug won't be triggered (at all easily, at
least) in real-world workloads.

>  kernel BUG at mm/hugetlb.c:742!
>  Call Trace:
>   hugetlbfs_evict_inode+0x7b/0xa0 fs/hugetlbfs/inode.c:493
>   evict+0x481/0x920 fs/inode.c:553
>   iput_final fs/inode.c:1515 [inline]
>   iput+0x62b/0xa20 fs/inode.c:1542
>   hugetlb_file_setup+0x593/0x9f0 fs/hugetlbfs/inode.c:1306
>   newseg+0x422/0xd30 ipc/shm.c:575
>   ipcget_new ipc/util.c:285 [inline]
>   ipcget+0x21e/0x580 ipc/util.c:639
>   SYSC_shmget ipc/shm.c:673 [inline]
>   SyS_shmget+0x158/0x230 ipc/shm.c:657
>   entry_SYSCALL_64_fastpath+0x1f/0xc2
>  RIP: resv_map_release+0x265/0x330 mm/hugetlb.c:742

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
