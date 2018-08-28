Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDDD6B4734
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:49:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c6-v6so2050389qta.6
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:49:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 30-v6sor829907qtz.146.2018.08.28.10.49.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 10:49:27 -0700 (PDT)
Date: Tue, 28 Aug 2018 13:49:25 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 01/10] cramfs: Convert to use vmf_insert_mixed
In-Reply-To: <20180828145728.11873-2-willy@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1808281235060.10215@knanqh.ubzr>
References: <20180828145728.11873-1-willy@infradead.org> <20180828145728.11873-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 28 Aug 2018, Matthew Wilcox wrote:

> cramfs is the only remaining user of vm_insert_mixed; convert it.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  fs/cramfs/inode.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
> index f408994fc632..b72449c19cd1 100644
> --- a/fs/cramfs/inode.c
> +++ b/fs/cramfs/inode.c
> @@ -417,10 +417,15 @@ static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
>  		 */
>  		int i;
>  		vma->vm_flags |= VM_MIXEDMAP;
> -		for (i = 0; i < pages && !ret; i++) {
> +		for (i = 0; i < pages; i++) {
> +			vm_fault_t vmf;
>  			unsigned long off = i * PAGE_SIZE;
>  			pfn_t pfn = phys_to_pfn_t(address + off, PFN_DEV);
> -			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
> +			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
> +			if (vmf & VM_FAULT_ERROR) {
> +				pages = i;
> +				break;
> +			}

I'd suggest this to properly deal with errers instead:

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index f408994fc6..0c35e62f10 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -418,9 +418,12 @@ static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
 		int i;
 		vma->vm_flags |= VM_MIXEDMAP;
 		for (i = 0; i < pages && !ret; i++) {
+			vm_fault_t vmf;
 			unsigned long off = i * PAGE_SIZE;
 			pfn_t pfn = phys_to_pfn_t(address + off, PFN_DEV);
-			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
+			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
+			if (vmf & VM_FAULT_ERROR)
+				ret = vm_fault_to_errno(vmf, 0);
 		}
 	}
 

Nicolas
