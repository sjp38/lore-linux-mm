Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0CF16B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:37:42 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p63so6925475wmp.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:37:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ln5si4297147wjb.38.2016.01.26.13.37.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 13:37:41 -0800 (PST)
Subject: Re: mm: VM_BUG_ON_PAGE(PageTail(page)) in mbind
References: <CACT4Y+YK7or=W4RGpv1k1T5-xDHu3_PPVZWqsQU6nWoArsV5vA@mail.gmail.com>
 <20160126202829.GA21250@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A7E71F.4060905@suse.cz>
Date: Tue, 26 Jan 2016 22:37:35 +0100
MIME-Version: 1.0
In-Reply-To: <20160126202829.GA21250@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, Doug Gilbert <dgilbert@interlog.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, linux-scsi@vger.kernel.org

On 26.1.2016 21:28, Kirill A. Shutemov wrote:
> From 396ad132be07a2d2b9ec5d1d6ec9fe2fffe8105e Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 26 Jan 2016 22:59:16 +0300
> Subject: [PATCH] sg: mark VMA as VM_IO to prevent migration
> 
> Reduced testcase:
> 
> 	#include <fcntl.h>
> 	#include <unistd.h>
> 	#include <sys/mman.h>
> 	#include <numaif.h>
> 
> 	#define SIZE 0x2000
> 
> 	int main()
> 	{
> 		int fd;
> 		void *p;
> 
> 		fd = open("/dev/sg0", O_RDWR);
> 		p = mmap(NULL, SIZE, PROT_EXEC, MAP_PRIVATE | MAP_LOCKED, fd, 0);
> 		mbind(p, SIZE, 0, NULL, 0, MPOL_MF_MOVE);
> 		return 0;
> 	}
> 
> We shouldn't try to migrate pages in sg VMA as we don't have a way to
> update Sg_scatter_hold::pages accordingly from mm core.
> 
> Let's mark the VMA as VM_IO to indicate to mm core that the VMA is
> migratable.

 ^ not migratable.

Acked-by: Vlastimil Babka <vbabka@suse.cz>


> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  drivers/scsi/sg.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
> index 503ab8b46c0b..5e820674432c 100644
> --- a/drivers/scsi/sg.c
> +++ b/drivers/scsi/sg.c
> @@ -1261,7 +1261,7 @@ sg_mmap(struct file *filp, struct vm_area_struct *vma)
>  	}
>  
>  	sfp->mmap_called = 1;
> -	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
> +	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
>  	vma->vm_private_data = sfp;
>  	vma->vm_ops = &sg_mmap_vm_ops;
>  	return 0;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
