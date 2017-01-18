Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 744196B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:03:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so2071588wme.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:03:43 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id y128si9017508wme.153.2017.01.18.02.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 02:03:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id E716B1C1542
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:03:41 +0000 (GMT)
Date: Wed, 18 Jan 2017 10:03:41 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to
 slowpath
Message-ID: <20170118100341.liydtsdqovmlgys4@techsingularity.net>
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117221610.22505-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 11:16:09PM +0100, Vlastimil Babka wrote:
> This is a preparation for the following patch to make review simpler. While
> the primary motivation is a bug fix, this could also save some cycles in the
> fast path.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

To be clear, the fast path savings will be when cpusets are active even
though that is still a good thing.  Most of the time, they are disabled
static branches. I see there were concerns raised that this would retry
the kswapd paths but I don't really see the issue. The same wakeup could
occur due to a cpuset switch with the existing retry. Even a potentially
spurious wakeup of kswapd is ok if the slow paths were being hit anyway
as kswapd is probably still awake from the first wakeup. If anything,
the fact that kswapd wakeups ignore cpusets and potentially wakes kswapd
on forbidden nodes is more problematic but not worth fixing. If kswapd
needs to wake on a node outside the cpuset then it's going to be by some
active process outside the cpuset some time in the future so;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
