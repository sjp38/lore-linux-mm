Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9CE36B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 03:24:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c206so32007826wme.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 00:24:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r73si15106496wmb.104.2017.01.17.00.24.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 00:24:28 -0800 (PST)
Date: Tue, 17 Jan 2017 09:24:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170117082425.GD19699@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117025607.frrcdbduthhutrzj@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 16-01-17 21:56:07, Theodore Ts'o wrote:
> On Fri, Jan 06, 2017 at 03:11:07PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > This reverts commit 216553c4b7f3e3e2beb4981cddca9b2027523928. Now that
> > the transaction context uses memalloc_nofs_save and all allocations
> > within the this context inherit GFP_NOFS automatically, there is no
> > reason to mark specific allocations explicitly.
> > 
> > This patch should not introduce any functional change. The main point
> > of this change is to reduce explicit GFP_NOFS usage inside ext4 code
> > to make the review of the remaining usage easier.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Jan Kara <jack@suse.cz>
> 
> Changes in the jbd2 layer aren't going to guarantee that
> memalloc_nofs_save() will be executed if we are running ext4 without a
> journal (aka in no journal mode).  And this is a *very* common
> configuration; it's how ext4 is used inside Google in our production
> servers.

OK, I wasn't aware of that.

> So that means the earlier patches will probably need to be changed so
> the nOFS scope is done in the ext4_journal_{start,stop} functions in
> fs/ext4/ext4_jbd2.c.

I could definitely appreciated some help here. The call paths are rather
complex and I am not familiar with the code enough. On of the biggest
problem I have currently is that there doesn't seem to be an easy place
to store the old allocation context. The original patch had it inside
the journal handle. I was thinking about putting it into superblock but
ext4_journal_stop doesn't seem to have access to the sb if there is no
handle. Now, if ext4_journal_start is never called from a nested context
then this is not a big deal but there are just too many caller to
check...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
