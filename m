Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5926B0070
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 11:37:48 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id em10so692973wid.1
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:37:47 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
        by mx.google.com with ESMTPS id gd11si18529451wic.26.2014.09.09.08.37.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 08:37:46 -0700 (PDT)
Received: by mail-wi0-f175.google.com with SMTP id ex7so4556613wid.8
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 08:37:44 -0700 (PDT)
Message-ID: <540F1EC6.4000504@plexistor.com>
Date: Tue, 09 Sep 2014 18:37:42 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 0/9] pmem: Fixes and farther development (mm: add_persistent_memory)
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 08/28/2014 12:11 AM, Ross Zwisler wrote:
> PMEM is a modified version of the Block RAM Driver, BRD. The major difference
> is that BRD allocates its backing store pages from the page cache, whereas
> PMEM uses reserved memory that has been ioremapped.
> 
> One benefit of this approach is that there is a direct mapping between
> filesystem block numbers and virtual addresses.  In PMEM, filesystem blocks N,
> N+1, N+2, etc. will all be adjacent in the virtual memory space. This property
> allows us to set up PMD mappings (2 MiB) for DAX.
> 
> This patch set is builds upon the work that Matthew Wilcox has been doing for
> DAX:
> 

Let us not submit a driver with the wrong user visible API. Lets submit the
better API (and structure) I have sent.

> https://lkml.org/lkml/2014/8/27/31
> 
> Specifically, my implementation of pmem_direct_access() in patch 4/4 uses API
> enhancements introduced in Matthew's DAX patch v10 02/21:
> 
> https://lkml.org/lkml/2014/8/27/48
> 
> Ross Zwisler (4):
>   pmem: Initial version of persistent memory driver
>   pmem: Add support for getgeo()
>   pmem: Add support for rw_page()
>   pmem: Add support for direct_access()
> 

On top of the 4 above patches here is a list of changes:

[PATCH 1/9] SQUASHME: pmem: Remove unused #include headers
[PATCH 2/9] SQUASHME: pmem: Request from fdisk 4k alignment
[PATCH 3/9] SQUASHME: pmem: Let each device manage private memory region
[PATCH 4/9] SQUASHME: pmem: Support of multiple memory regions

	These 4 need to be squashed into Ross's 
		[patch 1/4] pmem: Initial version of persistent memory driver
	See below for a suggested new patch

[PATCH 5/9 v2] mm: Let sparse_{add,remove}_one_section receive a node_id
[PATCH 6/9 v2] mm: New add_persistent_memory/remove_persistent_memory
[PATCH 7/9 v2] pmem: Add support for page structs

	Please need review by Toshi and mm people.

[PATCH 8/9] SQUASHME: pmem: Fixs to getgeo
[PATCH 9/9] pmem: KISS, remove register_blkdev

	And some more development atop the initial version


All these patches can be viewed in this tree/branch:
	git://git.open-osd.org/pmem.git branch pmem-jens-3.17-rc1
	[http://git.open-osd.org/gitweb.cgi?p=pmem.git;a=shortlog;h=refs/heads/pmem-jens-3.17-rc1]

I have also prepared a new branch *pmem* which is already SQUASHED
And has my suggested changed commit logs for the combined patches
here is the commit-log:

aa85c80 Boaz Harrosh  |  pmem: KISS, remove register_blkdev 
738203c Boaz Harrosh  |  pmem: Add support for page structs 
9f50a54 Boaz Harrosh  |  mm: New add_persistent_memory/remove_persistent_memory 
fdfab12 Yigal Korman  |  mm: Let sparse_{add,remove}_one_section receive a node_id 
a477a87 Ross Zwisler  |  pmem: Add support for direct_access() 
316a93a Ross Zwisler  |  pmem: Add support for rw_page() 
6850353 Boaz Harrosh  |  SQUASHME: pmem: Fixs to getgeo 
d78a84a Ross Zwisler  |  pmem: Add support for getgeo() 
bb0eb45 Ross Zwisler  |  pmem: Initial version of persistent memory driver                                                                             

All these patches can be viewed in this tree/branch:
	git://git.open-osd.org/pmem.git branch pmem
	[http://git.open-osd.org/gitweb.cgi?p=pmem.git;a=shortlog;h=refs/heads/pmem]
Specifically the first [bb0eb45] is needed so first version can be released with the
proper user visible API.
Ross please consider taking these patches (pmem branch) in your tree for submission?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
