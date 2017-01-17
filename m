Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D35D26B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:01:20 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id u68so162262075ywg.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:01:20 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id b7si6417158ywa.364.2017.01.16.19.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 19:01:20 -0800 (PST)
Date: Mon, 16 Jan 2017 22:01:18 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 7/8] Revert "ext4: avoid deadlocks in the writeback path
 by using sb_getblk_gfp"
Message-ID: <20170117030118.727jqyamjhojzajb@thunk.org>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-8-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106141107.23953-8-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Jan 06, 2017 at 03:11:06PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts commit c45653c341f5c8a0ce19c8f0ad4678640849cb86 because
> sb_getblk_gfp is not really needed as
> sb_getblk
>   __getblk_gfp
>     __getblk_slow
>       grow_buffers
>         grow_dev_page
> 	  gfp_mask = mapping_gfp_constraint(inode->i_mapping, ~__GFP_FS) | gfp
> 
> so __GFP_FS is cleared unconditionally and therefore the above commit
> didn't have any real effect in fact.
> 
> This patch should not introduce any functional change. The main point
> of this change is to reduce explicit GFP_NOFS usage inside ext4 code to
> make the review of the remaining usage easier.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

If I'm not mistaken, this patch is not dependent on any of the other
patches in this series (and the other patches are not dependent on
this one).  Hence, I could take this patch via the ext4 tree, correct?

     	    	     	   	     - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
