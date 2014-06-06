Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5216B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:49:21 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id n16so868602oag.25
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:49:20 -0700 (PDT)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id eb4si19633502pbb.113.2014.06.06.06.49.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 06:49:20 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so2501512pbb.7
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:49:20 -0700 (PDT)
Message-ID: <1402062463.15497.7.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid scanning the whole targets[*] when
 scan_balance equals SCAN_FILE/SCAN_ANON
From: Chen Yucong <slaoub@gmail.com>
Date: Fri, 06 Jun 2014 21:47:43 +0800
In-Reply-To: <20140606131251.GB2878@cmpxchg.org>
References: <1402044866-15313-1-git-send-email-slaoub@gmail.com>
	 <20140606131251.GB2878@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mgorman@suse.de, mhocko@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, 2014-06-06 at 09:12 -0400, Johannes Weiner wrote:
> Hi Chen,
> 
> On Fri, Jun 06, 2014 at 04:54:26PM +0800, Chen Yucong wrote:
> > If (scan_balance == SCAN_FILE) is true for shrink_lruvec, then  the value of
> > targets[LRU_INACTIVE_ANON] and targets[LRU_ACTIVE_ANON] will be zero. As a result,
> > the value of 'percentage' will also be  zero, and the *whole* targets[LRU_INACTIVE_FILE]
> > and targets[LRU_ACTIVE_FILE] will be scanned.
> > 
> > For (scan_balance == SCAN_ANON), there is the same conditions stated above.
> > 
> > But via https://lkml.org/lkml/2013/4/10/334, we can find that the kernel does not prefer
> > reclaiming too many pages from the other LRU. So before recalculating the other LRU scan
> > count based on its original scan targets and the percentage scanning already complete, we
> > should need to check whether 'scan_balance' equals SCAN_FILE/SCAN_ANON.
> > 
> > Signed-off-by: Chen Yucong <slaoub@gmail.com>
> > ---
> >  mm/vmscan.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d51f7e0..ca3f5f1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2120,6 +2120,9 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  			percentage = nr_file * 100 / scan_target;
> >  		}
> >  
> > +		if (targets[lru] == 0 && targets[lru + LRU_ACTIVE] == 0)
> > +			break;
> 
> We have meanwhile included a change that bails out if nr_anon or
> nr_file are zero, right before that percentage calculation, that
> should cover the scenario you're describing.  It's called:
> 
> mm: vmscan: use proportional scanning during direct reclaim and full scan at DEF_PRIORITY

Thanks very much for your reply. Indeed, your patch is more
comprehensive and perfect. I think I need to update my local
git-repository timely.

thx!
cyc 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
