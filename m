Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id F1B8A6B006E
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 17:50:18 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so47372821qkg.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 14:50:18 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 2/2][v2] blk-plug: don't flush nested plug lists
References: <1428347694-17704-1-git-send-email-jmoyer@redhat.com>
	<1428347694-17704-2-git-send-email-jmoyer@redhat.com>
	<x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
	<20150408230203.GG15810@dastard>
Date: Fri, 10 Apr 2015 17:50:06 -0400
In-Reply-To: <20150408230203.GG15810@dastard> (Dave Chinner's message of "Thu,
	9 Apr 2015 09:02:03 +1000")
Message-ID: <x498udzlkkx.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Roger Pau Monn?? <roger.pau@citrix.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Steven Whitehouse <swhiteho@redhat.com>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, xfs@oss.sgi.com, Christoph Hellwig <hch@lst.de>, Weston Andros Adamson <dros@primarydata.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Sagi Grimberg <sagig@mellanox.com>, Tejun Heo <tj@kernel.org>, Fabian Frederick <fabf@skynet.be>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ming Lei <ming.lei@canonical.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Michal Hocko <mhocko@suse.cz>, Joe Perches <joe@perches.com>, Miklos Szeredi <mszeredi@suse.cz>, Namjae Jeon <namjae.jeon@samsung.com>, Mark Rustad <mark.d.rustad@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-kernel@vger.kernel.org, dm-devel@redhat.com, xen-devel@lists.xenproject.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

Dave Chinner <david@fromorbit.com> writes:

> On Tue, Apr 07, 2015 at 02:55:13PM -0400, Jeff Moyer wrote:
>> The way the on-stack plugging currently works, each nesting level
>> flushes its own list of I/Os.  This can be less than optimal (read
>> awful) for certain workloads.  For example, consider an application
>> that issues asynchronous O_DIRECT I/Os.  It can send down a bunch of
>> I/Os together in a single io_submit call, only to have each of them
>> dispatched individually down in the bowels of the dirct I/O code.
>> The reason is that there are blk_plug-s instantiated both at the upper
>> call site in do_io_submit and down in do_direct_IO.  The latter will
>> submit as little as 1 I/O at a time (if you have a small enough I/O
>> size) instead of performing the batching that the plugging
>> infrastructure is supposed to provide.
>
> I'm wondering what impact this will have on filesystem metadata IO
> that needs to be issued immediately. e.g. we are doing writeback, so
> there is a high level plug in place and we need to page in btree
> blocks to do extent allocation. We do readahead at this point,
> but it looks like this change will prevent the readahead from being
> issued by the unplug in xfs_buf_iosubmit().

I'm not ignoring you, Dave, I'm just doing some more investigation and
testing.  It's taking longer than I had hoped.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
