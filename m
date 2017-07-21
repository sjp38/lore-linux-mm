Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1536B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 01:07:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so56169126pgj.4
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 22:07:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p73si1438196pfa.300.2017.07.20.22.07.13
        for <linux-mm@kvack.org>;
        Thu, 20 Jul 2017 22:07:14 -0700 (PDT)
Date: Fri, 21 Jul 2017 14:07:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: not check inuse if
 migrate_mode is not MIGRATE_ASYNC
Message-ID: <20170721050712.GA11758@bbox>
References: <1500018667-30175-1-git-send-email-zhuhui@xiaomi.com>
 <20170717053941.GA29581@bbox>
 <CANFwon3uY_G1RshS2-3ZQu5wCre5oK6kbBNxskKVNvB3NVPTBQ@mail.gmail.com>
 <20170720084711.GA8355@bbox>
 <CANFwon270CNy173Q01oCM3GCGBx0fFPxPy9wGx_bSXPH4yXafg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANFwon270CNy173Q01oCM3GCGBx0fFPxPy9wGx_bSXPH4yXafg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Hui,

On Thu, Jul 20, 2017 at 05:33:45PM +0800, Hui Zhu wrote:

< snip >

> >> >> +++ b/mm/zsmalloc.c
> >> >> @@ -1982,6 +1982,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> >> >>       unsigned long old_obj, new_obj;
> >> >>       unsigned int obj_idx;
> >> >>       int ret = -EAGAIN;
> >> >> +     int inuse;
> >> >>
> >> >>       VM_BUG_ON_PAGE(!PageMovable(page), page);
> >> >>       VM_BUG_ON_PAGE(!PageIsolated(page), page);
> >> >> @@ -1996,21 +1997,24 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> >> >>       offset = get_first_obj_offset(page);
> >> >>
> >> >>       spin_lock(&class->lock);
> >> >> -     if (!get_zspage_inuse(zspage)) {
> >> >> +     inuse = get_zspage_inuse(zspage);
> >> >> +     if (mode == MIGRATE_ASYNC && !inuse) {
> >> >>               ret = -EBUSY;
> >> >>               goto unlock_class;
> >> >>       }
> >> >>
> >> >>       pos = offset;
> >> >>       s_addr = kmap_atomic(page);
> >> >> -     while (pos < PAGE_SIZE) {
> >> >> -             head = obj_to_head(page, s_addr + pos);
> >> >> -             if (head & OBJ_ALLOCATED_TAG) {
> >> >> -                     handle = head & ~OBJ_ALLOCATED_TAG;
> >> >> -                     if (!trypin_tag(handle))
> >> >> -                             goto unpin_objects;
> >> >> +     if (inuse) {
> >
> > I don't want to add inuse check for every loop. It might avoid unncessary
> > looping in every loop of zs_page_migrate so it is for optimization, not
> > correction. As I consider it would happen rarely, I think we don't need
> > to add the check. Could you just remove get_zspage_inuse check, instead?
> >
> > like this.
> >
> >
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 013eea76685e..2d3d75fb0f16 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1980,14 +1980,9 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
> >         pool = mapping->private_data;
> >         class = pool->size_class[class_idx];
> >         offset = get_first_obj_offset(page);
> > +       pos = offset;
> >
> >         spin_lock(&class->lock);
> > -       if (!get_zspage_inuse(zspage)) {
> > -               ret = -EBUSY;
> > -               goto unlock_class;
> > -       }
> > -
> > -       pos = offset;
> >         s_addr = kmap_atomic(page);
> >         while (pos < PAGE_SIZE) {
> >                 head = obj_to_head(page, s_addr + pos);
> >
> >
> 
> What about set pos to avoid the loops?
> 
> @@ -1997,8 +1997,10 @@ int zs_page_migrate(struct address_space
> *mapping, struct page *newpage,
> 
>         spin_lock(&class->lock);
>         if (!get_zspage_inuse(zspage)) {
> -               ret = -EBUSY;
> -               goto unlock_class;
> +               /* The page is empty.
> +                  Set "offset" to the end of page.
> +                  Then the loops of page will be avoided.  */
> +               offset = PAGE_SIZE;

Good idea. Just a nitpick:

/*
 * set "offset" to end of the page so that every loops
 * skips unnecessary object scanning.
 */

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
