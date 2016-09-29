Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D81B36B026B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 21:42:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 124so15216129itl.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:42:45 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d194si23061142ite.75.2016.09.28.18.42.14
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 18:42:15 -0700 (PDT)
Date: Thu, 29 Sep 2016 10:50:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160929015043.GC29250@js1304-P5Q-DELUXE>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
 <002a01d21936$5ca792a0$15f6b7e0$@net>
 <20160928051841.GB22706@js1304-P5Q-DELUXE>
 <000601d2199c$1f01cd10$5d056730$@net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000601d2199c$1f01cd10$5d056730$@net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Smythies <dsmythies@telus.net>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Wed, Sep 28, 2016 at 08:22:24AM -0700, Doug Smythies wrote:
> On 2016.09.27 23:20 Joonsoo Kim wrote:
> > On Wed, Sep 28, 2016 at 02:18:42PM +0900, Joonsoo Kim wrote:
> >> On Tue, Sep 27, 2016 at 08:13:58PM -0700, Doug Smythies wrote:
> >>> By the way, I can eliminate the problem by doing this:
> >>> (see also: https://bugzilla.kernel.org/show_bug.cgi?id=172991)
> >> 
> >> I think that Johannes found the root cause of the problem and they
> >> (Johannes and Vladimir) will solve the root cause.
> >> 
> >> However, there is something useful to do in SLAB side.
> >> Could you test following patch, please?
> >> 
> >> Thanks.
> >> 
> >> ---------->8--------------
> >> diff --git a/mm/slab.c b/mm/slab.c
> >> index 0eb6691..39e3bf2 100644
> >> --- a/mm/slab.c
> >> +++ b/mm/slab.c
> >> @@ -965,7 +965,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> >>          * guaranteed to be valid until irq is re-enabled, because it will be
> >>          * freed after synchronize_sched().
> >>          */
> >> -       if (force_change)
> >> +       if (n->shared && force_change)
> >>                 synchronize_sched();
> >
> > Oops...
> >
> > s/n->shared/old_shared/
> 
> Yes, that seems to work fine. After boot everything is good.
> Then I tried and tried to get it to mess up, but could not.

Thanks for confirm.
I will send a formal patch, soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
