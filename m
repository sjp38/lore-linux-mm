Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9643E6B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 19:37:20 -0500 (EST)
Date: Wed, 30 Nov 2011 08:37:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 8/9] readahead: basic support for backwards prefetching
Message-ID: <20111130003716.GA11147@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.925952168@intel.com>
 <20111129153552.GP5635@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129153552.GP5635@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Li, Shaohua" <shaohua.li@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(snip)
> > @@ -676,6 +677,20 @@ ondemand_readahead(struct address_space 
> >  	}
> >  
> >  	/*
> > +	 * backwards reading
> > +	 */
> > +	if (offset < ra->start && offset + req_size >= ra->start) {
> > +		ra->pattern = RA_PATTERN_BACKWARDS;
> > +		ra->size = get_next_ra_size(ra, max);
> > +		max = ra->start;
> > +		if (ra->size > max)
> > +			ra->size = max;
> > +		ra->async_size = 0;
> > +		ra->start -= ra->size;
>   IMHO much more obvious way to write this is:
> ra->size = get_next_ra_size(ra, max);
> if (ra->size > ra->start) {
>   ra->size = ra->start;
>   ra->start = 0;
> } else
>   ra->start -= ra->size;

Good idea! Here is the updated code:

        /*
         * backwards reading
         */
        if (offset < ra->start && offset + req_size >= ra->start) {
                ra->pattern = RA_PATTERN_BACKWARDS;
                ra->size = get_next_ra_size(ra, max);
                if (ra->size > ra->start) {
                        /*
                         * ra->start may be concurrently set to some huge
                         * value, the min() at least avoids submitting huge IO
                         * in this race condition
                         */
                        ra->size = min(ra->start, max);
                        ra->start = 0;
                } else
                        ra->start -= ra->size;
                ra->async_size = 0;
                goto readit;
        }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
