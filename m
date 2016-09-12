Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 945106B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:18:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g141so54522721wmd.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:18:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s140si14420053wmd.57.2016.09.12.02.18.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 02:18:16 -0700 (PDT)
Date: Mon, 12 Sep 2016 11:18:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
Message-ID: <20160912091811.GE14524@dhcp22.suse.cz>
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Li Zhong <zhong@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Mon 05-09-16 16:18:29, Vlastimil Babka wrote:
> On 09/05/2016 04:59 AM, Li Zhong wrote:
> > Commit 394e31d2c introduced new_node_page() for memory hotplug.
> > 
> > In new_node_page(), the nid is cleared before calling __alloc_pages_nodemask().
> > But if it is the only node of the system,
> 
> So the use case is that we are partially offlining the only online node?
> 
> > and the first round allocation fails,
> > it will not be able to get memory from an empty nodemask, and trigger oom.
> 
> Hmm triggering OOM due to empty nodemask sounds like a wrong thing to do.
> CCing some OOM experts for insight.

Hmm, to be honest I think that using an empty nodemask is just a bug in
the code. I do not see any reasonable scenario when this would make a
sense. I agree that triggering an OOM killer for that is bad as well but
do we actually want to allow for such a case at all? How can this
happen?

> Also OOM is skipped for __GFP_THISNODE
> allocations, so we might also consider the same for nodemask-constrained
> allocations?
> 
> > The patch checks whether it is the last node on the system, and if it is, then
> > don't clear the nid in the nodemask.
> 
> I'd rather see the allocation not OOM, and rely on the fallback in
> new_node_page() that doesn't have nodemask. But I suspect it might also make
> sense to treat empty nodemask as something unexpected and put some WARN_ON
> (instead of OOM) in the allocator.

To be honest I am really not all that happy about 394e31d2ceb4
("mem-hotplug: alloc new page from a nearest neighbor node when
mem-offline") and find it a bit fishy. I would rather re-iterate that
patch rather than build new hacks on top.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
