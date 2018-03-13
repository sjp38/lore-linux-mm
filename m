Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD9BC6B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 16:37:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a22so590270qkc.1
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:37:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l17si501506qkk.482.2018.03.13.13.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 13:37:05 -0700 (PDT)
Date: Tue, 13 Mar 2018 16:36:57 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/8] Uprobe: Export vaddr <-> offset conversion functions
Message-ID: <20180313203657.GG3828@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-2-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180313125603.19819-2-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, Mar 13, 2018 at 06:25:56PM +0530, Ravi Bangoria wrote:
> No functionality changes.
> 
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> ---
>  include/linux/mm.h      | 12 ++++++++++++
>  kernel/events/uprobes.c | 10 ----------
>  2 files changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42..95909f2 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2274,6 +2274,18 @@ struct vm_unmapped_area_info {
>  		return unmapped_area(info);
>  }
>  
> +static inline unsigned long
> +offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
> +{
> +	return vma->vm_start + offset - ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +}
> +
> +static inline loff_t
> +vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
> +{
> +	return ((loff_t)vma->vm_pgoff << PAGE_SHIFT) + (vaddr - vma->vm_start);
> +}
> +
>  /* truncate.c */
>  extern void truncate_inode_pages(struct address_space *, loff_t);
>  extern void truncate_inode_pages_range(struct address_space *,
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index ce6848e..bd6f230 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -130,16 +130,6 @@ static bool valid_vma(struct vm_area_struct *vma, bool is_register)
>  	return vma->vm_file && (vma->vm_flags & flags) == VM_MAYEXEC;
>  }
>  
> -static unsigned long offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
> -{
> -	return vma->vm_start + offset - ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> -}
> -
> -static loff_t vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
> -{
> -	return ((loff_t)vma->vm_pgoff << PAGE_SHIFT) + (vaddr - vma->vm_start);
> -}
> -
>  /**
>   * __replace_page - replace page in vma by new page.
>   * based on replace_page in mm/ksm.c
> -- 
> 1.8.3.1
> 
