Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8CC486B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 07:29:58 -0500 (EST)
Date: Tue, 29 Nov 2011 20:29:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-ID: <20111129122951.GA17432@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.636765408@intel.com>
 <20111121152958.e4fd76d4.akpm@linux-foundation.org>
 <20111129032323.GC19506@localhost>
 <20111128204950.29404d0b.akpm@linux-foundation.org>
 <20111129064109.GA8612@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129064109.GA8612@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

>  int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  		pgoff_t offset, unsigned long nr_to_read)
>  {
> +	struct file_ra_state fadvice_ra = {
> +		.pattern	= RA_PATTERN_FADVISE,
> +	};
>  	int ret = 0;
>  
>  	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
> @@ -222,8 +397,9 @@ int force_page_cache_readahead(struct ad
>  
>  		if (this_chunk > nr_to_read)
>  			this_chunk = nr_to_read;
> -		err = __do_page_cache_readahead(mapping, filp,
> -						offset, this_chunk, 0);
> +		fadvice_ra.start = offset;
> +		fadvice_ra.size = this_chunk;
> +		err = ra_submit(&fadvice_ra, mapping, filp, offset, nr_to_read);
>  		if (err < 0) {
>  			ret = err;
>  			break;

It looks that we can safely use filp->f_ra:

@@ -214,6 +386,7 @@ int force_page_cache_readahead(struct ad
        if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
                return -EINVAL;

+       filp->f_ra.pattern = RA_PATTERN_FADVISE;
        nr_to_read = max_sane_readahead(nr_to_read);
        while (nr_to_read) {
                int err;
@@ -222,8 +395,9 @@ int force_page_cache_readahead(struct ad
               
                if (this_chunk > nr_to_read)
                        this_chunk = nr_to_read;
-               err = __do_page_cache_readahead(mapping, filp,
-                                               offset, this_chunk, 0);
+               filp->f_ra.start = offset;
+               filp->f_ra.size = this_chunk;
+               err = ra_submit(&filp->f_ra, mapping, filp, offset, nr_to_read);
                if (err < 0) {
                        ret = err;
                        break;

But still, it adds one more function call to the fadvise path.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
