Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B42D46B000D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:54:06 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id z186so4434360vkd.15
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:54:06 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id s28si1848832uac.350.2018.03.21.15.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 15:54:05 -0700 (PDT)
Subject: Re: [PATCH v2] shm: add split function to shm_vm_ops
References: <0d24f817-303a-7b4d-4603-b2d14e4b391a@oracle.com>
 <20180321161314.7711-1-mike.kravetz@oracle.com>
 <20180321135618.f3d4a0c30d9f413ce4092ddf@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <051fa302-f4c2-cc90-7a12-eaedfa806e73@oracle.com>
Date: Wed, 21 Mar 2018 15:53:56 -0700
MIME-Version: 1.0
In-Reply-To: <20180321135618.f3d4a0c30d9f413ce4092ddf@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, stable@vger.kernel.org

On 03/21/2018 01:56 PM, Andrew Morton wrote:
> On Wed, 21 Mar 2018 09:13:14 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>  
>> +static int shm_split(struct vm_area_struct *vma, unsigned long addr)
>> +{
>> +	struct file *file = vma->vm_file;
>> +	struct shm_file_data *sfd = shm_file_data(file);
>> +
>> +	if (sfd->vm_ops && sfd->vm_ops->split)
>> +		return sfd->vm_ops->split(vma, addr);
> 
> This will be the only site which tests for NULL shm_file_data.vm_ops. 
> It's a can't-happen, methinks.

You are correct, thanks for catching this.

> 
> I think I'll leave it as it is for now and will queue up a non-urgent
> patch:
> 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: ipc/shm.c: shm_split(): remove unneeded test for NULL shm_file_data.vm_ops
> 
> This was added by the recent "ipc/shm.c: add split function to
> shm_vm_ops", but it is not necessary.
> 
> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Looks good, FWIW
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
> 
>  ipc/shm.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN ipc/shm.c~ipc-shmc-shm_split-remove-unneeded-test-for-null-shm_file_datavm_ops ipc/shm.c
> --- a/ipc/shm.c~ipc-shmc-shm_split-remove-unneeded-test-for-null-shm_file_datavm_ops
> +++ a/ipc/shm.c
> @@ -391,7 +391,7 @@ static int shm_split(struct vm_area_stru
>  	struct file *file = vma->vm_file;
>  	struct shm_file_data *sfd = shm_file_data(file);
>  
> -	if (sfd->vm_ops && sfd->vm_ops->split)
> +	if (sfd->vm_ops->split)
>  		return sfd->vm_ops->split(vma, addr);
>  
>  	return 0;
> _
> 
