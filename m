Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 740B5600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 23:55:43 -0500 (EST)
Received: by ywh5 with SMTP id 5so28104483ywh.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 20:55:41 -0800 (PST)
Date: Mon, 4 Jan 2010 13:48:27 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm : add check for the return value
Message-Id: <20100104134827.ce642c11.minchan.kim@barrios-desktop>
In-Reply-To: <4B416A28.70806@gmail.com>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
	<20100104122138.f54b7659.minchan.kim@barrios-desktop>
	<4B416A28.70806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: shijie8 <shijie8@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 04 Jan 2010 12:10:16 +0800
shijie8 <shijie8@gmail.com> wrote:

> 
> > I think it's not desirable to add new branch in hot-path even though
> > we could avoid that.
> >
> > How about this?
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4e4b5b3..87976ad 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1244,6 +1244,9 @@ again:
> >          return page;
> >
> >   failed:
> >    
> you miss anther place where also  uses "goto failed".

Yes. It was just for showing my intention. :)

> > +       spin_lock(&zone->lock);
> > +       __mod_zone_page_state(zone, NR_FREE_PAGES, 1<<  order);
> > +       spin_unlock(&zone->lock);
> >          local_irq_restore(flags);
> >          put_cpu();
> >          return NULL;
> >
> >    
> I also thought  over your method before I sent the patch,  but there 
> already exits a
> "if (!page)" , I not sure whether my patch adds too much delay in hot-path.

Tend to agree. I don't object your patch. 

I think the branch itself could not a big deal but 'likely'. 

Why I suggest is that now 'if (!page)' don't have 'likely'.
As you know, 'likely' make the code relocate for reducing code footprint.

Why? It was just mistake or doesn't need it? 

I think Mel does know it. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
