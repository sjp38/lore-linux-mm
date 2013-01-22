Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 82C216B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 10:20:29 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz10so4128395pad.9
        for <linux-mm@kvack.org>; Tue, 22 Jan 2013 07:20:28 -0800 (PST)
Date: Wed, 23 Jan 2013 00:20:20 +0900
From: Minchan Kim <minchan.kernel.2@gmail.com>
Subject: Re: [PATCH v4 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130122151808.GA3757@blaptop>
References: <1358813253-20913-1-git-send-email-minchan@kernel.org>
 <50FE6025.2080609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FE6025.2080609@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Jan 22, 2013 at 10:47:17AM +0100, Jerome Marchand wrote:
> On 01/22/2013 01:07 AM, Minchan Kim wrote:
> > Now zram allocates new page with GFP_KERNEL in zram I/O path
> > if IO is partial. Unfortunately, It may cuase deadlock with
> > reclaim path so this patch solves the problem.
> > 
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Jerome Marchand <jmarchan@redhat.com>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> > 
> > We could use GFP_IO instead of GFP_ATOMIC in zram_bvec_read with
> > some modification related to buffer allocation in case of partial IO.
> > But it needs more churn and prevent merge this patch into stable
> > if we should send this to stable so I'd like to keep it as simple
> > as possbile. GFP_IO usage could be separate patch after we merge it.
> > Thanks.
> 
> I'd rather have a preallocated buffer for that. It would make
> zram_bvec_read/write() simpler (no need to deal with an allocation
> failure or to free the buffer) and it would be consistent with the way
> other similar buffer works (compress_workmem/buffer).

Consistent? Other buffers are MUST for zram working while the buffer
for partial I/O is supplement. Although partial I/O might be common in your config,
it doesn't match with my usecase. I didn't see any partial IO in my usecase.
Nontheless, why should I pay free 4K? Because of just making code SIMPLE?
I don't think current alloc/free handling about partial I/O is mess at the cost
of 4K. And we could use a few zram(a swap and a 2-compressed tmpfs) in system
so the cost is n*4K. Please keep in mind that ZRAM's goal is memory efficiency
and have used in many embedded system which they are always trying to save
just hundred byte.

> 
> Jerome
> 
> > 
> >  drivers/staging/zram/zram_drv.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> > index 61fb8f1..b285b3a 100644
> > --- a/drivers/staging/zram/zram_drv.c
> > +++ b/drivers/staging/zram/zram_drv.c
> > @@ -220,7 +220,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
> >  	user_mem = kmap_atomic(page);
> >  	if (is_partial_io(bvec))
> >  		/* Use  a temporary buffer to decompress the page */
> > -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +		uncmem = kmalloc(PAGE_SIZE, GFP_ATOMIC);
> >  	else
> >  		uncmem = user_mem;
> >  
> > @@ -268,7 +268,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  		 * This is a partial IO. We need to read the full page
> >  		 * before to write the changes.
> >  		 */
> > -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
> >  		if (!uncmem) {
> >  			pr_info("Error allocating temp memory!\n");
> >  			ret = -ENOMEM;
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
