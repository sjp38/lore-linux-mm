Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC4B6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 01:41:43 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so6484960pdj.24
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 22:41:42 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id sz7si19306736pab.290.2014.02.02.22.41.39
        for <linux-mm@kvack.org>;
        Sun, 02 Feb 2014 22:41:42 -0800 (PST)
Date: Mon, 3 Feb 2014 15:41:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 6/6] mm, hugetlb: improve page-fault scalability
Message-ID: <20140203064138.GA2360@lge.com>
References: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
 <1391189806-13319-7-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391189806-13319-7-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 31, 2014 at 09:36:46AM -0800, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> The kernel can currently only handle a single hugetlb page fault at a time.
> This is due to a single mutex that serializes the entire path. This lock
> protects from spurious OOM errors under conditions of low of low availability
> of free hugepages. This problem is specific to hugepages, because it is
> normal to want to use every single hugepage in the system - with normal pages
> we simply assume there will always be a few spare pages which can be used
> temporarily until the race is resolved.
> 
> Address this problem by using a table of mutexes, allowing a better chance of
> parallelization, where each hugepage is individually serialized. The hash key
> is selected depending on the mapping type. For shared ones it consists of the
> address space and file offset being faulted; while for private ones the mm and
> virtual address are used. The size of the table is selected based on a compromise
> of collisions and memory footprint of a series of database workloads.

Hello,

Thanks for doing this patchset. :)
Just one question!
Why do we need a separate hash key depending on the mapping type?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
