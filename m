Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC94F6B0485
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:12:27 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so11825534itb.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:12:27 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r184si7079923iod.227.2016.11.18.14.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 14:12:27 -0800 (PST)
Subject: Re: [PATCH v3 (re-send)] xen/gntdev: Use mempolicy instead of VM_IO
 flag to avoid NUMA balancing
References: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com>
 <alpine.LSU.2.11.1611181335560.9605@eggly.anvils>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <2bf041f3-8918-3c6f-8afb-c9edcc03dcd9@oracle.com>
Date: Fri, 18 Nov 2016 17:14:55 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611181335560.9605@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, david.vrabel@citrix.com, jgross@suse.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, olaf@aepfle.de

On 11/18/2016 04:51 PM, Hugh Dickins wrote:
> On Thu, 17 Nov 2016, Boris Ostrovsky wrote:
>
>> Commit 9c17d96500f7 ("xen/gntdev: Grant maps should not be subject to
>> NUMA balancing") set VM_IO flag to prevent grant maps from being
>> subjected to NUMA balancing.
>>
>> It was discovered recently that this flag causes get_user_pages() to
>> always fail with -EFAULT.
>>
>> check_vma_flags
>> __get_user_pages
>> __get_user_pages_locked
>> __get_user_pages_unlocked
>> get_user_pages_fast
>> iov_iter_get_pages
>> dio_refill_pages
>> do_direct_IO
>> do_blockdev_direct_IO
>> do_blockdev_direct_IO
>> ext4_direct_IO_read
>> generic_file_read_iter
>> aio_run_iocb
>>
>> (which can happen if guest's vdisk has direct-io-safe option).
>>
>> To avoid this don't use vm_flags. Instead, use mempolicy that prohibit=
s
>> page migration (i.e. clear MPOL_F_MOF|MPOL_F_MORON) and make sure we
>> don't consult task's policy (which may include those flags) if vma
>> doesn't have one.
>>
>> Reported-by: Olaf Hering <olaf@aepfle.de>
>> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> Cc: stable@vger.kernel.org
> Hmm, sorry, but this seems overcomplicated to me: ingenious, but an
> unusual use of the ->get_policy method, which is a little worrying,
> since it has only been used for shmem (+ shm and kernfs) until now.
>
> Maybe I'm wrong, but wouldn't substituting VM_MIXEDMAP for VM_IO
> solve the problem more simply?

It would indeed. I didn't want to use it because it has specific meaning
("Can contain "struct page" and pure PFN pages") and that didn't seem
like the right flag to describe this vma.


-boris


>
> Hugh
>
>> ---
>>
>> Mis-spelled David's address.
>>
>> Changes in v3:
>> * Don't use __mpol_dup() and get_task_policy() which are not exported
>>   for use by drivers. Add vm_operations_struct.get_policy().
>> * Copy to stable
>>
>>
>>  drivers/xen/gntdev.c |   27 ++++++++++++++++++++++++++-
>>  1 files changed, 26 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>> index bb95212..632edd4 100644
>> --- a/drivers/xen/gntdev.c
>> +++ b/drivers/xen/gntdev.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/spinlock.h>
>>  #include <linux/slab.h>
>>  #include <linux/highmem.h>
>> +#include <linux/mempolicy.h>
>> =20
>>  #include <xen/xen.h>
>>  #include <xen/grant_table.h>
>> @@ -433,10 +434,28 @@ static void gntdev_vma_close(struct vm_area_stru=
ct *vma)
>>  	return map->pages[(addr - map->pages_vm_start) >> PAGE_SHIFT];
>>  }
>> =20
>> +#ifdef CONFIG_NUMA
>> +/*
>> + * We have this op to make sure callers (such as vma_policy_mof()) do=
n't
>> + * check current task's policy which may include migrate flags (MPOL_=
F_MOF
>> + * or MPOL_F_MORON)
>> + */
>> +static struct mempolicy *gntdev_vma_get_policy(struct vm_area_struct =
*vma,
>> +					       unsigned long addr)
>> +{
>> +	if (mpol_needs_cond_ref(vma->vm_policy))
>> +		mpol_get(vma->vm_policy);
>> +	return vma->vm_policy;
>> +}
>> +#endif
>> +
>>  static const struct vm_operations_struct gntdev_vmops =3D {
>>  	.open =3D gntdev_vma_open,
>>  	.close =3D gntdev_vma_close,
>>  	.find_special_page =3D gntdev_vma_find_special_page,
>> +#ifdef CONFIG_NUMA
>> +	.get_policy =3D gntdev_vma_get_policy,
>> +#endif
>>  };
>> =20
>>  /* ------------------------------------------------------------------=
 */
>> @@ -1007,7 +1026,13 @@ static int gntdev_mmap(struct file *flip, struc=
t vm_area_struct *vma)
>> =20
>>  	vma->vm_ops =3D &gntdev_vmops;
>> =20
>> -	vma->vm_flags |=3D VM_DONTEXPAND | VM_DONTDUMP | VM_IO;
>> +	vma->vm_flags |=3D VM_DONTEXPAND | VM_DONTDUMP;
>> +
>> +#ifdef CONFIG_NUMA
>> +	/* Prevent NUMA balancing */
>> +	if (vma->vm_policy)
>> +		vma->vm_policy->flags &=3D ~(MPOL_F_MOF | MPOL_F_MORON);
>> +#endif
>> =20
>>  	if (use_ptemod)
>>  		vma->vm_flags |=3D VM_DONTCOPY;
>> --=20
>> 1.7.1
>>
>>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
