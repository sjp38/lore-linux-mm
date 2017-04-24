Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC1CE6B0311
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:56:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m22so15826729pgc.4
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:56:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si19203432plk.256.2017.04.24.08.56.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 08:56:17 -0700 (PDT)
Date: Mon, 24 Apr 2017 17:56:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 08/20] mm: ensure that we set mapping error if
 writeout() fails
Message-ID: <20170424155614.GI23988@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
 <20170424132259.8680-9-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424132259.8680-9-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon 24-04-17 09:22:47, Jeff Layton wrote:
> If writepage fails during a page migration, then we need to ensure that
> fsync will see it by flagging the mapping.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> ---
>  mm/migrate.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 738f1d5f8350..3a59830bdae2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -792,7 +792,11 @@ static int writeout(struct address_space *mapping, struct page *page)
>  		/* unlocked. Relock */
>  		lock_page(page);
>  
> -	return (rc < 0) ? -EIO : -EAGAIN;
> +	if (rc < 0) {
> +		mapping_set_error(mapping, rc);
> +		return -EIO;
> +	}
> +	return -EAGAIN;
>  }
>  
>  /*
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
