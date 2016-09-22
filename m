Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCE36B026C
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 20:35:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so136978794pfv.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:35:27 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id m28si926472pfk.200.2016.09.21.17.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 17:35:26 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id q2so24264158pfj.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:35:26 -0700 (PDT)
Date: Wed, 21 Sep 2016 17:35:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return
 value
In-Reply-To: <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
Message-ID: <alpine.DEB.2.10.1609211731230.130215@chino.kir.corp.google.com>
References: <57E20C49.8010304@zoho.com> <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com> <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Thu, 22 Sep 2016, zijun_hu wrote:

> On 2016/9/22 5:21, David Rientjes wrote:
> > On Wed, 21 Sep 2016, zijun_hu wrote:
> > 
> >> From: zijun_hu <zijun_hu@htc.com>
> >>
> >> correct lazy_max_pages() return value if the number of online
> >> CPUs is power of 2
> >>
> >> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> >> ---
> >>  mm/vmalloc.c | 4 +++-
> >>  1 file changed, 3 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> >> index a125ae8..2804224 100644
> >> --- a/mm/vmalloc.c
> >> +++ b/mm/vmalloc.c
> >> @@ -594,7 +594,9 @@ static unsigned long lazy_max_pages(void)
> >>  {
> >>  	unsigned int log;
> >>  
> >> -	log = fls(num_online_cpus());
> >> +	log = num_online_cpus();
> >> +	if (log > 1)
> >> +		log = (unsigned int)get_count_order(log);
> >>  
> >>  	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
> >>  }
> > 
> > The implementation of lazy_max_pages() is somewhat arbitrarily defined, 
> > the existing approximation has been around for eight years and 
> > num_online_cpus() isn't intended to be rounded up to the next power of 2.  
> > I'd be inclined to just leave it as it is.
> > 
> do i understand the intent in current code logic as below ?
> [8, 15) roundup to 16?
> [32, 63) roundup to 64?
> 

The intent is as it is implemented; with your change, lazy_max_pages() is 
potentially increased depending on the number of online cpus.  This is 
only a heuristic, changing it would need justification on why the new 
value is better.  It is opposite to what the comment says: "to be 
conservative and not introduce a big latency on huge systems, so go with
a less aggressive log scale."  NACK to the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
