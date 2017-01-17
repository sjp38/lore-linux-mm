Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 018C66B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:16:26 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so17876137wjy.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:16:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f71si16463436wmf.28.2017.01.17.08.16.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 08:16:24 -0800 (PST)
Date: Tue, 17 Jan 2017 17:16:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170117161618.GT19699@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
 <20170117082425.GD19699@dhcp22.suse.cz>
 <20170117151817.GR19699@dhcp22.suse.cz>
 <20170117155916.dcizr65bwa6behe7@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117155916.dcizr65bwa6behe7@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-01-17 10:59:16, Theodore Ts'o wrote:
> On Tue, Jan 17, 2017 at 04:18:17PM +0100, Michal Hocko wrote:
> > 
> > OK, so I've been staring into the code and AFAIU current->journal_info
> > can contain my stored information. I could either hijack part of the
> > word as the ref counting is only consuming low 12b. But that looks too
> > ugly to live. Or I can allocate some placeholder.
> 
> Yeah, I was looking at something similar.  Can you guarantee that the
> context will only take one or two bits?  (Looks like it only needs one
> bit ATM, even though at the moment you're storing the whole GFP mask,
> correct?)

No, I am just storing PF_MEMALLOC_NO{FS,IO} but I assume further changes
might want to pull in more changes into the scope context.

> > But before going to play with that I am really wondering whether we need
> > all this with no journal at all. AFAIU what Jack told me it is the
> > journal lock(s) which is the biggest problem from the reclaim recursion
> > point of view. What would cause a deadlock in no journal mode?
> 
> We still have the original problem for why we need GFP_NOFS even in
> ext2.  If we are in a writeback path, and we need to allocate memory,
> we don't want to recurse back into the file system's writeback path.

But we do not enter the writeback path from the direct reclaim. Or do
you mean something other than pageout()'s mapping->a_ops->writepage?
There is only try_to_release_page where we get back to the filesystems
but I do not see any NOFS protection in ext4_releasepage.

> Certainly not for the same inode, and while we could make it work if
> the mm was writing back another inode, or another superblock, there
> are also stack depth considerations that would make this be a bad
> idea.  So we do need to be able to assert GFP_NOFS even in no journal
> mode, and for any file system including ext2, for that matter.
> 
> Because of the fact that we're going to have to play games with
> current->journal_info, maybe this is something that I should take
> responsibility for, and to go through the the ext4 tree after the main
> patch series go through?

How do you see a possibility that we would handle nojournal mode on
top of "[PATCH 5/8] jbd2: mark the transaction context with the scope
GFP_NOFS context" in a separate patch?

But anyway, I agree that we should go with the API sooner rather than
later.

>   Maybe you could use xfs and ext2 as sample
> (simple) implementations?
> 
> My only ask is that the memalloc nofs context be a well defined N
> bits, where N < 16, and I'll find some place to put them (probably
> journal_info).

I am pretty sure that we won't need more than a bit or two in a
foreseeable future (I can think of GFP_NOWAIT being one candidate).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
