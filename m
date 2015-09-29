Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 58A6E6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:29:56 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so142316874wic.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:29:56 -0700 (PDT)
Received: from mail-wi0-x241.google.com (mail-wi0-x241.google.com. [2a00:1450:400c:c05::241])
        by mx.google.com with ESMTPS id zb2si28550780wjc.95.2015.09.29.03.29.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 03:29:55 -0700 (PDT)
Received: by wicxq10 with SMTP id xq10so1289683wic.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:29:54 -0700 (PDT)
Date: Tue, 29 Sep 2015 13:26:57 +0300
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH 1/2] mm: change free_cma and free_pages declarations to
 unsigned
Message-ID: <20150929102657.GA27621@gmail.com>
References: <20150927210416.GA20144@gmail.com>
 <20150929101327.GW25655@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150929101327.GW25655@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, mgorman@suse.dec, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 29, 2015 at 11:13:27AM +0100, Mel Gorman wrote:
> On Sun, Sep 27, 2015 at 09:04:16PM +0000, Alexandru Moise wrote:
> > Their stored values come from zone_page_state() which returns
> > an unsigned long. To improve code correctness we should avoid
> > mixing signed and unsigned integers.
> > 
> > Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
> > ---
> >  mm/page_alloc.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 48aaf7b..f55e3a2 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2242,7 +2242,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  	/* free_pages may go negative - that's OK */
> >  	long min = mark;
> >  	int o;
> > -	long free_cma = 0;
> > +	unsigned long free_cma = 0;
> >  
> 
> NAK.
> 
> free_cma is used with free_pages which is explicitly commented as saying
> it can go negative. With your patch, there is a signed/unsigned operation
> where the unsigned type cannot fit into the signed type which casts them
> both to unsigned which is then broken for the comparison.  This patch
> looks broken for very subtle reasons. Please do not do any similar style
> patches to this because they can introduce subtle breakage if issues are
> not caught at review.
> 

Understood, I thought the comment only applied to the "min" variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
