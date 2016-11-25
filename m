Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3D46B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 04:00:26 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o2so2008694wje.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 01:00:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mc8si41294688wjb.284.2016.11.25.01.00.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 01:00:24 -0800 (PST)
Date: Fri, 25 Nov 2016 10:00:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Softlockup during memory allocation
Message-ID: <20161125090022.GA24353@dhcp22.suse.cz>
References: <20161121053154.GA29816@dhcp22.suse.cz>
 <ab42c7a5-49e2-4e46-be60-e0a56704a11d@kyup.com>
 <20161122143056.GB6831@dhcp22.suse.cz>
 <6c33f44b-327c-d943-73da-5935136a83c9@kyup.com>
 <20161122170239.GH6831@dhcp22.suse.cz>
 <dca0dfb4-6623-f11f-5f6e-1afac02d5ee6@kyup.com>
 <20161123074947.GE2864@dhcp22.suse.cz>
 <e0bdfd66-9e15-dee7-c311-b1785efab390@kyup.com>
 <20161124121209.GE20668@dhcp22.suse.cz>
 <a655e607-91c5-173c-ec3a-e211df598f92@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a655e607-91c5-173c-ec3a-e211df598f92@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Linux MM <linux-mm@kvack.org>

On Thu 24-11-16 15:09:38, Nikolay Borisov wrote:
[...]
> I just checked all the zones for both nodes (the machines have 2 NUMA
> nodes) so essentially there are no reclaimable pages - all are
> anonymous. So the pertinent question is why process are sleeping in
> reclamation path when there are no pages to free. I also observed the
> same behavior on a different node, this time the priority was 0 and the
> code hasn't resorted to OOM. This seems all too strange..

>From my experience we usually hit the memcg OOM quickly if there are no
reclaimable pages. I do not remember anything big changed recently in
that area. Could you enable mm_vmscan_memcg_isolate,
mm_vmscan_memcg_reclaim__{begin,end} and mm_vmscan_lru_shrink_inactive
tracepoints to see what is going on during the reclaim?

I suspect we will see some minor reclaim activity there which will
basically "livelock" the oom from happening but let's see.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
