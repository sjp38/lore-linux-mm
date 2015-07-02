Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 19C099003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 10:25:57 -0400 (EDT)
Received: by ykfy125 with SMTP id y125so69610660ykf.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 07:25:56 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id x203si4023644ykx.80.2015.07.02.07.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 07:25:56 -0700 (PDT)
Date: Thu, 2 Jul 2015 10:25:51 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
Message-ID: <20150702142551.GB9456@thunk.org>
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz>
 <20150701061731.GB6286@dhcp22.suse.cz>
 <20150701133715.GA6287@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701133715.GA6287@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Marian Marinov <mm@1h.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

On Wed, Jul 01, 2015 at 03:37:15PM +0200, Michal Hocko wrote:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 37e90db1520b..6c44d424968e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -995,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  
>  			/* Case 3 above */
> -			} else {
> +			} else if (sc->gfp_mask & __GFP_FS) {
>  				wait_on_page_writeback(page);
>  			}
>  		}

Um, I've just taken a closer look at this code now that I'm back from
vacation, and I'm not sure this is right.  This Case 3 code occurs
inside an

	if (PageWriteback(page)) {
	    ...
	}

conditional, and if I'm not mistaken, if the flow of control exits
this conditional, it is assumed that the page is *not* under writeback.
This patch will assume the page has been cleaned if __GFP_FS is set,
which could lead to a dirty page getting dropped, so I believe this is
a bug.  No?

It would seem to me that a better fix would be to change the Case 2
handling:

			/* Case 2 above */
			} else if (global_reclaim(sc) ||
-			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
+			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_FS)) {
				/*
				 * This is slightly racy - end_page_writeback()
				 * might have just cleared PageReclaim, then
				 * setting PageReclaim here end up interpreted
				 * as PageReadahead - but that does not matter
				 * enough to care.  What we do want is for this
				 * page to have PageReclaim set next time memcg
				 * reclaim reaches the tests above, so it will
				 * then wait_on_page_writeback() to avoid OOM;
				 * and it's also appropriate in global reclaim.
				 */
				SetPageReclaim(page);
				nr_writeback++;

				goto keep_locked;


Am I missing something?

							- Ted
							

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
