Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3111F6B04BB
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 04:10:32 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so550299wrh.19
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 01:10:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si2115174wrg.337.2018.01.04.01.10.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 01:10:30 -0800 (PST)
Date: Thu, 4 Jan 2018 10:10:28 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20180104091028.GB29010@quack2.suse.cz>
References: <20171211233619.GQ4094@dastard>
 <20171212180534.c5f7luqz5oyfe7c3@destiny>
 <20171212222004.GT4094@dastard>
 <20171219120709.GE2277@quack2.suse.cz>
 <20171219213505.GN5858@dastard>
 <20171220143055.GA31584@quack2.suse.cz>
 <20180102161305.6r6qvz5bfixbn3dv@destiny>
 <20180103023219.GC30682@dastard>
 <20180103135921.GF4911@quack2.suse.cz>
 <20180104013207.GB32627@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104013207.GB32627@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Thu 04-01-18 12:32:07, Dave Chinner wrote:
> On Wed, Jan 03, 2018 at 02:59:21PM +0100, Jan Kara wrote:
> > On Wed 03-01-18 13:32:19, Dave Chinner wrote:
> > > I think we could probably block ->write_metadata if necessary via a
> > > completion/wakeup style notification when a specific LSN is reached
> > > by the log tail, but realistically if there's any amount of data
> > > needing to be written it'll throttle data writes because the IO
> > > pipeline is being kept full by background metadata writes....
> > 
> > So the problem I'm concerned about is a corner case. Consider a situation
> > when you have no dirty data, only dirty metadata but enough of them to
> > trigger background writeback. How should metadata writeback behave for XFS
> > in this case? Who should be responsible that wb_writeback() just does not
> > loop invoking ->write_metadata() as fast as CPU allows until xfsaild makes
> > enough progress?
> >
> > Thinking about this today, I think this looping prevention belongs to
> > wb_writeback().
> 
> Well, backgroudn data writeback can block in two ways. One is during
> IO submission when the request queue is full, the other is when all
> dirty inodes have had some work done on them and have all been moved
> to b_more_io - wb_writeback waits for the __I_SYNC bit to be cleared
> on the last(?) inode on that list, hence backing off before
> submitting more IO.
> 
> IOws, there's a "during writeback" blocking mechanism as well as a
> "between cycles" block mechanism.
> 
> > Sadly we don't have much info to decide how long to sleep
> > before trying more writeback so we'd have to just sleep for
> > <some_magic_amount> if we found no writeback happened in the last writeback
> > round before going through the whole writeback loop again.
> 
> Right - I don't think we can provide a generic "between cycles"
> blocking mechanism for XFS, but I'm pretty sure we can emulate a
> "during writeback" blocking mechanism to avoid busy looping inside
> the XFS code.
> 
> e.g. if we get a writeback call that asks for 5% to be written,
> and we already have a metadata writeback target of 5% in place,
> that means we should block for a while. That would emulate request
> queue blocking and prevent busy looping in this case....

If you can do this in XFS then fine, it saves some mess in the generic
code.

> > And
> > ->write_metadata() for XFS would need to always return 0 (as in "no progress
> > made") to make sure this busyloop avoidance logic in wb_writeback()
> > triggers. ext4 and btrfs would return number of bytes written from
> > ->write_metadata (or just 1 would be enough to indicate some progress in
> > metadata writeback was made and busyloop avoidance is not needed).
> 
> Well, if we block for a little while, we can indicate that progress
> has been made and this whole mess would go away, right?

Right. So let's just ignore the problem for the sake of Josef's patch set.
Once the patches land and when XFS starts using the infrastructure, we will
make sure this is handled properly.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
