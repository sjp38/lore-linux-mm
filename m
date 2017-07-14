Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1EFA4408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:51:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q87so76635798pfk.15
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 21:51:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p17si5604641pge.55.2017.07.13.21.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 21:51:39 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6E4miC5042833
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:51:39 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bpmfsnd49-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:51:38 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 14 Jul 2017 14:51:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6E4pZTQ24313880
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 14:51:35 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6E4pYdx021473
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 14:51:34 +1000
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
 <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 14 Jul 2017 10:21:26 +0530
MIME-Version: 1.0
In-Reply-To: <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <b4470a3e-ce80-e3d4-c5ea-6cb8b5ced8ad@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On 07/14/2017 04:03 AM, Mike Kravetz wrote:
> On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
>> [+CC linux-api]
>>
>> On 07/13/2017 05:58 PM, Mike Kravetz wrote:
>>> mremap will create a 'duplicate' mapping if old_size == 0 is
>>> specified.  Such duplicate mappings make no sense for private
>>> mappings.  If duplication is attempted for a private mapping,
>>> mremap creates a separate private mapping unrelated to the
>>> original mapping and makes no modifications to the original.
>>> This is contrary to the purpose of mremap which should return
>>> a mapping which is in some way related to the original.
>>>
>>> Therefore, return EINVAL in the case where if an attempt is
>>> made to duplicate a private mapping.
>>>
>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>
> In another e-mail thread, Andrea makes the case that mremap(old_size == 0)
> of private file backed mappings could possibly be used for something useful.
> For example to create a private COW mapping.  Of course, a better way to do
> this would be simply using the fd to create a private mapping.
> 
> If returning EINVAL for all private mappings is too general, the following
> patch adds a check to only return EINVAL for private anon mappings.
> 
> mm/mremap: Fail map duplication attempts for private anon mappings
> 
> mremap will create a 'duplicate' mapping if old_size == 0 is
> specified.  Such duplicate mappings make no sense for private
> anonymous mappings.  If duplication is attempted for a private
> anon mapping, mremap creates a separate private mapping unrelated
> to the original mapping and makes no modifications to the original.
> This is contrary to the purpose of mremap which should return a
> mapping which is in some way related to the original.
> 
> Therefore, return EINVAL in the case where an attempt is made to
> duplicate a private anon mapping.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/mremap.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b1..586ea3d 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -383,6 +383,14 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>  	if (!vma || vma->vm_start > addr)
>  		return ERR_PTR(-EFAULT);
>  
> +	/*
> +	 * !old_len  is a special case where a mapping is 'duplicated'.
> +	 * Do not allow this for private anon mappings.
> +	 */
> +	if (!old_len && vma_is_anonymous(vma) &&
> +	    !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
> +		return ERR_PTR(-EINVAL);

Sounds better compared to rejecting everything private.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
