Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 989976B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 02:15:03 -0400 (EDT)
Received: by wegp1 with SMTP id p1so155027552weg.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 23:15:03 -0700 (PDT)
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com. [74.125.82.177])
        by mx.google.com with ESMTPS id w1si15461363wix.3.2015.03.23.23.15.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 23:15:01 -0700 (PDT)
Received: by weop45 with SMTP id p45so155097677weo.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 23:15:01 -0700 (PDT)
Message-ID: <551100E3.9010007@plexistor.com>
Date: Tue, 24 Mar 2015 08:14:59 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <20150323224047.GQ28621@dastard>
In-Reply-To: <20150323224047.GQ28621@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/24/2015 12:40 AM, Dave Chinner wrote:
> On Mon, Mar 23, 2015 at 02:54:40PM +0200, Boaz Harrosh wrote:
>> From: Boaz Harrosh <boaz@plexistor.com>
>>
>> When freezing an FS, we must write protect all IS_DAX()
>> inodes that have an mmap mapping on an inode. Otherwise
>> application will be able to modify previously faulted-in
>> file pages.
> 
> All you need to do is lock out page faults once the page is clean;
> that's what the sb_start_pagefault() calls are for in the page fault
> path - they catch write faults and block them until the filesystem
> is unfrozen. Hence I'm not sure why this would be necessary if you
> are catching write faults in .pfn_mkwrite....
> 

Jan pointed it out and he was right I have a test for this. What
happens is that since we had a mapping from before the freeze we will
not have a page-fault. And the buffers will be modified.

As Jan explained in the cache path we do a writeback which turns
all pages to read-only. But with dax we do not have writeback
so the pages stay read-write mapped. Something needs to loop
through the pages and write-protect them. I chose to unmap
them because it is the much-much smaller code, and I do not care
to optimize the freeze.

[Yes, sigh, I will convert the test to an xfstest. May I just add
 it to some existing fs_freeze test. Only novelty is that we need
 to write-access an mmap block before the freeze-start, then continue
 access after the freeze and see modifications
]

> Cheers,
> Dave.
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
