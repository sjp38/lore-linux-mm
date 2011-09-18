Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2556C9000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 10:47:58 -0400 (EDT)
Date: Sun, 18 Sep 2011 22:47:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110918144751.GA18645@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
 <20110918143721.GA17240@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110918143721.GA17240@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> BTW, I also compared the IO-less patchset and the vanilla kernel's
> JBOD performance. Basically, the performance is lightly improved
> under large memory, and reduced a lot in small memory servers.
> 
>  vanillla IO-less  
> --------------------------------------------------------------------------------
[...]
>  26508063 17706200      -33.2%  JBOD-10HDD-thresh=100M/xfs-100dd-1M-16p-5895M-100M
>  23767810 23374918       -1.7%  JBOD-10HDD-thresh=100M/xfs-10dd-1M-16p-5895M-100M
>  28032891 20659278      -26.3%  JBOD-10HDD-thresh=100M/xfs-1dd-1M-16p-5895M-100M
>  26049973 22517497      -13.6%  JBOD-10HDD-thresh=100M/xfs-2dd-1M-16p-5895M-100M
> 
> There are still some itches in JBOD..

OK, in the dirty_bytes=100M case, I find that the bdi threshold _and_
writeout bandwidth may drop close to 0 in long periods. This change
may avoid one bdi being stuck:

        /*
         * bdi reserve area, safeguard against dirty pool underrun and disk idle
         *
         * It may push the desired control point of global dirty pages higher
         * than setpoint. It's not necessary in single-bdi case because a
         * minimal pool of @freerun dirty pages will already be guaranteed.
         */
-       x_intercept = min(write_bw, freerun);
+       x_intercept = min(write_bw + MIN_WRITEBACK_PAGES, freerun);
        if (bdi_dirty < x_intercept) {
                if (bdi_dirty > x_intercept / 8) {
                        pos_ratio *= x_intercept;
                        do_div(pos_ratio, bdi_dirty);
                } else
                        pos_ratio *= 8;
        }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
