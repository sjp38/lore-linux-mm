Received: by py-out-1112.google.com with SMTP id f47so2706630pye.20
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 09:05:13 -0700 (PDT)
Message-ID: <87a5b0800803240905g705a8ea3p11c415ad37fc3cbb@mail.gmail.com>
Date: Mon, 24 Mar 2008 16:05:12 +0000
From: "Will Newton" <will.newton@gmail.com>
Subject: Re: [PATCH 2/6] compcache: block device - internal defs
In-Reply-To: <200803242033.30782.nitingupta910@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803242033.30782.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nitingupta910@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 3:03 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:

Hi Nitin,

> This contains header to be used internally by block device code.
>  It contains flags to enable/disable debugging, stats collection and also
>  defines default disk size (25% of total RAM).
>
>  Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
>  ---
>   drivers/block/compcache.h |  147 +++++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 147 insertions(+), 0 deletions(-)
>
>  diff --git a/drivers/block/compcache.h b/drivers/block/compcache.h
>  new file mode 100644
>  index 0000000..b84b5d3
>  --- /dev/null
>  +++ b/drivers/block/compcache.h
>  @@ -0,0 +1,147 @@
>  +/*
>  + * Compressed RAM based swap device
>  + *
>  + * (C) Nitin Gupta
>  + *
>  + * This RAM based block device acts as swap disk.
>  + * Pages swapped to this device are compressed and
>  + * stored in memory.
>  + *
>  + * Project home: http://code.google.com/p/compcache
>  + */
>  +
>  +#ifndef _COMPCACHE_H_
>  +#define _COMPCACHE_H_
>  +
>  +#define K(x)   ((x) >> 10)
>  +#define KB(x)  ((x) << 10)
>  +
>  +#define SECTOR_SHIFT           9
>  +#define SECTOR_SIZE            (1 << SECTOR_SHIFT)
>  +#define SECTORS_PER_PAGE_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
>  +#define SECTORS_PER_PAGE       (1 << SECTORS_PER_PAGE_SHIFT)
>  +
>  +/*-- Configurable parameters */
>  +/* Default compcache size: 25% of total RAM */
>  +#define DEFAULT_COMPCACHE_PERCENT      25
>  +#define INIT_SIZE                      KB(16)
>  +#define GROW_SIZE                      INIT_SIZE

Maybe these could be renamed to INIT_SIZE_BYTES/GROW_SIZE_BYTES to
make the units clearer?

>  +/*-- */
>  +
>  +/* Message prefix */
>  +#define C "compcache: "
>  +
>  +/* Debugging and Stats */
>  +#define NOP    do { } while(0)
>  +
>  +#if (1 || defined(CONFIG_DEBUG_COMPCACHE))
>  +#define DEBUG  1
>  +#define STATS  1
>  +#else
>  +#define DEBUG  0
>  +#define STATS  0
>  +#endif

If DEBUG is defined unconditionally what is the point of CONFIG_DEBUG_COMPCACHE?

>  +
>  +/* Create /proc/compcache? */
>  +/* If STATS is disabled, this will give minimal compcache info */
>  +#define CONFIG_COMPCACHE_PROC
>  +
>  +#if DEBUG
>  +#define CC_DEBUG(fmt,arg...) \
>  +       printk(KERN_DEBUG C fmt,##arg)
>  +#else
>  +#define CC_DEBUG(fmt,arg...) NOP
>  +#endif

Have you thought about using pr_debug() for this? It looks like it
would simplify this file at the cost of a little flexibility.

>  +
>  +/*
>  + * Verbose debugging:
>  + * Enable basic debugging + verbose messages spread all over code
>  + */
>  +#define DEBUG2 0
>  +
>  +#if DEBUG2
>  +#define DEBUG  1
>  +#define STATS  1
>  +#define CONFIG_COMPCACHE_PROC  1
>  +#define CC_DEBUG2((fmt,arg...) \
>  +       printk(KERN_DEBUG C fmt,##arg)
>  +#else /* DEBUG2 */
>  +#define CC_DEBUG2(fmt,arg...) NOP
>  +#endif
>  +
>  +/* Its useless to collect stats if there is no way to export it */
>  +#if (STATS && !defined(CONFIG_COMPCACHE_PROC))
>  +#error "compcache stats is enabled but not /proc/compcache."
>  +#endif

So it appears that if we want DEBUG we also get STATS, which requires
/proc support enabled, so it is impossible to have just DEBUG and no
STATS or /proc support?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
