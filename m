Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90F8A6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:09:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so58875278wmf.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 05:09:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d18si50233559wmd.16.2016.12.28.05.09.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 05:09:53 -0800 (PST)
Date: Wed, 28 Dec 2016 14:09:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] slab reclaim
Message-ID: <20161228130949.GA11480@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hi,
I would like to propose the following for LSF/MM discussion. Both MM and
FS people should be involved.

The current way of the slab reclaim is rather suboptimal from 2
perspectives.

1) The slab allocator relies on shrinkers to release pages but shrinkers
are object rather than page based. This means that the memory reclaim
asks to free some pages, slab asks shrinkers to free some objects
and the result might be that nothing really gets freed even though
shrinkers do their jobs properly because some objects are still pinning
the page. This is not a new problem and it has been discussed in the
past. Dave Chinner has even suggested a solution [1] which sounds like
the right approach. There was no follow up and I believe we should
into implementing it.

2) The way we scale slab reclaim pressure depends on the regular LRU
reclaim. There are workloads which do not general a lot of pages on LRUs
while they still consume a lot of slab memory. We can end up even going
OOM because the slab reclaim doesn't free up enough. I am not really
sure how the proper solution should look like but either we need some
way of slab consumption throttling or we need a more clever slab
pressure estimation.

[1] https://lkml.org/lkml/2010/2/8/329.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
