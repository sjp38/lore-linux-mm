Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D99F0280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 05:21:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k44so646099wre.1
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 02:21:16 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id p46si16566edc.208.2018.01.04.02.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 02:21:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 62F621C21AF
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 10:21:15 +0000 (GMT)
Date: Thu, 4 Jan 2018 10:21:14 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -V4 -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20180104102114.l45sjluuzdgpcfd7@techsingularity.net>
References: <871sjopllj.fsf@yhuang-dev.intel.com>
 <20171221235813.GA29033@bbox>
 <87r2rmj1d8.fsf@yhuang-dev.intel.com>
 <20171223013653.GB5279@bgram>
 <20180102102103.mpah2ehglufwhzle@suse.de>
 <20180102112955.GA29170@quack2.suse.cz>
 <20180102132908.hv3qwxqpz7h2jyqp@techsingularity.net>
 <87o9mbixi0.fsf@yhuang-dev.intel.com>
 <20180103095408.pqxggi7voser7ia3@techsingularity.net>
 <87lgheh173.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87lgheh173.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, J???r???me Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu, Jan 04, 2018 at 09:17:36AM +0800, Huang, Ying wrote:
> > Maybe, but in this particular case, I would prefer to go with something
> > more conventional unless there is strong evidence that it's an improvement
> > (which I doubt in this case given the cost of migration overall and the
> > corner case of migrating a dirty page).
> 
> So you like page_lock() more than RCU? 

In this instance, yes.

> Is there any problem of RCU?
> The object to be protected isn't clear?
> 

It's not clear what object is being protected or how it's protected and
it's not the usual means a mapping is pinned. Furthermore, in the event
a page is being truncated, we really do not want to bother doing any
migration work for compaction purposes as it's a waste.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
