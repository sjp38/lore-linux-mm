Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 66A2B6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 23:11:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 700533EE0C8
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 50A4145DD74
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F2F245DE4D
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BF871DB802C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B79C21DB803F
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:37 +0900 (JST)
Message-ID: <4FD955E8.5050100@jp.fujitsu.com>
Date: Thu, 14 Jun 2012 12:09:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V9 05/15] hugetlb: avoid taking i_mmap_mutex in unmap_single_vma()
 for hugetlb
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339583254-895-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/13 19:27), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
> fix linked list corruption in unmap_hugepage_range()") but we don't use
> page->lru in unmap_hugepage_range any more.  Also the lock was taken
> higher up in the stack in some code path.  That would result in deadlock.
> 
> unmap_mapping_range (i_mmap_mutex)
>   ->  unmap_mapping_range_tree
>      ->  unmap_mapping_range_vma
>         ->  zap_page_range_single
>           ->  unmap_single_vma
> 	      ->  unmap_hugepage_range (i_mmap_mutex)
> 
> For shared pagetable support for huge pages, since pagetable pages are ref
> counted we don't need any lock during huge_pmd_unshare.  We do take
> i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
> (39dde65c9940c97f ("shared page table for hugetlb page")).
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
