Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F28A6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 18:28:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so25407050pfj.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 15:28:30 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id b5si23407ple.343.2017.09.27.15.28.28
        for <linux-mm@kvack.org>;
        Wed, 27 Sep 2017 15:28:29 -0700 (PDT)
Date: Thu, 28 Sep 2017 08:19:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 10/15] mm: Use pagevec_lookup_range_tag() in
 __filemap_fdatawait_range()
Message-ID: <20170927221902.GG10621@dastard>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-11-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927160334.29513-11-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Sep 27, 2017 at 06:03:29PM +0200, Jan Kara wrote:
> Use pagevec_lookup_range_tag() in __filemap_fdatawait_range() as it is
> interested only in pages from given range. Remove unnecessary code
> resulting from this.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/filemap.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index fe20329c83cd..479fc54b7cd1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -421,18 +421,13 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
>  
>  	pagevec_init(&pvec, 0);
>  	while ((index <= end) &&
> -			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> -			PAGECACHE_TAG_WRITEBACK,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
> +			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
> +			&index, end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE))) {

While touching this, can we clean this up by moving the lookup
outside the while condition? i.e:

	while (index <= end) {
		unsigned i;

		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
				end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE);
		if (!nr_pages)
			break;

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
