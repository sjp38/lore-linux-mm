Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A98D56B0038
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 23:13:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 72so5570300pge.10
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 20:13:26 -0700 (PDT)
Received: from out0-237.mail.aliyun.com (out0-237.mail.aliyun.com. [140.205.0.237])
        by mx.google.com with ESMTP id r1si18808119plb.293.2017.04.11.20.13.25
        for <linux-mm@kvack.org>;
        Tue, 11 Apr 2017 20:13:25 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
Date: Wed, 12 Apr 2017 11:13:20 +0800
Message-ID: <0c0501d2b33a$bd0bfc00$3723f400$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Vegard Nossum' <vegard.nossum@gmail.com>, 'Dmitry Vyukov' <dvyukov@google.com>, 'Michal Hocko' <mhocko@suse.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Andrey Ryabinin' <aryabinin@virtuozzo.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Andrew Morton' <akpm@linux-foundation.org>

On April 12, 2017 6:52 AM Mike Kravetz wrote: 
> 
> If mmap() maps a file, it can be passed an offset into the file at
> which the mapping is to start.  Offset could be a negative value when
> represented as a loff_t.  The offset plus length will be used to
> update the file size (i_size) which is also a loff_t.  Validate the
> value of offset and offset + length to make sure they do not overflow
> and appear as negative.
> 
> Found by syzcaller with commit ff8c0c53c475 ("mm/hugetlb.c: don't call
> region_abort if region_chg fails") applied.  Prior to this commit, the
> overflow would still occur but we would luckily return ENOMEM.
> To reproduce:
> mmap(0, 0x2000, 0, 0x40021, 0xffffffffffffffffULL, 0x8000000000000000ULL);
> 
> Resulted in,
> kernel BUG at mm/hugetlb.c:742!
> Call Trace:
>  hugetlbfs_evict_inode+0x80/0xa0
>  ? hugetlbfs_setattr+0x3c0/0x3c0
>  evict+0x24a/0x620
>  iput+0x48f/0x8c0
>  dentry_unlink_inode+0x31f/0x4d0
>  __dentry_kill+0x292/0x5e0
>  dput+0x730/0x830
>  __fput+0x438/0x720
>  ____fput+0x1a/0x20
>  task_work_run+0xfe/0x180
>  exit_to_usermode_loop+0x133/0x150
>  syscall_return_slowpath+0x184/0x1c0
>  entry_SYSCALL_64_fastpath+0xab/0xad
> 
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
