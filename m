Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20F6F6B000A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:41:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j47so2136295wre.11
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:41:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m54si2956645wrm.302.2018.03.21.01.41.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 01:41:15 -0700 (PDT)
Date: Wed, 21 Mar 2018 09:41:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetlb: prevent hugetlb VMA to be misaligned
Message-ID: <20180321084113.GD23100@dhcp22.suse.cz>
References: <1521566754-30390-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <86240c1a-d1f1-0f03-855e-c5196762ec0a@oracle.com>
 <0d24f817-303a-7b4d-4603-b2d14e4b391a@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d24f817-303a-7b4d-4603-b2d14e4b391a@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>

On Tue 20-03-18 14:35:28, Mike Kravetz wrote:
> On 03/20/2018 02:26 PM, Mike Kravetz wrote:
> > Thanks Laurent!
> > 
> > This bug was introduced by 31383c6865a5.  Dan's changes for 31383c6865a5
> > seem pretty straight forward.  It simply replaces an explicit check when
> > splitting a vma to a new vm_ops split callout.  Unfortunately, mappings
> > created via shmget/shmat have their vm_ops replaced.  Therefore, this
> > split callout is never made.
> > 
> > The shm vm_ops do indirectly call the original vm_ops routines as needed.
> > Therefore, I would suggest a patch something like the following instead.
> > If we move forward with the patch, we should include Laurent's BUG output
> > and perhaps test program in the commit message.
> 
> Sorry, patch in previous mail was a mess
> 
> >From 7a19414319c7937fd2757c27f936258f16c1f61d Mon Sep 17 00:00:00 2001
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Tue, 20 Mar 2018 13:56:57 -0700
> Subject: [PATCH] shm: add split function to shm_vm_ops
> 
> The split function was added to vm_operations_struct to determine
> if a mapping can be split.  This was mostly for device-dax and
> hugetlbfs mappings which have specific alignment constraints.
> 
> mappings initiated via shmget/shmat have their original vm_ops
> overwritten with shm_vm_ops.  shm_vm_ops functions will call back
> to the original vm_ops if needed.  Add such a split function.
> 
> Fixes: 31383c6865a5 ("mm, hugetlbfs: introduce ->split() to vm_operations_struct)
> Reported by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Yes this looks much better than the original hugetlb specific code in
the generic vma code.

Please add the original VM_BUG_ON report to the changelog

Cc: stable
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  ipc/shm.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 7acda23430aa..50e88fc060b1 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -386,6 +386,17 @@ static int shm_fault(struct vm_fault *vmf)
>  	return sfd->vm_ops->fault(vmf);
>  }
>  
> +static int shm_split(struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct file *file = vma->vm_file;
> +	struct shm_file_data *sfd = shm_file_data(file);
> +
> +	if (sfd->vm_ops && sfd->vm_ops->split)
> +		return sfd->vm_ops->split(vma, addr);
> +
> +	return 0;
> +}
> +
>  #ifdef CONFIG_NUMA
>  static int shm_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
>  {
> @@ -510,6 +521,7 @@ static const struct vm_operations_struct shm_vm_ops = {
>  	.open	= shm_open,	/* callback for a new vm-area open */
>  	.close	= shm_close,	/* callback for when the vm-area is released */
>  	.fault	= shm_fault,
> +	.split	= shm_split,
>  #if defined(CONFIG_NUMA)
>  	.set_policy = shm_set_policy,
>  	.get_policy = shm_get_policy,
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs
