Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4E646B0315
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 15:16:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j16so16954922pfk.4
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:16:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 1si4036813ply.290.2017.04.24.12.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 12:16:06 -0700 (PDT)
Date: Mon, 24 Apr 2017 13:16:04 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 06/20] dax: set errors in mapping when writeback fails
Message-ID: <20170424191604.GA2884@linux.intel.com>
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

On Mon, Apr 24, 2017 at 09:22:45AM -0400, Jeff Layton wrote:
> In order to get proper error codes from fsync, we must set an error in
> the mapping range when writeback fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Works fine in some error injection testing.

Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
