Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19C446B025E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 10:59:24 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id j82so179625297ybg.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 07:59:24 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a68si6964248ywf.0.2017.01.17.07.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 07:59:23 -0800 (PST)
Date: Tue, 17 Jan 2017 10:59:16 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170117155916.dcizr65bwa6behe7@thunk.org>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
 <20170117025607.frrcdbduthhutrzj@thunk.org>
 <20170117082425.GD19699@dhcp22.suse.cz>
 <20170117151817.GR19699@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117151817.GR19699@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 17, 2017 at 04:18:17PM +0100, Michal Hocko wrote:
> 
> OK, so I've been staring into the code and AFAIU current->journal_info
> can contain my stored information. I could either hijack part of the
> word as the ref counting is only consuming low 12b. But that looks too
> ugly to live. Or I can allocate some placeholder.

Yeah, I was looking at something similar.  Can you guarantee that the
context will only take one or two bits?  (Looks like it only needs one
bit ATM, even though at the moment you're storing the whole GFP mask,
correct?)

> But before going to play with that I am really wondering whether we need
> all this with no journal at all. AFAIU what Jack told me it is the
> journal lock(s) which is the biggest problem from the reclaim recursion
> point of view. What would cause a deadlock in no journal mode?

We still have the original problem for why we need GFP_NOFS even in
ext2.  If we are in a writeback path, and we need to allocate memory,
we don't want to recurse back into the file system's writeback path.
Certainly not for the same inode, and while we could make it work if
the mm was writing back another inode, or another superblock, there
are also stack depth considerations that would make this be a bad
idea.  So we do need to be able to assert GFP_NOFS even in no journal
mode, and for any file system including ext2, for that matter.

Because of the fact that we're going to have to play games with
current->journal_info, maybe this is something that I should take
responsibility for, and to go through the the ext4 tree after the main
patch series go through?  Maybe you could use xfs and ext2 as sample
(simple) implementations?

My only ask is that the memalloc nofs context be a well defined N
bits, where N < 16, and I'll find some place to put them (probably
journal_info).

Thanks,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
