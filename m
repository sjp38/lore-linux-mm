Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC6C36B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 11:52:32 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id c82so307928vkd.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:52:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g30si8497019uab.241.2017.09.13.08.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 08:52:31 -0700 (PDT)
Date: Wed, 13 Sep 2017 11:52:05 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [RFC Patch 1/1] mm/hugetlb: Clarify OOM message on size of
 hugetlb and requested hugepages total
Message-ID: <20170913155204.w75sgaosyqi6it57@oracle.com>
References: <20170911154820.16203-1-Liam.Howlett@Oracle.com>
 <20170911154820.16203-2-Liam.Howlett@Oracle.com>
 <20170913124258.dipjsogp6vzqyjf4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913124258.dipjsogp6vzqyjf4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@Oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

* Michal Hocko <mhocko@kernel.org> [170913 08:43]:
> On Mon 11-09-17 11:48:20, Liam R. Howlett wrote:
> > Change the output of hugetlb_show_meminfo to give the size of the
> > hugetlb in more than just Kb and add a warning message if the requested
> > hugepages is larger than the allocated hugepages.  The warning message
> > for very badly configured hugepages has been removed in favour of this
> > method.
> > 
> > The new messages look like this:
> > ----
> > Node 0 hugepages_total=1 hugepages_free=1 hugepages_surp=0
> > hugepages_size=1.00 GiB
> > 
> > Node 0 hugepages_total=1326 hugepages_free=1326 hugepages_surp=0
> > hugepages_size=2.00 MiB
> > 
> > hugepage_size 1.00 GiB: Requested 5 hugepages (5.00 GiB) but 1 hugepages
> > (1.00 GiB) were allocated.
> > 
> > hugepage_size 2.00 MiB: Requested 4000 hugepages (7.81 GiB) but 1326
> > hugepages (2.59 GiB) were allocated.
> > ----
> > 
> > The old messages look like this:
> > ----
> > Node 0 hugepages_total=1 hugepages_free=1 hugepages_surp=0
> > hugepages_size=1048576kB
> > 
> > Node 0 hugepages_total=1435 hugepages_free=1435 hugepages_surp=0
> > hugepages_size=2048kB
> > ----
> > 
> > Signed-off-by: Liam R. Howlett <Liam.Howlett@Oracle.com>
> 
> To be honest, I really dislike this. It doesn't really add anything
> really new to the OOM report. We already know how much memory is
> unreclaimable because it is reserved for hugetlb usage. Why does the
> requested size make any difference? We could fail to allocate requested
> number of pages because of memory pressure or fragmentation without any
> sign of misconfiguration.

Okay, thanks.  I was trying to address the issues you had with the
previous logging addition.

I understand that the OOM report is clear to many, but I thought it
would be more clear if the hugepage size was printed in a human readable
format instead of KB, especially with platforms supporting a lot of
huge page sizes and we already use the formatting elsewhere.

My thoughts for the requested size was to expose the failure to allocate
a resource which currently doesn't have any reporting back to the user -
except on boot failures, which you also disliked.  I thought reporting
in the OOM message would be less of a change than reporting at
allocation time and it would be more clear what happened on poorly
configured systems as the failure would be printed closer to the panic.

> 
> Also req_max_huge_pages would have to be per NUMA node othwerise you are
> just losing information when allocation hugetlb pages via sysfs per node
> interface.
> 

Thank you for your thorough review and time,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
