Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD0B86B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:24:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o141so87605356ioe.4
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:24:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m129si27031584itb.53.2016.10.13.08.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 08:24:49 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
Date: Thu, 13 Oct 2016 08:24:31 -0700
MIME-Version: 1.0
In-Reply-To: <57FF7BB4.1070202@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com

On 10/13/2016 05:19 AM, Jan Stancek wrote:
> Hi,
> 
> I'm running into ENOMEM failures with libhugetlbfs testsuite [1] on
> a power8 lpar system running 4.8 or latest git [2]. Repeated runs of
> this suite trigger multiple OOMs, that eventually kill entire system,
> it usually takes 3-5 runs:
> 
>  * Total System Memory......:  18024 MB
>  * Shared Mem Max Mapping...:    320 MB
>  * System Huge Page Size....:     16 MB
>  * Available Huge Pages.....:     20
>  * Total size of Huge Pages.:    320 MB
>  * Remaining System Memory..:  17704 MB
>  * Huge Page User Group.....:  hugepages (1001)
> 
> I see this only on ppc (BE/LE), x86_64 seems unaffected and successfully
> ran the tests for ~12 hours.
> 
> Bisect has identified following patch as culprit:
>   commit 67961f9db8c477026ea20ce05761bde6f8bf85b0
>   Author: Mike Kravetz <mike.kravetz@oracle.com>
>   Date:   Wed Jun 8 15:33:42 2016 -0700
>     mm/hugetlb: fix huge page reserve accounting for private mappings
> 

Thanks Jan, I'll take a look.

> 
> Following patch (made with my limited insight) applied to
> latest git [2] fixes the problem for me:
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec49d9e..7261583 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1876,7 +1876,7 @@ static long __vma_reservation_common(struct hstate *h,
>                  * return value of this routine is the opposite of the
>                  * value returned from reserve map manipulation routines above.
>                  */
> -               if (ret)
> +               if (ret >= 0)
>                         return 0;
>                 else
>                         return 1;
> 

Do note that this code is only executed if this condition is true:

	else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER) && ret >= 0) {

So, we would always return 0.  This always tells the calling code that a
reservation exists.

-- 
Mike Kravetz

> Regards,
> Jan
> 
> [1] https://github.com/libhugetlbfs/libhugetlbfs
> [2] v4.8-14230-gb67be92
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
