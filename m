Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id E40286B00B8
	for <linux-mm@kvack.org>; Mon,  5 May 2014 14:00:48 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so2824249oag.37
        for <linux-mm@kvack.org>; Mon, 05 May 2014 11:00:48 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id pp9si6771371obc.209.2014.05.05.11.00.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 May 2014 11:00:47 -0700 (PDT)
Message-ID: <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 05 May 2014 11:00:44 -0700
In-Reply-To: <20140505152014.GA8551@cerebellum.variantweb.net>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
	 <20140505152014.GA8551@cerebellum.variantweb.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Weijie Yang <weijie.yang@samsung.com>, 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, weijie.yang.kh@gmail.com, heesub.shin@samsung.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, 2014-05-05 at 10:20 -0500, Seth Jennings wrote:
> On Mon, May 05, 2014 at 12:01:21PM +0800, Weijie Yang wrote:
> > Currently, we use a rwlock tb_lock to protect concurrent access to
> > whole zram meta table. However, according to the actual access model,
> > there is only a small chance for upper user access the same table[index],
> > so the current lock granularity is too big.
> > 
> > This patch add a atomic state for every table[index] to record its access,
> > by using CAS operation, protect concurrent access to the same table[index],
> > meanwhile allow the maximum concurrency.
> > 
> > On 64-bit system, it will not increase the meta table memory overhead, and
> > on 32-bit system with 4K page_size, it will increase about 1MB memory overhead
> > for 1GB zram. So, it is cost-efficient.
> > 
> > Test result:
> > (x86-64 Intel Core2 Q8400, system memory 4GB, Ubuntu 12.04,
> > kernel v3.15.0-rc3, zram 1GB with 4 max_comp_streams LZO,
> > take the average of 5 tests)
> > 
> > iozone -t 4 -R -r 16K -s 200M -I +Z
> > 
> >       Test          base	   lock-free	ratio
> > ------------------------------------------------------
> >  Initial write   1348017.60    1424141.62   +5.6%
> >        Rewrite   1520189.16    1652504.81   +8.7%
> >           Read   8294445.45   11404668.35   +37.5%
> >        Re-read   8134448.83   11555483.75   +42.1%
> >   Reverse Read   6748717.97    8394478.17   +24.4%
> >    Stride read   7220276.66    9372229.95   +29.8%
> >    Random read   7133010.06    9187221.90   +28.8%
> > Mixed workload   4056980.71    5843370.85   +44.0%
> >   Random write   1470106.17    1608947.04   +9.4%
> >         Pwrite   1259493.72    1311055.32   +4.1%
> >          Pread   4247583.17    4652056.11   +9.5%
> > 
> > Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> > ---
> > 
> > This patch is based on linux-next tree, commit b5c8d48bf8f42 
> > 
> >  drivers/block/zram/zram_drv.c |   41 ++++++++++++++++++++++++++---------------
> >  drivers/block/zram/zram_drv.h |    5 ++++-
> >  2 files changed, 30 insertions(+), 16 deletions(-)
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 48eccb3..8b70945
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -255,7 +255,6 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
> >  		goto free_table;
> >  	}
> >  
> > -	rwlock_init(&meta->tb_lock);
> >  	return meta;
> >  
> >  free_table:
> > @@ -339,12 +338,14 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> >  	unsigned long handle;
> >  	u16 size;
> >  
> > -	read_lock(&meta->tb_lock);
> > +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> > +		cpu_relax();
> > +
> 
> So... this might be dumb question, but this looks like a spinlock
> implementation.
> 
> What advantage does this have over a standard spinlock?

I was wondering the same thing. Furthermore by doing this you'll loose
the benefits of sharing the lock... your numbers do indicate that it is
for the better. Also, note that hopefully rwlock_t will soon be updated
to be fair and perform up to par with spinlocks, something which is long
overdue. So you could reduce the critical region by implementing the
same granularity, just don't implement your own locking schemes, like
this.

> Seth
> 
> >  	handle = meta->table[index].handle;
> >  	size = meta->table[index].size;
> >  
> >  	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> > -		read_unlock(&meta->tb_lock);
> > +		atomic_set(&meta->table[index].state, IDLE);
> >  		clear_page(mem);
> >  		return 0;
> >  	}
> > @@ -355,7 +356,7 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> >  	else
> >  		ret = zcomp_decompress(zram->comp, cmem, size, mem);
> >  	zs_unmap_object(meta->mem_pool, handle);
> > -	read_unlock(&meta->tb_lock);
> > +	atomic_set(&meta->table[index].state, IDLE);
> >  
> >  	/* Should NEVER happen. Return bio error if it does. */
> >  	if (unlikely(ret)) {
> > @@ -376,14 +377,16 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
> >  	struct zram_meta *meta = zram->meta;
> >  	page = bvec->bv_page;
> >  
> > -	read_lock(&meta->tb_lock);
> > +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> > +		cpu_relax();
> > +

So here you could reduce the amount of atomic ops and cacheline boucing
by doing a read before the CAS. It works well for our mutexes and
rwsems. Something like:

while (true) {
	if (atomic_read(&meta->table[index].state) == IDLE &&
	    atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) == IDLE)
		/* yay! lock acquired */
}

But then again, that's kind of implementing your own locking scheme...
use a standard one instead ;)

Also, instead of cpu_relax() you probably want arch_mutex_cpu_relax()
for the sake of z systems.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
