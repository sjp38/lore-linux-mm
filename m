Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3286B6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 05:18:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n12so934736wmc.5
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 02:18:13 -0800 (PST)
Received: from outbound-smtp20.blacknight.com (outbound-smtp20.blacknight.com. [46.22.139.247])
        by mx.google.com with ESMTPS id h89si542083edd.471.2018.03.07.02.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 02:18:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp20.blacknight.com (Postfix) with ESMTPS id 17DE61C1901
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 10:18:11 +0000 (GMT)
Date: Wed, 7 Mar 2018 10:18:10 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] kswapd aggressiveness with watermark_scale_factor
Message-ID: <20180307101810.sxnd4tqijbatp22d@techsingularity.net>
References: <7d57222b-42f5-06a2-2f91-75384e0c0bd9@codeaurora.org>
 <20180215124016.hn64v57istrfwz7p@techsingularity.net>
 <0467b068-4627-e49f-77e8-c785a38a0d74@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0467b068-4627-e49f-77e8-c785a38a0d74@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Linux-MM <linux-mm@kvack.org>, hannes@cmpxchg.org, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "vbabka@suse.cz" <vbabka@suse.cz>

On Wed, Mar 07, 2018 at 02:47:09PM +0530, Vinayak Menon wrote:
> > This needs a proper changelog, signed-offs and a comment on the reasoning
> > behind the new min value for the gap between low and high and how it
> > was derived.  It appears the equation was designed such at the gap, as
> > a percentage of the zone size, would shrink according as the zone size
> > increases but I'm not 100% certain that was the intent. That should be
> > explained and why not just using "tmp >> 2" would have problems.
> >
> > It would also need review/testing by Johannes to ensure that there is no
> > reintroduction of the problems that watermark_scale_factor was designed
> > to solve.
> 
> Sorry for the delayed response. I will send a patch with the details. The equation was designed so that the
> low-high gap is small for smaller RAM sizes and tends towards min-low gap as the RAM size increases. This
> was done considering that it should not have a bad effect on for 140G configuration which Johannes had taken
> taken as example when watermark_scale_factor was introduced, also assuming that the thrashing seen due to
> low-high gap would be visible only on low RAM devices.
> 

If you do spin a new version with corrections made, be very careful to
note that the figures you supply are based on a kernel without THP because
that's where it makes a real difference. The differences with THP enabled
are very different as that alters min_free_kbytes and by extention, it
changes the point where your patch has an effect on the distance between
watermarks. It does mean that a test you say definitely works will not
necessary be visible to someone who tests the same patch on x86-64. Maybe
no one will notice or care but if you get a report about the results being
unreproducible then I suggest you check first if THP was enabled.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
