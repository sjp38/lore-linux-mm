Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8D76B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 08:33:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so22975356wma.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:33:51 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id gm9si1028652wjb.47.2016.06.23.05.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 05:33:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 5D4B61C1D74
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 13:33:49 +0100 (IST)
Date: Thu, 23 Jun 2016 13:33:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
Message-ID: <20160623123347.GV1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <20160623102648.GP1868@techsingularity.net>
 <20160623112714.GF30077@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160623112714.GF30077@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 23, 2016 at 01:27:14PM +0200, Michal Hocko wrote:
> On Thu 23-06-16 11:26:48, Mel Gorman wrote:
> > On Tue, Jun 21, 2016 at 03:15:39PM +0100, Mel Gorman wrote:
> > > The bulk of the updates are in response to review from Vlastimil Babka
> > > and received a lot more testing than v6.
> > > 
> > 
> > Hi Andrew,
> > 
> > Please drop these patches again from mmotm.
> > 
> > There has been a number of odd conflicts resulting in at least one major
> > bug where a node-counter is used on a zone that will result in random
> > behaviour. Some of the additional feedback is non-trivial and all of it
> > will need to be resolved against the OOM detection rework and the huge
> > tmpfs implementation.
> 
> FWIW I haven't spotted any obvious misbehaving wrt. the OOM detection
> rework. You have kept the per-zone counters which are used for the retry
> logic so I think we should be safe. I am still reading through the
> series though.
> 

The main snag is NR_FILE_DIRTY and NR_WRITEBACK in should_reclaim_retry.
It currently is a random number generator if it reads a zone stat
instead of the node one. In some configurations, it even reads values
after the stats array.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
