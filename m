Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BD2DC6B0081
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 00:23:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so11558689pdj.13
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:23:20 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id rb6si13850100pab.272.2014.04.16.21.23.18
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 21:23:19 -0700 (PDT)
Date: Thu, 17 Apr 2014 14:23:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH/RFC 00/19] Support loop-back NFS mounts
Message-ID: <20140417042313.GV15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416104207.75b044e8@tlielax.poochiereds.net>
 <20140417102048.2fc8275c@notabene.brown>
 <20140417012739.GU15995@dastard>
 <20140417115018.460345d0@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140417115018.460345d0@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org, Ming Lei <ming.lei@canonical.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On Thu, Apr 17, 2014 at 11:50:18AM +1000, NeilBrown wrote:
> On Thu, 17 Apr 2014 11:27:39 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Thu, Apr 17, 2014 at 10:20:48AM +1000, NeilBrown wrote:
> > > A good example is the deadlock with the flush-* threads.
> > > flush-* will lock a page, and  then call ->writepage.  If ->writepage
> > > allocates memory it can enter reclaim, call ->releasepage on NFS, and block
> > > waiting for a COMMIT to complete.
> > > The COMMIT might already be running, performing fsync on that same file that
> > > flush-* is flushing.  It locks each page in turn.  When it  gets to the page
> > > that flush-* has locked, it will deadlock.
> > 
> > It's nfs_release_page() again....
> > 
> > > In general, if nfsd is allowed to block on local filesystem, and local
> > > filesystem is allowed to block on NFS, then a deadlock can happen.
> > > We would need a clear hierarchy
> > > 
> > >    __GFP_NETFS > __GFP_FS > __GFP_IO
> > > 
> > > for it to work.  I'm not sure the extra level really helps a lot and it would
> > > be a lot of churn.
> > 
> > I think you are looking at this the wrong way - it's not the other
> > filesystems that have to avoid memory reclaim recursion, it's the
> > NFS client mount that is on loopback that needs to avoid recursion.
> > 
> > IMO, the fix should be that the NFS client cannot block on messages sent to the NFSD
> > on the same host during memory reclaim. That is, nfs_release_page()
> > cannot send commit messages to the server if the server is on
> > localhost. Instead, it just tells memory reclaim that it can't
> > reclaim that page.
> > 
> > If nfs_release_page() no longer blocks in memory reclaim, and all
> > these nfsd-gets-blocked-in-GFP_KERNEL-memory-allocation recursion
> > problems go away. Do the same for all the other memory reclaim
> > operations in the NFS client, and you've got a solution that should
> > work without needing to walk all over the rest of the kernel....
> 
> Maybe.
> It is nfs_release_page() today. I wonder if it could be other things another
> day.  I want to be sure I have a solution that really makes sense.

There could be other things, but in the absence of those things,
I don't think that adding another layer to memory reclaim
dependencies for this niche corner case makes a lot of sense. ;)

> However ... the thing that nfs_release_page is doing it sending a COMMIT to
> tell the server to flush to stable storage.  It does that so that if the
> server crashes, then the client can re-send.
> Of course when it is a loop-back mount the client is the server so the COMMIT
> is completely pointless.  If the client notices that it is sending a COMMIT
> to itself, it can simply assume a positive reply.

Yes, that's very true. You might have to treat ->writepage
specially, too, if that can block, say, on the number of outstanding
requests that can be sent to the server.

> You are right, that would make the patch set a lot less intrusive.  I'll give
> it some serious thought - thanks.

No worries. :)

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
