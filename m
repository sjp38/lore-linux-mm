Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 6EE8A6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 19:35:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 05:02:16 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AD80DE002D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:07:00 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34NZCqQ65077426
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 05:05:13 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34NZFHO001287
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 10:35:16 +1100
Date: Fri, 5 Apr 2013 07:35:14 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130404233514.GA32731@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Cc Andi,
On Thu, Apr 04, 2013 at 05:09:08PM +0800, Wanpeng Li wrote:
>order >= MAX_ORDER pages are only allocated at boot stage using the 
>bootmem allocator with the "hugepages=xxx" option. These pages are never 
>free after boot by default since it would be a one-way street(>= MAX_ORDER
>pages cannot be allocated later), but if administrator confirm not to 
>use these gigantic pages any more, these pinned pages will waste memory
>since other users can't grab free pages from gigantic hugetlb pool even
>if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
>shrink supporting. Administrator can enable knob exported in sysctl to
>permit to shrink gigantic hugetlb pool.
>
>Testcase:
>boot: hugepagesz=1G hugepages=10
>
>[root@localhost hugepages]# free -m
>             total       used       free     shared    buffers     cached
>Mem:         36269      10836      25432          0         11        288
>-/+ buffers/cache:      10537      25732
>Swap:        35999          0      35999
>[root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
>-bash: echo: write error: Invalid argument
>[root@localhost hugepages]# echo 1 > /proc/sys/vm/hugetlb_shrink_gigantic_pool
>[root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
>[root@localhost hugepages]# free -m
>             total       used       free     shared    buffers     cached
>Mem:         36269        597      35672          0         11        288
>-/+ buffers/cache:        297      35972
>Swap:        35999          0      35999
>
>Wanpeng Li (6):
>  introduce new sysctl knob which control gigantic page pools shrinking
>  update_and_free_page gigantic pages awareness
>  enable gigantic hugetlb page pools shrinking
>  use already exist huge_page_order() instead of h->order
>  remove redundant hugetlb_prefault 
>  use already exist interface huge_page_shift
>
> Documentation/sysctl/vm.txt |   13 +++++++
> include/linux/hugetlb.h     |    5 +--
> kernel/sysctl.c             |    7 ++++
> mm/hugetlb.c                |   83 +++++++++++++++++++++++++++++--------------
> mm/internal.h               |    1 +
> mm/page_alloc.c             |    2 +-
> 6 files changed, 82 insertions(+), 29 deletions(-)
>
>-- 
>1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
