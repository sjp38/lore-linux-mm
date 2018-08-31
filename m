Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83B7A6B590E
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 17:31:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v52-v6so16156687qtc.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 14:31:56 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l184-v6si1496730qkd.360.2018.08.31.14.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 14:31:55 -0700 (PDT)
Date: Fri, 31 Aug 2018 14:31:41 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
Message-ID: <20180831213138.GA9159@tower.DHCP.thefacebook.com>
References: <20180831203450.2536-1-guro@fb.com>
 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Aug 31, 2018 at 05:15:39PM -0400, Rik van Riel wrote:
> On Fri, 2018-08-31 at 13:34 -0700, Roman Gushchin wrote:
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index fa2c150ab7b9..c910cf6bf606 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -476,6 +476,10 @@ static unsigned long do_shrink_slab(struct
> > shrink_control *shrinkctl,
> >  	delta = freeable >> priority;
> >  	delta *= 4;
> >  	do_div(delta, shrinker->seeks);
> > +
> > +	if (delta == 0 && freeable > 0)
> > +		delta = min(freeable, batch_size);
> > +
> >  	total_scan += delta;
> >  	if (total_scan < 0) {
> >  		pr_err("shrink_slab: %pF negative objects to delete
> > nr=%ld\n",
> 
> I agree that we need to shrink slabs with fewer than
> 4096 objects, but do we want to put more pressure on
> a slab the moment it drops below 4096 than we applied
> when it had just over 4096 objects on it?
> 
> With this patch, a slab with 5000 objects on it will
> get 1 item scanned, while a slab with 4000 objects on
> it will see shrinker->batch or SHRINK_BATCH objects
> scanned every time.
> 
> I don't know if this would cause any issues, just
> something to ponder.

Hm, fair enough. So, basically we can always do

    delta = max(delta, min(freeable, batch_size));

Does it look better?


> 
> If nobody things this is a problem, you can give the
> patch my:
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> 

Thanks!
