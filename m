Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA8C26B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:18:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so18777676wmt.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 07:18:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si9512650wrp.122.2017.01.17.07.18.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 07:18:20 -0800 (PST)
Date: Tue, 17 Jan 2017 16:18:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170117151817.GR19699@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
 <20170117082425.GD19699@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117082425.GD19699@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-01-17 09:24:25, Michal Hocko wrote:
> On Mon 16-01-17 21:56:07, Theodore Ts'o wrote:
> > On Fri, Jan 06, 2017 at 03:11:07PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > This reverts commit 216553c4b7f3e3e2beb4981cddca9b2027523928. Now that
> > > the transaction context uses memalloc_nofs_save and all allocations
> > > within the this context inherit GFP_NOFS automatically, there is no
> > > reason to mark specific allocations explicitly.
> > > 
> > > This patch should not introduce any functional change. The main point
> > > of this change is to reduce explicit GFP_NOFS usage inside ext4 code
> > > to make the review of the remaining usage easier.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > 
> > Changes in the jbd2 layer aren't going to guarantee that
> > memalloc_nofs_save() will be executed if we are running ext4 without a
> > journal (aka in no journal mode).  And this is a *very* common
> > configuration; it's how ext4 is used inside Google in our production
> > servers.
> 
> OK, I wasn't aware of that.
> 
> > So that means the earlier patches will probably need to be changed so
> > the nOFS scope is done in the ext4_journal_{start,stop} functions in
> > fs/ext4/ext4_jbd2.c.
> 
> I could definitely appreciated some help here. The call paths are rather
> complex and I am not familiar with the code enough. On of the biggest
> problem I have currently is that there doesn't seem to be an easy place
> to store the old allocation context. 

OK, so I've been staring into the code and AFAIU current->journal_info
can contain my stored information. I could either hijack part of the
word as the ref counting is only consuming low 12b. But that looks too
ugly to live. Or I can allocate some placeholder.

But before going to play with that I am really wondering whether we need
all this with no journal at all. AFAIU what Jack told me it is the
journal lock(s) which is the biggest problem from the reclaim recursion
point of view. What would cause a deadlock in no journal mode?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
