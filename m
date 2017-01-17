Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11C956B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:56:17 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id v73so162621301ywg.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 18:56:17 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id f139si6392926ywb.262.2017.01.16.18.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 18:56:16 -0800 (PST)
Date: Mon, 16 Jan 2017 21:56:07 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20170117025607.frrcdbduthhutrzj@thunk.org>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-9-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106141107.23953-9-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Jan 06, 2017 at 03:11:07PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts commit 216553c4b7f3e3e2beb4981cddca9b2027523928. Now that
> the transaction context uses memalloc_nofs_save and all allocations
> within the this context inherit GFP_NOFS automatically, there is no
> reason to mark specific allocations explicitly.
> 
> This patch should not introduce any functional change. The main point
> of this change is to reduce explicit GFP_NOFS usage inside ext4 code
> to make the review of the remaining usage easier.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

Changes in the jbd2 layer aren't going to guarantee that
memalloc_nofs_save() will be executed if we are running ext4 without a
journal (aka in no journal mode).  And this is a *very* common
configuration; it's how ext4 is used inside Google in our production
servers.

So that means the earlier patches will probably need to be changed so
the nOFS scope is done in the ext4_journal_{start,stop} functions in
fs/ext4/ext4_jbd2.c.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
