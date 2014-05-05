Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 771596B00C2
	for <linux-mm@kvack.org>; Mon,  5 May 2014 16:46:18 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so1981924pdj.11
        for <linux-mm@kvack.org>; Mon, 05 May 2014 13:46:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ke1si9664207pad.460.2014.05.05.13.46.16
        for <linux-mm@kvack.org>;
        Mon, 05 May 2014 13:46:17 -0700 (PDT)
Date: Mon, 5 May 2014 13:46:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
Message-Id: <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
In-Reply-To: <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
	<20140505152014.GA8551@cerebellum.variantweb.net>
	<1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Weijie Yang <weijie.yang@samsung.com>, 'Minchan Kim' <minchan@kernel.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, weijie.yang.kh@gmail.com, heesub.shin@samsung.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, 05 May 2014 11:00:44 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> > > @@ -339,12 +338,14 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> > >  	unsigned long handle;
> > >  	u16 size;
> > >  
> > > -	read_lock(&meta->tb_lock);
> > > +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> > > +		cpu_relax();
> > > +
> > 
> > So... this might be dumb question, but this looks like a spinlock
> > implementation.
> > 
> > What advantage does this have over a standard spinlock?
> 
> I was wondering the same thing. Furthermore by doing this you'll loose
> the benefits of sharing the lock... your numbers do indicate that it is
> for the better. Also, note that hopefully rwlock_t will soon be updated
> to be fair and perform up to par with spinlocks, something which is long
> overdue. So you could reduce the critical region by implementing the
> same granularity, just don't implement your own locking schemes, like
> this.

It sounds like seqlocks will match this access pattern pretty well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
