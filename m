Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 518336B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 06:25:43 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hm4so2903136wib.14
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 03:25:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd8si232969wjc.103.2014.04.09.03.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 03:25:40 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:25:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: hugetlb: ensure hugepage access is denied if hugepages are not
 supported
Message-ID: <20140409102534.GA27270@suse.de>
References: <20140403231413.GB17412@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140403231413.GB17412@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, nyc@holomorphy.com, benh@kernel.crashing.org, paulus@samba.org, anton@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org


On Thu, Apr 03, 2014 at 04:14:13PM -0700, Nishanth Aravamudan wrote:
> In KVM guests on Power, in a guest not backed by hugepages, we see the
> following:
> 
> AnonHugePages:         0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:         64 kB
> 
> HPAGE_SHIFT == 0 in this configuration, which indicates that hugepages
> are not supported at boot-time, but this is only checked in
> hugetlb_init(). Extract the check to a helper function, and use it in a
> few relevant places.
> 
> This does make hugetlbfs not supported (not registered at all) in this
> environment. I believe this is fine, as there are no valid hugepages and
> that won't change at runtime.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

This patch looks ok but the changelog misses important information from
the original report which is probably why it fell through the cracks.
Add the fact that you encountered a problem during mount to the changelog
and resend it directly to Andrew. This part from your original report;

	Currently, I am seeing the following when I `mount -t hugetlbfs
	/none /dev/hugetlbfs`, and then simply do a `ls /dev/hugetlbfs`. I
	think it's related to the fact that hugetlbfs is properly not
	correctly setting itself up in this state?:

	Unable to handle kernel paging request for data at address 0x00000031
	Faulting instruction address: 0xc000000000245710
	Oops: Kernel access of bad area, sig: 11 [#1]
	SMP NR_CPUS=2048 NUMA pSeries
	....

It probably slipped through the cracks because from the changelog this
looks like a minor formatting issue and not a functional fix.

> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index d19b30a..cc8fcc7 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -1017,6 +1017,11 @@ static int __init init_hugetlbfs_fs(void)
>  	int error;
>  	int i;
>  
> +	if (!hugepages_supported()) {
> +		printk(KERN_ERR "hugetlbfs: Disabling because there are no supported hugepage sizes\n");
> +		return -ENOTSUPP;
> +	}
> +
>  	error = bdi_init(&hugetlbfs_backing_dev_info);
>  	if (error)
>  		return error;

KERN_ERR feels like overkill for this type of issue. KERN_INFO?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
