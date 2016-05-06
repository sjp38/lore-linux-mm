Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48D3E6B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 23:09:28 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id n2so207299455obo.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 20:09:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g5si7095497iga.94.2016.05.05.20.09.26
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 20:09:27 -0700 (PDT)
Date: Fri, 6 May 2016 12:09:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160506030935.GA18573@bbox>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505100329.GA497@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 05, 2016 at 07:03:29PM +0900, Sergey Senozhatsky wrote:
> On (05/05/16 13:17), Ganesh Mahendran wrote:
> > if we find a zspage with usage == 100%, there is no need to
> > try other zspages.
> 
> Hello,
> 
> well... we iterate there from 0 to 1<<2, which is not awfully
> a lot to break it in the middle, and we do this only when we
> initialize a new pool (for every size class).
> 
> the check is
>  - true   15 times
>  - false  492 times

Thanks for the data, Sergey!

> 
> so it _sort of_ feels like this new if-condition doesn't
> buy us a lot, and most of the time it just sits there with
> no particular gain. let's hear from Minchan.
> 

I agree with Sergey.
First of al, I appreciates your patch, Ganesh! But as Sergey pointed
out, I don't see why it improves current zsmalloc.
If you want to merge strongly, please convince me with more detail
reason.

Thanks.


> 	-ss
> 
> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> > ---
> >  mm/zsmalloc.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index fda7177..310c7b0 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -765,6 +765,9 @@ static int get_pages_per_zspage(int class_size)
> >  		if (usedpc > max_usedpc) {
> >  			max_usedpc = usedpc;
> >  			max_usedpc_order = i;
> > +
> > +			if (max_usedpc == 100)
> > +				break;
> >  		}
> >  	}
> >  
> > -- 
> > 1.7.9.5
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
