Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A62CE6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 02:17:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id i10so2238412wrb.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 23:17:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e44si3916626wre.209.2017.02.06.23.17.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 23:17:29 -0800 (PST)
Date: Tue, 7 Feb 2017 08:17:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20170207071724.GA3022@dhcp22.suse.cz>
References: <20170206140718.16222-1-mhocko@kernel.org>
 <20170206140718.16222-5-mhocko@kernel.org>
 <20170206153923.GL2267@bombadil.infradead.org>
 <20170206174415.GA20731@dhcp22.suse.cz>
 <20170206183237.GE3580@birch.djwong.org>
 <20170206184743.GB20731@dhcp22.suse.cz>
 <20170206225150.GB12125@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206225150.GB12125@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Tue 07-02-17 09:51:50, Dave Chinner wrote:
> On Mon, Feb 06, 2017 at 07:47:43PM +0100, Michal Hocko wrote:
> > On Mon 06-02-17 10:32:37, Darrick J. Wong wrote:
[...]
> > > I prefer to keep the "...yet we are likely to be under GFP_NOFS..."
> > > wording of the old comment because it captures the uncertainty of
> > > whether or not we actually are already under NOFS.  If someone actually
> > > has audited this code well enough to know for sure then yes let's change
> > > the comment, but I haven't gone that far.
> > 
> > I believe we can drop the memalloc_nofs_save then as well because either
> > we are called from a potentially dangerous context and thus we are in
> > the nofs scope we we do not need the protection at all.
> 
> No, absolutely not. "Belief" is not a sufficient justification for
> removing low level deadlock avoidance infrastructure. This code
> needs to remain in _xfs_buf_map_pages() until a full audit of the
> caller paths is done and we're 100% certain that there are no
> lurking deadlocks.

Exactly. I was actually refering to "If someone actually has audited
this code" above... So I definitely do not want to justify anything
based on the belief

> For example, I'm pretty sure we can call into _xfs_buf_map_pages()
> outside of a transaction context but with an inode ILOCK held
> exclusively. If we then recurse into memory reclaim and try to run a
> transaction during reclaim, we have an inverted ILOCK vs transaction
> locking order. i.e. we are not allowed to call xfs_trans_reserve()
> with an ILOCK held as that can deadlock the log:  log full, locked
> inode pins tail of log, inode cannot be flushed because ILOCK is
> held by caller waiting for log space to become available....
> 
> i.e. there are certain situations where holding a ILOCK is a
> deadlock vector. See xfs_lock_inodes() for an example of the lengths
> we go to avoid ILOCK based log deadlocks like this...

Thanks for the reference. This is really helpful!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
