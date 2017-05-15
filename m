Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEB46B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 13:51:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g126so92266183ith.5
        for <linux-mm@kvack.org>; Mon, 15 May 2017 10:51:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 10si9539071itm.67.2017.05.15.10.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 10:51:47 -0700 (PDT)
Date: Mon, 15 May 2017 10:42:51 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [xfstests PATCH v2 2/3] ext4: allow ext4 to use $SCRATCH_LOGDEV
Message-ID: <20170515174251.GD4514@birch.djwong.org>
References: <20170509161245.29908-1-jlayton@redhat.com>
 <20170509161245.29908-3-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509161245.29908-3-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, fstests@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue, May 09, 2017 at 12:12:44PM -0400, Jeff Layton wrote:
> The writeback error handling test requires that you put the journal on a
> separate device. This allows us to use dmerror to simulate data
> writeback failure, without affecting the journal.
> 
> xfs already has infrastructure for this (a'la $SCRATCH_LOGDEV), so wire
> up the ext4 code so that it can do the same thing when _scratch_mkfs is
> called.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  common/rc | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/common/rc b/common/rc
> index 257b1903359d..8b815d9c8c33 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -675,6 +675,9 @@ _scratch_mkfs_ext4()
>  	local tmp=`mktemp`
>  	local mkfs_status
>  
> +	[ "$USE_EXTERNAL" = yes -a ! -z "$SCRATCH_LOGDEV" ] && \
> +	    $mkfs_cmd -O journal_dev $SCRATCH_LOGDEV && \
> +	    mkfs_cmd="$mkfs_cmd -J device=$SCRATCH_LOGDEV"
>  
>  	_scratch_do_mkfs "$mkfs_cmd" "$mkfs_filter" $* 2>$tmp.mkfserr 1>$tmp.mkfsstd
>  	mkfs_status=$?
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
