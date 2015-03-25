Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0934F6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:40:50 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so18023804wib.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:40:49 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id ua5si3602506wjc.197.2015.03.25.03.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 03:40:48 -0700 (PDT)
Received: by wixw10 with SMTP id w10so32181048wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:40:47 -0700 (PDT)
Message-ID: <551290AC.7080402@plexistor.com>
Date: Wed, 25 Mar 2015 12:40:44 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <55115A99.40705@plexistor.com> <20150325022633.GB31342@dastard> <5512725A.1010905@plexistor.com> <20150325094135.GI31342@dastard>
In-Reply-To: <20150325094135.GI31342@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 11:41 AM, Dave Chinner wrote:
> On Wed, Mar 25, 2015 at 10:31:22AM +0200, Boaz Harrosh wrote:
>> On 03/25/2015 04:26 AM, Dave Chinner wrote:
<>
>> sync and fsync should and will work correctly, but this does not
>> solve our problem. because what turns pages to read-only is the
>> writeback. And we do not have this in dax. Therefore we need to
>> do this here as a special case.
> 
> We can still use exactly the same dirty tracking as we use for data
> writeback. The difference is that we don't need to go through all
> teh page writeback; we can just flush the CPU caches and mark all
> the mappings clean, then clear the I_DIRTY_PAGES flag and move on to
> inode writeback....
> 

I see what you mean. the sb wide sync will not step into mmaped inodes
and fsync them.

If we go my way and write NT (None Temporal) style in Kernel.
NT instructions exist since xeon and all the Intel iX core CPUs have
them. In tests we conducted doing xeon NT-writes vs
regular-writes-and-cl_flush at .fsync showed minimum of 20% improvement.
That is on very large IOs. On 4k IOs it was even better.

It looks like you have a much better picture in your mind how to
fit this properly at the inode-dirty picture. Can you attempt a rough draft?

If we are going the NT way. Then we can only I_DIRTY_ track the mmaped
inodes. For me this is really scary because I do not want to trigger
any writeback threads. If you could please draw me an outline (or write
something up ;-)) it would be great.

> Cheers,
> Dave.

Thanks
Boaz


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
