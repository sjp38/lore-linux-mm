Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1849C828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 00:03:02 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id t15so4366721igr.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:03:02 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id qe5si1969805igb.89.2016.01.14.21.03.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 21:03:01 -0800 (PST)
Date: Fri, 15 Jan 2016 14:05:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115050510.GC11203@bbox>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox>
MIME-Version: 1.0
In-Reply-To: <20160115023518.GA10843@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junil Lee <junil0814.lee@lge.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 15, 2016 at 11:35:18AM +0900, Minchan Kim wrote:
> Hi Junil,
> 
> On Fri, Jan 15, 2016 at 09:36:24AM +0900, Junil Lee wrote:
> > To prevent unlock at the not correct situation, tagging the new obj to
> > assure lock in migrate_zspage() before right unlock path.
> > 
> > Two functions are in race condition by tag which set 1 on last bit of
> > obj, however unlock succrently when update new obj to handle before call
> > unpin_tag() which is right unlock path.
> > 
> > summarize this problem by call flow as below:
> > 
> > 		CPU0								CPU1
> > migrate_zspage
> > find_alloced_obj()
> > 	trypin_tag() -- obj |= HANDLE_PIN_BIT
> > obj_malloc() -- new obj is not set			zs_free
> > record_obj() -- unlock and break sync		pin_tag() -- get lock
> > unpin_tag()
> 
> It's really good catch!
> I think it should be stable material. For that, we should know this
> patch fixes what kinds of problem.
> 
> What do you see problem? I mean please write down the oops you saw and
> verify that the patch fixes your problem. :)
> 
> Minor nit below
> 
> > 
> > Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> > ---
> >  mm/zsmalloc.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index e7414ce..bb459ef 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1635,6 +1635,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> >  		free_obj = obj_malloc(d_page, class, handle);
> >  		zs_object_copy(free_obj, used_obj, class);
> >  		index++;
> > +		free_obj |= BIT(HANDLE_PIN_BIT);
> >  		record_obj(handle, free_obj);
> 
> I think record_obj should store free_obj to *handle with masking off least bit.
> IOW, how about this?
> 
> record_obj(handle, obj)
> {
>         *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);
> }
> 
> Thanks a lot!

Junil, as you pointed out in private mail, my code was broken.
I just wanted to make code more robust but it can add unnecessary
overhead in zsmalloc path although it would be minor so let's
go with your patch but please add comment why we need it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
