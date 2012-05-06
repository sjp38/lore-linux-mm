Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 31D026B0044
	for <linux-mm@kvack.org>; Sun,  6 May 2012 19:31:28 -0400 (EDT)
Date: Mon, 7 May 2012 09:31:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Message-ID: <20120506233117.GU5091@dastard>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-2-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336054995-22988-2-git-send-email-svenkatr@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Venkatraman S <svenkatr@ti.com>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Thu, May 03, 2012 at 07:53:00PM +0530, Venkatraman S wrote:
> From: Ilan Smith <ilan.smith@sandisk.com>
> 
> Add attribute to identify demand paging requests.
> Mark readpages with demand paging attribute.
> 
> Signed-off-by: Ilan Smith <ilan.smith@sandisk.com>
> Signed-off-by: Alex Lemberg <alex.lemberg@sandisk.com>
> Signed-off-by: Venkatraman S <svenkatr@ti.com>
> ---
>  fs/mpage.c                |    2 ++
>  include/linux/bio.h       |    7 +++++++
>  include/linux/blk_types.h |    2 ++
>  3 files changed, 11 insertions(+)
> 
> diff --git a/fs/mpage.c b/fs/mpage.c
> index 0face1c..8b144f5 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -386,6 +386,8 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
>  					&last_block_in_bio, &map_bh,
>  					&first_logical_block,
>  					get_block);
> +			if (bio)
> +				bio->bi_rw |= REQ_RW_DMPG;

Have you thought about the potential for DOSing a machine
with this? That is, user data reads can now preempt writes of any
kind, effectively stalling writeback and memory reclaim which will
lead to OOM situations. Or, alternatively, journal flushing will get
stalled and no new modifications can take place until the read
stream stops.

This really seems like functionality that belongs in an IO
scheduler so that write starvation can be avoided, not in high-level
data read paths where we have no clue about anything else going on
in the IO subsystem....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
