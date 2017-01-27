Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C90B6B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 04:37:39 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so45451083wjd.2
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 01:37:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si5271374wra.193.2017.01.27.01.37.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 01:37:38 -0800 (PST)
Date: Fri, 27 Jan 2017 10:37:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170127093735.GB4143@dhcp22.suse.cz>
References: <20170117082425.GD19699@dhcp22.suse.cz>
 <20170117151817.GR19699@dhcp22.suse.cz>
 <20170117155916.dcizr65bwa6behe7@thunk.org>
 <20170117161618.GT19699@dhcp22.suse.cz>
 <20170117172925.GA2486@quack2.suse.cz>
 <20170119083956.GE30786@dhcp22.suse.cz>
 <20170119092236.GC2565@quack2.suse.cz>
 <20170119094405.GK30786@dhcp22.suse.cz>
 <20170126074455.GC8456@dhcp22.suse.cz>
 <20170127061318.xd2qxashbl4dajez@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170127061318.xd2qxashbl4dajez@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri 27-01-17 01:13:18, Theodore Ts'o wrote:
> On Thu, Jan 26, 2017 at 08:44:55AM +0100, Michal Hocko wrote:
> > > > I'm convinced the current series is OK, only real life will tell us whether
> > > > we missed something or not ;)
> > > 
> > > I would like to extend the changelog of "jbd2: mark the transaction
> > > context with the scope GFP_NOFS context".
> > > 
> > > "
> > > Please note that setups without journal do not suffer from potential
> > > recursion problems and so they do not need the scope protection because
> > > neither ->releasepage nor ->evict_inode (which are the only fs entry
> > > points from the direct reclaim) can reenter a locked context which is
> > > doing the allocation currently.
> > > "
> > 
> > Could you comment on this Ted, please?
> 
> I guess....   so there still is one way this could screw us, and it's this reason for GFP_NOFS:
> 
>         - to prevent from stack overflows during the reclaim because
> 	          the allocation is performed from a deep context already
> 
> The writepages call stack can be pretty deep.  (Especially if we're
> using ext4 in no journal mode over, say, iSCSI.)
> 
> How much stack space can get consumed by a reclaim?

./scripts/stackusage with allyesconfig says:

./mm/page_alloc.c:3745  __alloc_pages_nodemask  264     static
./mm/page_alloc.c:3531  __alloc_pages_slowpath  520     static
./mm/vmscan.c:2946      try_to_free_pages       216     static
./mm/vmscan.c:2753      do_try_to_free_pages    304     static
./mm/vmscan.c:2517      shrink_node     	352     static
./mm/vmscan.c:2317      shrink_node_memcg       560     static
./mm/vmscan.c:1692      shrink_inactive_list    688     static
./mm/vmscan.c:908       shrink_page_list        608     static

So this would be 3512 for the standard LRUs reclaim whether we have
GFP_FS or not. shrink_page_list can recurse to releasepage but there is
no NOFS protection there so it doesn't make much sense to check this
path. So we are left with the slab shrinkers path

./mm/page_alloc.c:3745  __alloc_pages_nodemask  264     static
./mm/page_alloc.c:3531  __alloc_pages_slowpath  520     static
./mm/vmscan.c:2946      try_to_free_pages       216     static
./mm/vmscan.c:2753      do_try_to_free_pages    304     static
./mm/vmscan.c:2517      shrink_node     	352     static
./mm/vmscan.c:427       shrink_slab     	336     static
./fs/super.c:56 	super_cache_scan        104     static << here we have the NOFS protection
./fs/dcache.c:1089      prune_dcache_sb 	152     static
./fs/dcache.c:939       shrink_dentry_list      96      static
./fs/dcache.c:509       __dentry_kill   	72      static
./fs/dcache.c:323       dentry_unlink_inode     64      static
./fs/inode.c:1527       iput    		80      static
./fs/inode.c:532        evict   		72      static

This is where the fs specific callbacks play role and I am not sure
which paths can pass through for ext4 in the nojournal mode and how much
of the stack this can eat. But currently we are at +536 wrt. NOFS
context. This is quite a lot but still much less (2632 vs. 3512) than
the regular reclaim. So there is quite some stack space to eat... I am
wondering whether we have to really treat nojournal mode any special
just because of the stack usage?

If this ever turn out to be a problem and with the vmapped stacks we
have good chances to get a proper stack traces on a potential overflow
we can add the scope API around the problematic code path with the
explanation why it is needed.

Does that make sense to you?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
