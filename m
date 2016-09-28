Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F835280251
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 02:12:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so73998113pfy.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 23:12:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k87si6780760pfj.210.2016.09.27.23.11.59
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 23:12:00 -0700 (PDT)
Date: Wed, 28 Sep 2016 15:20:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160928062024.GF22706@js1304-P5Q-DELUXE>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <002a01d21936$5ca792a0$15f6b7e0$@net>
 <20160928051841.GB22706@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928051841.GB22706@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Wed, Sep 28, 2016 at 02:18:42PM +0900, Joonsoo Kim wrote:
> On Tue, Sep 27, 2016 at 08:13:58PM -0700, Doug Smythies wrote:
> > By the way, I can eliminate the problem by doing this:
> > (see also: https://bugzilla.kernel.org/show_bug.cgi?id=172991)
> 
> I think that Johannes found the root cause of the problem and they
> (Johannes and Vladimir) will solve the root cause.
> 
> However, there is something useful to do in SLAB side.
> Could you test following patch, please?
> 
> Thanks.
> 
> ---------->8--------------
> diff --git a/mm/slab.c b/mm/slab.c
> index 0eb6691..39e3bf2 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -965,7 +965,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
>          * guaranteed to be valid until irq is re-enabled, because it will be
>          * freed after synchronize_sched().
>          */
> -       if (force_change)
> +       if (n->shared && force_change)
>                 synchronize_sched();

Oops...

s/n->shared/old_shared/

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
