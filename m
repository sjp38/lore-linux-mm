Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA5F28025B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:08:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so50316932wmc.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:08:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df6si2538805wjc.260.2016.09.21.11.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 11:08:32 -0700 (PDT)
Date: Wed, 21 Sep 2016 20:08:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
Message-ID: <20160921180824.GI24210@dhcp22.suse.cz>
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
 <20160912091811.GE14524@dhcp22.suse.cz>
 <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
 <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Li Zhong <zhong@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue 20-09-16 14:53:32, David Rientjes wrote:
> On Tue, 20 Sep 2016, Vlastimil Babka wrote:
> 
> > On 09/12/2016 11:18 AM, Michal Hocko wrote:
> > > On Mon 05-09-16 16:18:29, Vlastimil Babka wrote:
> > > 
> > > > Also OOM is skipped for __GFP_THISNODE
> > > > allocations, so we might also consider the same for nodemask-constrained
> > > > allocations?
> > > > 
> > > > > The patch checks whether it is the last node on the system, and if it
> > > > is, then
> > > > > don't clear the nid in the nodemask.
> > > > 
> > > > I'd rather see the allocation not OOM, and rely on the fallback in
> > > > new_node_page() that doesn't have nodemask. But I suspect it might also
> > > > make
> > > > sense to treat empty nodemask as something unexpected and put some WARN_ON
> > > > (instead of OOM) in the allocator.
> > > 
> > > To be honest I am really not all that happy about 394e31d2ceb4
> > > ("mem-hotplug: alloc new page from a nearest neighbor node when
> > > mem-offline") and find it a bit fishy. I would rather re-iterate that
> > > patch rather than build new hacks on top.
> > 
> > OK, IIRC I suggested the main idea of clearing the current node from nodemask
> > and relying on nodelist to get us the other nodes sorted by their distance.
> > Which I thought was an easy way to get to the theoretically optimal result.
> > How would you rewrite it then? (but note that the fix is already mainline).
> > 
> 
> This is a mess.  Commit 9bb627be47a5 ("mem-hotplug: don't clear the only 
> node in new_node_page()") is wrong because it's clearing nid when the next 
> node in node_online_map doesn't match.  node_online_map is wrong because 
> it includes memoryless nodes.  (Nodes with closest NUMA distance also do 
> not need to have adjacent node ids.)
> 
> This is all protected by mem_hotplug_begin() and the zonelists will be 
> stable.  The solution is to rewrite new_node_page() to work correctly.  
> Use node_states[N_MEMORY] as mask, clear page_to_nid(page).  If mask is 
> not empty, do
> 
> __alloc_pages_nodemask(gfp_mask, 0,
> node_zonelist(page_to_nid(page), gfp_mask), &mask) 
> 
> and fallback to alloc_page(gfp_mask), which should also be used if the 
> mask is empty -- do not try to allocate memory from the empty set of 
> nodes.
> 
> mm-page_alloc-warn-about-empty-nodemask.patch is a rather ridiculous 
> warning to need.  The largest user of a page allocator nodemask is 
> mempolicies which makes sure it doesn't pass an empty set.  If it's really 
> required, it should at least be unlikely() since the vast majority of 
> callers will have ac->nodemask == NULL.

Sorry to respond late, I was too busy with other thigns but I completely
agree with the above. This is the way we should go forward!

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
