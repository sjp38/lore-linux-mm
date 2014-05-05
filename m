Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 019246B00CC
	for <linux-mm@kvack.org>; Mon,  5 May 2014 18:22:33 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id va2so6400731obc.25
        for <linux-mm@kvack.org>; Mon, 05 May 2014 15:22:33 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id v1si7233147obz.61.2014.05.05.15.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 May 2014 15:22:33 -0700 (PDT)
Message-ID: <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 05 May 2014 15:22:30 -0700
In-Reply-To: <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
	 <20140505152014.GA8551@cerebellum.variantweb.net>
	 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
	 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Weijie Yang <weijie.yang@samsung.com>, 'Minchan Kim' <minchan@kernel.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, weijie.yang.kh@gmail.com, heesub.shin@samsung.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, 2014-05-05 at 13:46 -0700, Andrew Morton wrote:
> On Mon, 05 May 2014 11:00:44 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > > > @@ -339,12 +338,14 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> > > >  	unsigned long handle;
> > > >  	u16 size;
> > > >  
> > > > -	read_lock(&meta->tb_lock);
> > > > +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> > > > +		cpu_relax();
> > > > +
> > > 
> > > So... this might be dumb question, but this looks like a spinlock
> > > implementation.
> > > 
> > > What advantage does this have over a standard spinlock?
> > 
> > I was wondering the same thing. Furthermore by doing this you'll loose
> > the benefits of sharing the lock... your numbers do indicate that it is
> > for the better. Also, note that hopefully rwlock_t will soon be updated
> > to be fair and perform up to par with spinlocks, something which is long
> > overdue. So you could reduce the critical region by implementing the
> > same granularity, just don't implement your own locking schemes, like
> > this.
> 
> It sounds like seqlocks will match this access pattern pretty well?

Indeed. And after a closer look, except for zram_slot_free_notify(),
that lock is always shared. So, unless fine graining it implies taking
the lock exclusively like in this patch (if so, that needs to be
explicitly documented in the changelog), we would ideally continue to
share it. That _should_ provide nicer performance numbers when using the
correct lock.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
