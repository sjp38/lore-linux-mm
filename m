Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 497BA6B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 09:03:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 12:42:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q59D3FLb60751892
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 23:03:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59D3EsV000801
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 23:03:14 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 05/16] hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb
In-Reply-To: <20120609094444.GG1761@cmpxchg.org>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120609094444.GG1761@cmpxchg.org>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Sat, 09 Jun 2012 18:33:05 +0530
Message-ID: <87sje4ljsm.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Sat, Jun 09, 2012 at 02:29:50PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
>> fix linked list corruption in unmap_hugepage_range()") but we don't use
>> page->lru in unmap_hugepage_range any more.  Also the lock was taken
>> higher up in the stack in some code path.  That would result in deadlock.
>> 
>> unmap_mapping_range (i_mmap_mutex)
>>  -> unmap_mapping_range_tree
>>     -> unmap_mapping_range_vma
>>        -> zap_page_range_single
>>          -> unmap_single_vma
>> 	      -> unmap_hugepage_range (i_mmap_mutex)
>> 
>> For shared pagetable support for huge pages, since pagetable pages are ref
>> counted we don't need any lock during huge_pmd_unshare.  We do take
>> i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
>> (39dde65c9940c97f ("shared page table for hugetlb page")).
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> This patch (together with the previous one) seems like a bugfix that's
> not really related to the hugetlb controller, unless I miss something.
>
> Could you please submit the fix separately?

Patches upto 6 can really got in a separate series. I was not sure
whether I should split them. I will post that as a separate series now

>
> Maybe also fold the two patches into one and make it a single bugfix
> change that gets rid of the lock by switching away from page->lru.

I wanted to make sure the patch that drop i_mmap_mutex is a separate one
so that we understand and document the locking details separately

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
