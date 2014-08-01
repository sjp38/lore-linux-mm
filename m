Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCE96B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 01:05:33 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so4850104pdi.11
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 22:05:33 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id g7si8307654pat.225.2014.07.31.22.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 22:05:32 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so4850329pdb.31
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 22:05:32 -0700 (PDT)
Date: Thu, 31 Jul 2014 22:03:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/5] mm, shmem: Add shmem_vma() helper
In-Reply-To: <1406036632-26552-4-git-send-email-jmarchan@redhat.com>
Message-ID: <alpine.LSU.2.11.1407312202040.3912@eggly.anvils>
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-4-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

On Tue, 22 Jul 2014, Jerome Marchand wrote:

> Add a simple helper to check if a vm area belongs to shmem.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> ---
>  include/linux/mm.h | 6 ++++++
>  mm/shmem.c         | 8 ++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 34099fa..04a58d1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1074,11 +1074,17 @@ int shmem_zero_setup(struct vm_area_struct *);
>  
>  extern int shmem_locate(struct vm_area_struct *vma, pgoff_t pgoff, int *count);
>  bool shmem_mapping(struct address_space *mapping);
> +bool shmem_vma(struct vm_area_struct *vma);
> +
>  #else
>  static inline bool shmem_mapping(struct address_space *mapping)
>  {
>  	return false;
>  }
> +static inline bool shmem_vma(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
>  #endif

I would prefer include/linux/shmem_fs.h for this (and one of us clean
up where the declarations of shmem_zero_setup and shmem_mapping live).

But if 4/5 goes away, then there will only be one user of shmem_vma(),
so in that case better just declare it (using shmem_mapping()) there
in task_mmu.c in the smaps patch.

>  
>  extern int can_do_mlock(void);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8aa4892..7d16227 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1483,6 +1483,14 @@ bool shmem_mapping(struct address_space *mapping)
>  	return mapping->backing_dev_info == &shmem_backing_dev_info;
>  }
>  
> +bool shmem_vma(struct vm_area_struct *vma)
> +{
> +	return (vma->vm_file &&
> +		vma->vm_file->f_dentry->d_inode->i_mapping->backing_dev_info
> +		== &shmem_backing_dev_info);
> +

I agree with Oleg,
	vma->vm_file && shmem_mapping(file_inode(vma->vm_file)->i_mapping);
would be better,

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
