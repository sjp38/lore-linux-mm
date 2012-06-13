Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 8BEA46B004D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 12:37:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Jun 2012 22:07:14 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5DGbA8o8978918
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:07:11 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5DM7mqn008656
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:07:48 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V9 04/15] hugetlb: use mmu_gather instead of a temporary linked list for accumulating pages
In-Reply-To: <20120613145923.GA14777@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120613145923.GA14777@tiehlicka.suse.cz>
Date: Wed, 13 Jun 2012 22:07:06 +0530
Message-ID: <871uljnp71.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Wed 13-06-12 15:57:23, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Use a mmu_gather instead of a temporary linked list for accumulating
>> pages when we unmap a hugepage range
>
> Sorry for coming up with the comment that late but you owe us an
> explanation _why_ you are doing this.
>
> I assume that this fixes a real problem when we take i_mmap_mutex
> already up in 
> unmap_mapping_range
>   mutex_lock(&mapping->i_mmap_mutex);
>   unmap_mapping_range_tree | unmap_mapping_range_list 
>     unmap_mapping_range_vma
>       zap_page_range_single
>         unmap_single_vma
> 	  unmap_hugepage_range
> 	    mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
>
> And that this should have been marked for stable as well (I haven't
> checked when this has been introduced).

Switch to mmu_gather is to get rid of the use of page->lru so that i can use it for
active list.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
