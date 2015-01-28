Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D11C96B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:03:50 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so26202002pad.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:03:50 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fc9si90233pac.115.2015.01.28.07.03.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 07:03:50 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so26178267pad.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:03:49 -0800 (PST)
Date: Thu, 29 Jan 2015 00:04:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150128150424.GC965@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128145651.GB965@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, sergey.senozhatsky.work@gmail.com

On (01/28/15 23:56), Sergey Senozhatsky wrote:
> > -static inline int init_done(struct zram *zram)
> > +static inline bool init_done(struct zram *zram)
> >  {
> > -	return zram->meta != NULL;
> > +	/*
> > +	 * init_done can be used without holding zram->init_lock in
> > +	 * read/write handler(ie, zram_make_request) but we should make sure
> > +	 * that zram->init_done should set up after meta initialization is
> > +	 * done. Look at setup_init_done.
> > +	 */
> > +	bool ret = zram->init_done;
> 
> I don't like re-introduced ->init_done.
> another idea... how about using `zram->disksize == 0' instead of
> `->init_done' (previously `->meta != NULL')? should do the trick.
> 

a typo, I meant `->disksize != 0'.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
