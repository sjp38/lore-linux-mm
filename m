Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDEB6B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:15:05 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id r126so15865830vkg.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 21:15:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d4si585300uaa.115.2017.06.27.21.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 21:15:03 -0700 (PDT)
Date: Tue, 27 Jun 2017 21:12:20 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 3/6] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170628041220.GB7736@birch.djwong.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-4-mhocko@kernel.org>
 <20170627084950.GI28072@dhcp22.suse.cz>
 <20170627134751.GA28043@infradead.org>
 <20170627140654.GO28072@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627140654.GO28072@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs <linux-xfs@vger.kernel.org>

[add linux-xfs to cc]

FYI this is a discussion of the patch "xfs: map KM_MAYFAIL to
__GFP_RETRY_MAYFAIL" which was last discussed on the xfs list in March
and now is in the -mm tree...

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?h=next-20170627&id=43182d82c48fae80d31a9101b6bb06d75cee32c7

On Tue, Jun 27, 2017 at 04:06:54PM +0200, Michal Hocko wrote:
> On Tue 27-06-17 06:47:51, Christoph Hellwig wrote:
> > On Tue, Jun 27, 2017 at 10:49:50AM +0200, Michal Hocko wrote:
> > > Christoph, Darrick
> > > could you have a look at this patch please? Andrew has put it into mmotm
> > > but I definitely do not want it passes your attention.
> > 
> > I don't think what we have to gain from it.  Callsite for KM_MAYFAIL
> > should handler failures, but the current behavior seems to be doing fine
> > too.
> 
> Last time I've asked I didnd't get any reply so let me ask again. Some
> of those allocations seem to be small (e.g. by a random look
> xlog_cil_init allocates struct xfs_cil which is 576B and struct
> xfs_cil_ctx 176B). Those do not fail currently under most conditions and
> it will retry allocation with the OOM killer if there is no progress. As
> you know that failing those is acceptable, wouldn't it be better to
> simply fail them and do not disrupt the system with the oom killer?

I remember the first time I saw this patch, and didn't have much of an
opinion either way -- the current behavior is fine, so why mess around?
I'd just as soon XFS not have to deal with errors if it doesn't have to. :)

But, you've asked again, so I'll be less glib this time.

I took a quick glance at all the MAYFAIL users in XFS.  /Nearly/ all
them seem to be cases either where we're mounting a filesystem or are
collecting memory for some ioctl -- in either case it's not hard to just
fail back out to userspace.  The upcoming online fsck patches use it
heavily, which is fine since we can always fail out to userspace and
tell the admin to go run xfs_repair offline.

The one user that caught my eye was xfs_iflush_cluster, which seems to
want an array of pointers to a cluster's worth of struct xfs_inodes.  On
a 64k block fs with 256 byte pointers I guess that could be ~2k worth of
pointers, but otoh it looks like that's an optimization: If we're going
to flush an inode out to disk we opportunistically scan the inode tree
to see if the adjacent inodes are also ready to flush; if we can't get
the memory for this, then it just backs off to flushing the one inode.

All the callers of MAYFAIL that I found actually /do/ check the return
value and start bailing out... so, uh, I guess I'm fine with it.  At
worst it's easily reverted during -rc if it causes problems.  Anyone
have a stronger objection?

Acked-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
