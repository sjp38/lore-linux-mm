Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6EFA6B02F2
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:54:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t7so15665420pgt.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:54:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x20si19432325pge.143.2017.04.24.08.54.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 08:54:20 -0700 (PDT)
Date: Mon, 24 Apr 2017 17:54:16 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 06/20] dax: set errors in mapping when writeback fails
Message-ID: <20170424155416.GH23988@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
 <20170424132259.8680-7-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424132259.8680-7-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon 24-04-17 09:22:45, Jeff Layton wrote:
> In order to get proper error codes from fsync, we must set an error in
> the mapping range when writeback fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

So I'm fine with the change but please expand the changelog to something
like:

DAX currently doesn't set errors in the mapping when cache flushing fails
in dax_writeback_mapping_range(). Since this function can get called only
from fsync(2) or sync(2), this is actually as good as it can currently get
since we correctly propagate the error up from dax_writeback_mapping_range()
to filemap_fdatawrite(). However in the future better writeback error
handling will enable us to properly report these errors on fsync(2) even if
there are multiple file descriptors open against the file or if sync(2)
gets called before fsync(2). So convert DAX to using standard error
reporting through the mapping.

After improving the changelog you can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 85abd741253d..9b6b04030c3f 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -901,8 +901,10 @@ int dax_writeback_mapping_range(struct address_space *mapping,
>  
>  			ret = dax_writeback_one(bdev, mapping, indices[i],
>  					pvec.pages[i]);
> -			if (ret < 0)
> +			if (ret < 0) {
> +				mapping_set_error(mapping, ret);
>  				return ret;
> +			}
>  		}
>  	}
>  	return 0;
> -- 
> 2.9.3
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
