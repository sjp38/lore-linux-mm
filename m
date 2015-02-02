Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB3816B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 22:47:32 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so76846712pad.4
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:47:32 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id wq4si22155026pab.92.2015.02.01.19.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 19:47:32 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so76898811pad.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:47:31 -0800 (PST)
Date: Mon, 2 Feb 2015 12:47:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202034730.GD6977@swordfish>
References: <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150201150416.GB1290@swordfish>
 <20150202014315.GC6402@blaptop>
 <20150202015940.GB6977@swordfish>
 <20150202024550.GE6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202024550.GE6402@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/02/15 11:45), Minchan Kim wrote:
> On Mon, Feb 02, 2015 at 10:59:40AM +0900, Sergey Senozhatsky wrote:
> > On (02/02/15 10:43), Minchan Kim wrote:
> > > >  static inline int init_done(struct zram *zram)
> > > >  {
> > > > -	return zram->meta != NULL;
> > > > +	return atomic_read(&zram->refcount);
> > > 
> > > As I said previous mail, it could make livelock so I want to use disksize
> > > in here to prevent further I/O handling.
> > 
> > just as I said in my previous email -- is this live lock really possible?
> > we need to umount device to continue with reset. and umount will kill IOs out
> > of our way.
> > 
> > the other reset caller is  __exit zram_exit(). but once again, I don't
> > expect this function being executed on mounted device and module being
> > in use.
> > 
> > 
> > > > +static inline void zram_put(struct zram *zram)
> > > > +{
> > > > +	if (atomic_dec_and_test(&zram->refcount))
> > > > +		complete(&zram->io_done);
> > > > +}
> > > 
> > > Although I suggested this complete, it might be rather overkill(pz,
> > > understand me it was work in midnight. :))
> > > Instead, we could use just atomic_dec in here and
> > > use wait_event(event, atomic_read(&zram->refcount) == 0) in reset.
> > > 
> > 
> > yes, I think it can do the trick.
> 
> Hey, it's not a trick. It suits for the our goal well. Completion
> was too much, I think.
> 

sure :)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
