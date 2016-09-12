Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3C776B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 19:18:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 188so199008104iti.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 16:18:30 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 18si6354903ion.58.2016.09.12.16.18.29
        for <linux-mm@kvack.org>;
        Mon, 12 Sep 2016 16:18:30 -0700 (PDT)
Date: Tue, 13 Sep 2016 09:18:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/3] writeback: allow for dirty metadata accounting
Message-ID: <20160912231826.GK22388@dastard>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-3-git-send-email-jbacik@fb.com>
 <20160909081743.GC22777@quack2.suse.cz>
 <bd00ed53-00c8-49d2-13b2-5f7dfa607185@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd00ed53-00c8-49d2-13b2-5f7dfa607185@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: Jan Kara <jack@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

On Mon, Sep 12, 2016 at 10:56:04AM -0400, Josef Bacik wrote:
> I think that looping through all the sb's in the system would be
> kinda shitty for this tho, we want the "get number of dirty pages"
> part to be relatively fast.  What if I do something like the
> shrinker_control only for dirty objects. So the fs registers some
> dirty_objects_control, we call into each of those and get the counts
> from that.  Does that sound less crappy?  Thanks,

Hmmm - just an off-the-wall thought on this....

If you're going to do that, then why wouldn't you simply use a
"shrinker" to do the metadata writeback rather than having a hook to
count dirty objects to pass to some other writeback code that calls
a hook to write the metadata?

That way filesystems can also implement dirty accounting and
"writers" for each cache of objects they currently implement
shrinkers for. i.e. just expanding shrinkers to be able to "count
dirty objects" and "write dirty objects" so that we can tell
filesystems to write back all their different metadata caches
proportionally to the size of the page cache and it's dirty state.
The existing file data and inode writeback could then just be new
generic "superblock shrinker" operations, and the fs could have it's
own private metadata writeback similar to the private sb shrinker
callout we currently have...

And, in doing so, we might be able to completely hide memcg from the
writeback implementations similar to the way memcg is completely
hidden from the shrinker reclaim implementations...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
