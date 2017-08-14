Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0B26B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:20:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 16so126783508pgg.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:20:20 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y12si3868361pgs.202.2017.08.14.02.20.18
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 02:20:19 -0700 (PDT)
Date: Mon, 14 Aug 2017 18:20:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: schedule free_work if zspage
 is ZS_EMPTY
Message-ID: <20170814092017.GH26913@bbox>
References: <1502692486-27519-1-git-send-email-zhuhui@xiaomi.com>
 <20170814083105.GC26913@bbox>
 <CANFwon0cB3xveRD+eqLaVXhPs9uWO+Ds+a4W8R8dPU0KH28Jfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANFwon0cB3xveRD+eqLaVXhPs9uWO+Ds+a4W8R8dPU0KH28Jfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 14, 2017 at 05:11:50PM +0800, Hui Zhu wrote:
> 2017-08-14 16:31 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hi Hui,
> >
> > On Mon, Aug 14, 2017 at 02:34:46PM +0800, Hui Zhu wrote:
> >> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
> >> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
> >> can handle the ZS_EMPTY zspage.
> >>
> >> But it will affect the free_work free the zspage.  That will make this
> >> ZS_EMPTY zspage stay in system until another zspage wake up free_work.
> >>
> >> Make this patch let zs_page_migrate wake up free_work if need.
> >>
> >> Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
> >> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> >
> > This patch makes me remind why I didn't try to migrate empty zspage
> > as you did e2846124f9a2. I have forgotten it toally.
> >
> > We cannot guarantee when the freeing of the page happens if we use
> > deferred freeing in zs_page_migrate. However, we returns
> > MIGRATEPAGE_SUCCESS which is totally lie.
> > Without instant freeing the page, it doesn't help the migration
> > situation. No?
> >
> 
> Sorry I think the reason is I didn't introduce this clear.
> After I patch e2846124f9a2.  I got some false in zs_page_isolate:
> if (get_zspage_inuse(zspage) == 0) {
> spin_unlock(&class->lock);
> return false;
> }
> The page of this zspage was migrated in before.
> 
> So I think e2846124f9a2 is OK that MIGRATEPAGE_SUCCESS with the "page".
> But it keep the "newpage" with a empty zspage inside system.
> Root cause is zs_page_isolate remove it from  ZS_EMPTY list but not
> call zs_page_putback "schedule_work(&pool->free_work);".  Because
> zs_page_migrate done the job without
> "schedule_work(&pool->free_work);"
> 
> That is why I made the new patch.

Thanks. Now I got it. Could you resend the patch with such detailed
information?

< snip >

> >> +     if (!is_zspage_isolated(zspage)) {
> >> +             /*
> >> +              * The page and class is locked, we cannot free zspage
> >> +              * immediately so let's defer.

Please put more words about that why we should calls schedule_work
in here.

Thanks!

> >> +              */
> >> +             if (putback_zspage(class, zspage) == ZS_EMPTY)
> >> +                     schedule_work(&pool->free_work);
> >> +     }
> >>
> >>       reset_page(page);
> >>       put_page(page);
> >> --
> >> 1.9.1
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
