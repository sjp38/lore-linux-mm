Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 354976B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:06:38 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id z69so3494138ita.0
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 07:06:38 -0800 (PST)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id o191si2333713iod.278.2017.11.17.07.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Nov 2017 07:06:35 -0800 (PST)
Date: Fri, 17 Nov 2017 23:06:04 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: [PATCH v2 2/3] bdi: add error handle for bdi_debug_register
Message-ID: <20171117150604.GA21325@localhost.didichuxing.com>
References: <cover.1509415695.git.zhangweiping@didichuxing.com>
 <100ecef9a09dc2a95feb5f6fac21c8bfa26be4eb.1509415695.git.zhangweiping@didichuxing.com>
 <20171101134722.GB28572@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171101134722.GB28572@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, Jan Kara <jack@suse.cz>
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 01, 2017 at 02:47:22PM +0100, Jan Kara wrote:
> On Tue 31-10-17 18:38:24, weiping zhang wrote:
> > In order to make error handle more cleaner we call bdi_debug_register
> > before set state to WB_registered, that we can avoid call bdi_unregister
> > in release_bdi().
> > 
> > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> 
> Looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> 								Honza
> 
> > ---
> >  mm/backing-dev.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index b5f940ce0143..84b2dc76f140 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -882,10 +882,13 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
> >  	if (IS_ERR(dev))
> >  		return PTR_ERR(dev);
> >  
> > +	if (bdi_debug_register(bdi, dev_name(dev))) {
> > +		device_destroy(bdi_class, dev->devt);
> > +		return -ENOMEM;
> > +	}
> >  	cgwb_bdi_register(bdi);
> >  	bdi->dev = dev;
> >  
> > -	bdi_debug_register(bdi, dev_name(dev));
> >  	set_bit(WB_registered, &bdi->wb.state);
> >  
> >  	spin_lock_bh(&bdi_lock);
> > -- 

Hello Jens,

Could you please give some comments for this series cleanup.

--
Thanks
weiping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
