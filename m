Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id B56C66B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:49:58 -0500 (EST)
Received: by ierx19 with SMTP id x19so64800311ier.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:49:58 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id i201si3820000ioi.31.2015.03.03.21.49.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 21:49:58 -0800 (PST)
Received: by igdh15 with SMTP id h15so34123149igd.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:49:58 -0800 (PST)
Date: Tue, 3 Mar 2015 21:49:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/4] hugetlbfs: optionally reserve all fs pages at mount
 time
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Message-ID: <alpine.DEB.2.10.1503032145110.12253@chino.kir.corp.google.com>
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 3 Mar 2015, Mike Kravetz wrote:

> hugetlbfs allocates huge pages from the global pool as needed.  Even if
> the global pool contains a sufficient number pages for the filesystem
> size at mount time, those global pages could be grabbed for some other
> use.  As a result, filesystem huge page allocations may fail due to lack
> of pages.
> 
> Applications such as a database want to use huge pages for performance
> reasons.  hugetlbfs filesystem semantics with ownership and modes work
> well to manage access to a pool of huge pages.  However, the application
> would like some reasonable assurance that allocations will not fail due
> to a lack of huge pages.  At application startup time, the application
> would like to configure itself to use a specific number of huge pages.
> Before starting, the application will can check to make sure that enough
> huge pages exist in the system global pools.  What the application wants
> is exclusive use of a subpool of huge pages. 
> 
> Add a new hugetlbfs mount option 'reserved' to specify that the number
> of pages associated with the size of the filesystem will be reserved.  If
> there are insufficient pages, the mount will fail.  The reservation is
> maintained for the duration of the filesystem so that as pages are
> allocated and free'ed a sufficient number of pages remains reserved.
> 

This functionality is somewhat limited because it's not possible to 
reserve a subset of the size for a single mount point, it's either all or 
nothing.  It shouldn't be too difficult to just add a reserved=<value> 
option where <value> is <= size.  If it's done that way, you should be 
able to omit size= entirely for unlimited hugepages but always ensure that 
a low watermark of hugepages are reserved for the database.

> Comments from RFC addressed/incorporated
> 
> Mike Kravetz (4):
>   hugetlbfs: add reserved mount fields to subpool structure
>   hugetlbfs: coordinate global and subpool reserve accounting
>   hugetlbfs: accept subpool reserved option and setup accordingly
>   hugetlbfs: document reserved mount option
> 
>  Documentation/vm/hugetlbpage.txt | 18 ++++++++------
>  fs/hugetlbfs/inode.c             | 15 ++++++++++--
>  include/linux/hugetlb.h          |  7 ++++++
>  mm/hugetlb.c                     | 53 +++++++++++++++++++++++++++++++++-------
>  4 files changed, 75 insertions(+), 18 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
