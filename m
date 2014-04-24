Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 99C696B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 21:21:22 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so1370913pbc.30
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:21:22 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id xy8si1611912pab.160.2014.04.23.18.21.20
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 18:21:21 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:20:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH/RFC 0/5] Support loop-back NFS mounts - take 2
Message-ID: <20140424012022.GX15995@dastard>
References: <20140423022441.4725.89693.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140423022441.4725.89693.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 23, 2014 at 12:40:58PM +1000, NeilBrown wrote:
> This is a somewhat shorter patchset for loop-back NFS support than
> last time, thanks to the excellent feedback and particularly to Dave
> Chinner.  Thanks.
> 
> Avoiding the wait-for-congestion which can trigger a livelock is much
> the same, though I've reduced the cases in which the wait is
> by-passed.
> I did this using current->backing_dev_info which is otherwise serving
> no purpose on the current kernel.
> 
> Avoiding the deadlocks has been turned on its head.
> Instead of nfsd checking if it is a loop-back mount and setting
> PF_FSTRANS, which then needs lots of changes too PF_FSTRANS and
> __GFP_FS handling, it is now NFS which checks for a loop-back
> filesystem.
> 
> There is more verbosity in that patch (Fifth of Five) but the essence
> is that nfs_release_page will now not wait indefinitely for a COMMIT
> request to complete when sent to the local host.  It still waits a
> little while as some delay can be important. But it won't wait
> forever.
> The duration of "a little while" is currently 100ms, though I do
> wonder if a bigger number would serve just as well.
> 
> Unlike the previous series, this set should remove deadlocks that
> could happen during the actual fail-over process.  This is achieved by
> having nfs_release_page monitor the connection and if it changes from
> a remote to a local connection, or just disconnects, then it will
> timeout.  It currently polls every second, though this probably could
> be longer too.  It only needs to be the same order of magnitude as the
> time it takes node failure to be detected and failover to happen, and
> I suspect that is closer to 1 minute.  So maybe a 10 or 20 second poll
> interval would be just as good.
> 
> Implementing this timeout requires some horrible code as the
> wait_on_bit functions don't support timeouts.  If the general approach
> is found acceptable I'll explore ways to improve the timeout code.
> 
> Comments, criticism, etc very welcome as always,

Looks much less intrusive to me, and doesn't appear to affect any
other filesystem or the recursion patterns of memory reclaim,
so I like it very much more than the previous patchset. Nice work!
:)

The code changes are really outside my area of expertise now, so I
don't really feel qualified to review the changes. However, consider
the overall approach:

Acked-by: Dave Chinner <dchinner@redhat.com>

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
