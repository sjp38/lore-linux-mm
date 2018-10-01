Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0656B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 18:11:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so5669433pgv.15
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 15:11:43 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p5-v6si4425191pgi.411.2018.10.01.15.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 15:11:41 -0700 (PDT)
Subject: Re: [PATCH] mm: madvise(MADV_DODUMP) allow hugetlbfs pages
References: <20180930054629.29150-1-daniel@linux.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ecbe3fad-4ab7-6549-bafb-5f24ccc36e74@oracle.com>
Date: Mon, 1 Oct 2018 15:11:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180930054629.29150-1-daniel@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Black <daniel@linux.ibm.com>, linux-mm@kvack.org, khlebnikov@openvz.org

On 9/29/18 10:46 PM, Daniel Black wrote:
<snip>
> hugetlbfs pages have VM_DONTEXPAND in the VmFlags driver pages based on
> author testing with analysis from Florian Weimer[1].
> 
> The inclusion of VM_DONTEXPAND into the VM_SPECIAL defination
> was a consequence of the large useage of VM_DONTEXPAND in device
> drivers.
> 
> A consequence of [2] is that VM_DONTEXPAND marked pages are unable to be
> marked DODUMP.
> 
> A user could quite legitimately madvise(MADV_DONTDUMP) their hugetlbfs
> memory for a while and later request that madvise(MADV_DODUMP) on the
> same memory. We correct this omission by allowing madvice(MADV_DODUMP)
> on hugetlbfs pages.
> 
> [1] https://stackoverflow.com/questions/52548260/madvisedodump-on-the-same-ptr-size-as-a-successful-madvisedontdump-fails-wit
> [2] commit 0103bd16fb90 ("mm: prepare VM_DONTDUMP for using in drivers")
> 
> Fixes: 0103bd16fb90 ("mm: prepare VM_DONTDUMP for using in drivers")
> Reported-by: Kenneth Penza <kpenza@gmail.com>
> Signed-off-by: Daniel Black <daniel@linux.ibm.com>
> Buglink: https://lists.launchpad.net/maria-discuss/msg05245.html
> Cc: linux-mm@kvack.org
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  mm/madvise.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 972a9eaa898b..71d21df2a3f3 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -96,7 +96,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  		new_flags |= VM_DONTDUMP;
>  		break;
>  	case MADV_DODUMP:
> -		if (new_flags & VM_SPECIAL) {
> +		if (!is_vm_hugetlb_page(vma) && new_flags & VM_SPECIAL) {

Thanks Daniel,

This is certainly a regression.  My only question is whether this condition
should be more specific and test the default hugetlb vma flags
(VM_DONTEXPAND | VM_HUGETLB).  Or, whether simply checking VM_HUGETLB as you
have done above is sufficient.  Only reason for concern is that I am not
100% certain other VM_SPECIAL flags could not be set in VM_HUGETLB vma.

Perhaps Konstantin has an opinion as he did a bunch of the vm_flag reorg.

-- 
Mike Kravetz


>  			error = -EINVAL;
>  			goto out;
>  		}
> 
