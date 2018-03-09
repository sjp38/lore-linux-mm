Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8874A6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 20:05:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t123so292458wmt.2
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 17:05:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n31si14070726wrf.204.2018.03.08.17.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 17:05:15 -0800 (PST)
Date: Thu, 8 Mar 2018 17:05:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] hugetlbfs: check for pgoff value overflow
Message-Id: <20180308170511.c16fc731523ff49f1981f89d@linux-foundation.org>
In-Reply-To: <20180309002726.7248-1-mike.kravetz@oracle.com>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
	<20180309002726.7248-1-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, stable@vger.kernel.org

On Thu,  8 Mar 2018 16:27:26 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> A vma with vm_pgoff large enough to overflow a loff_t type when
> converted to a byte offset can be passed via the remap_file_pages
> system call.  The hugetlbfs mmap routine uses the byte offset to
> calculate reservations and file size.
> 
> A sequence such as:
>   mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
>   remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);
> will result in the following when task exits/file closed,
>   kernel BUG at mm/hugetlb.c:749!
> Call Trace:
>   hugetlbfs_evict_inode+0x2f/0x40
>   evict+0xcb/0x190
>   __dentry_kill+0xcb/0x150
>   __fput+0x164/0x1e0
>   task_work_run+0x84/0xa0
>   exit_to_usermode_loop+0x7d/0x80
>   do_syscall_64+0x18b/0x190
>   entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> 
> The overflowed pgoff value causes hugetlbfs to try to set up a
> mapping with a negative range (end < start) that leaves invalid
> state which causes the BUG.
> 
> The previous overflow fix to this code was incomplete and did not
> take the remap_file_pages system call into account.
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4374,6 +4374,12 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	struct resv_map *resv_map;
>  	long gbl_reserve;
>  
> +	/* This should never happen */
> +	if (from > to) {
> +		VM_WARN(1, "%s called with a negative range\n", __func__);
> +		return -EINVAL;
> +	}

This is tidier, and that comment is a bit too obvious to live ;)

--- a/mm/hugetlb.c~hugetlbfs-check-for-pgoff-value-overflow-v3-fix
+++ a/mm/hugetlb.c
@@ -18,6 +18,7 @@
 #include <linux/bootmem.h>
 #include <linux/sysfs.h>
 #include <linux/slab.h>
+#include <linux/mmdebug.h>
 #include <linux/sched/signal.h>
 #include <linux/rmap.h>
 #include <linux/string_helpers.h>
@@ -4374,11 +4375,8 @@ int hugetlb_reserve_pages(struct inode *
 	struct resv_map *resv_map;
 	long gbl_reserve;
 
-	/* This should never happen */
-	if (from > to) {
-		VM_WARN(1, "%s called with a negative range\n", __func__);
+	if (VM_WARN(from > to, "%s called with a negative range\n", __func__))
 		return -EINVAL;
-	}
 
 	/*
 	 * Only apply hugepage reservation if asked. At fault time, an
