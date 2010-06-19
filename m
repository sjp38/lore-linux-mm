Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ED74A6B01B2
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 06:45:01 -0400 (EDT)
Date: Sat, 19 Jun 2010 12:44:39 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] writeback: Creating /sys/kernel/mm/writeback/writeback
Message-ID: <20100619104439.GA7659@lst.de>
References: <1276907415-504-1-git-send-email-mrubin@google.com> <1276907415-504-2-git-send-email-mrubin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276907415-504-2-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 05:30:13PM -0700, Michael Rubin wrote:
> Adding the /sys/kernel/mm/writeback/writeback file.  It contains data
> to help developers and applications gain visibility into writeback
> behaviour.
> 
>     # cat /sys/kernel/mm/writeback/writeback
>     pages_dirtied:    3747
>     pages_cleaned:    3618
>     dirty_threshold:  816673
>     bg_threshold:     408336

I'm fine with exposting this. but the interface is rather awkward.
These kinds of multiple value per file interface require addition
parsing and are a pain to extend.  Please do something like

/proc/sys/vm/writeback/

			pages_dirtied
			pages_cleaned
			dirty_threshold
			background_threshold

where you can just read the value from the file.

> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index c920164..84b0181 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -1598,8 +1598,10 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
>  	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
>  	kunmap_atomic(kaddr, KM_USER0);
>  
> -	if (!TestSetPageWriteback(clone_page))
> +	if (!TestSetPageWriteback(clone_page)) {
>  		inc_zone_page_state(clone_page, NR_WRITEBACK);
> +		inc_zone_page_state(clone_page, NR_PAGES_ENTERED_WRITEBACK);
> +	}
>  	unlock_page(clone_page);

I'm not very happy about having this opencoded in a filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
