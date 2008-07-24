Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6O7TDlY010599
	for <linux-mm@kvack.org>; Thu, 24 Jul 2008 03:29:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6O7TDIE174424
	for <linux-mm@kvack.org>; Thu, 24 Jul 2008 03:29:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6O7TDbn013065
	for <linux-mm@kvack.org>; Thu, 24 Jul 2008 03:29:13 -0400
Message-ID: <48882F4A.10201@us.ibm.com>
Date: Thu, 24 Jul 2008 02:29:14 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] hugetlb: override default huge page size non-const fix
References: <20080723040644.GA18119@wotan.suse.de>
In-Reply-To: <20080723040644.GA18119@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
>
> I revisited the multi-size hugetlb patches, and realised I forgot one small
> outstanding issue. Your
> hugetlb-override-default-huge-page-size-ia64-build.patch
> fix basically disallows overriding of the default hugetlb size, because we
> always set the default back to HPAGE_SIZE.
>
> A better fix I think is just to initialize the default_hstate_size to an
> invalid value, which the init code checks for and reverts to HPAGE_SIZE
> anyway. So please replace that patch with this one.
>
> Overriding of the default hugepage size is not of major importance, but it
> can allow legacy code (providing it is well written), including the hugetlb
> regression suite to be run with different hugepage sizes (so actually it is
> quite important for developers at least).
>
> I don't have access to such a machine, but I hope (with this patch), the
> powerpc developers can run the libhugetlb regression suite one last time
> against a range of page sizes and ensure the results look reasonable.
>   
I am a little slow here, but I was able to boot with 
default_hugepagesz=64K and 16G on Power and it set the default huge page 
size to the given size.

Jon

> Thanks,
> Nick
>
> --
>
> If HPAGE_SIZE is not constant (eg. on ia64), then the initialiser does not
> work. Fix this by making default_hstate_size == 0, then if it isn't set
> from the cmdline, hugetlb_init will still do the right thing and set up the
> default hstate as (the now initialized) HPAGE_SIZE.
>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -34,7 +34,7 @@ struct hstate hstates[HUGE_MAX_HSTATE];
>  /* for command line parsing */
>  static struct hstate * __initdata parsed_hstate;
>  static unsigned long __initdata default_hstate_max_huge_pages;
> -static unsigned long __initdata default_hstate_size = HPAGE_SIZE;
> +static unsigned long __initdata default_hstate_size = 0;
>
>  #define for_each_hstate(h) \
>  	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
