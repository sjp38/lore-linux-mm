Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 335EA6B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 08:04:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 2 Apr 2012 17:34:31 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q32C4RlM3256350
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 17:34:28 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q32HXfRZ017138
	for <linux-mm@kvack.org>; Tue, 3 Apr 2012 03:33:42 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Question on i_mmap_mutex locking rule
Date: Mon, 02 Apr 2012 17:34:26 +0530
Message-ID: <877gxygx11.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>


Hi,

I started looking at unmap_hugepage_range. unmap_hugepage_range takes
i_mmap_mutex. But then the same lock is also taken higher up in the
stack. ie via the below chain

unmap_mapping_range (i_mmap_mutex)
 -> unmap_mapping_range_tree
    -> unmap_mapping_range_vma
       -> zap_page_range_single
          -> unmap_single_vma
             -> unmap_hugepage_range (i_mmap_mutex)

But there are other code path that doesn't take i_mmap_mutex. For ex:
-> madvise_dontneed
   -> zap_page_range
      -> unmap_vmas
         -> unmap_single_vma
            -> unmap_page_range
      

similarly unmap_region also don't take i_mmap_mutex. Don't we need to
ensure that we take i_mmap_mutex when we unmap a file backed range ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
