Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D11BE6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:44:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so42815612wmi.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 23:44:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f143si25455988wme.164.2017.01.25.23.44.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 23:44:58 -0800 (PST)
Date: Thu, 26 Jan 2017 08:44:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170126074455.GC8456@dhcp22.suse.cz>
References: <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
 <20170117082425.GD19699@dhcp22.suse.cz>
 <20170117151817.GR19699@dhcp22.suse.cz>
 <20170117155916.dcizr65bwa6behe7@thunk.org>
 <20170117161618.GT19699@dhcp22.suse.cz>
 <20170117172925.GA2486@quack2.suse.cz>
 <20170119083956.GE30786@dhcp22.suse.cz>
 <20170119092236.GC2565@quack2.suse.cz>
 <20170119094405.GK30786@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119094405.GK30786@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-01-17 10:44:05, Michal Hocko wrote:
> On Thu 19-01-17 10:22:36, Jan Kara wrote:
> > On Thu 19-01-17 09:39:56, Michal Hocko wrote:
> > > On Tue 17-01-17 18:29:25, Jan Kara wrote:
> > > > On Tue 17-01-17 17:16:19, Michal Hocko wrote:
> > > > > > > But before going to play with that I am really wondering whether we need
> > > > > > > all this with no journal at all. AFAIU what Jack told me it is the
> > > > > > > journal lock(s) which is the biggest problem from the reclaim recursion
> > > > > > > point of view. What would cause a deadlock in no journal mode?
> > > > > > 
> > > > > > We still have the original problem for why we need GFP_NOFS even in
> > > > > > ext2.  If we are in a writeback path, and we need to allocate memory,
> > > > > > we don't want to recurse back into the file system's writeback path.
> > > > > 
> > > > > But we do not enter the writeback path from the direct reclaim. Or do
> > > > > you mean something other than pageout()'s mapping->a_ops->writepage?
> > > > > There is only try_to_release_page where we get back to the filesystems
> > > > > but I do not see any NOFS protection in ext4_releasepage.
> > > > 
> > > > Maybe to expand a bit: These days, direct reclaim can call ->releasepage()
> > > > callback, ->evict_inode() callback (and only for inodes with i_nlink > 0),
> > > > shrinkers. That's it. So the recursion possibilities are rather more limited
> > > > than they used to be several years ago and we likely do not need as much
> > > > GFP_NOFS protection as we used to.
> > > 
> > > Thanks for making my remark more clear Jack! I would just want to add
> > > that I was playing with the patch below (it is basically
> > > GFP_NOFS->GFP_KERNEL for all allocations which trigger warning from the
> > > debugging patch which means they are called from within transaction) and
> > > it didn't hit the lockdep when running xfstests both with or without the
> > > enabled journal.
> > > 
> > > So am I still missing something or the nojournal mode is safe and the
> > > current series is OK wrt. ext*?
> > 
> > I'm convinced the current series is OK, only real life will tell us whether
> > we missed something or not ;)
> 
> I would like to extend the changelog of "jbd2: mark the transaction
> context with the scope GFP_NOFS context".
> 
> "
> Please note that setups without journal do not suffer from potential
> recursion problems and so they do not need the scope protection because
> neither ->releasepage nor ->evict_inode (which are the only fs entry
> points from the direct reclaim) can reenter a locked context which is
> doing the allocation currently.
> "

Could you comment on this Ted, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
