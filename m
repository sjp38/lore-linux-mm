Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA916B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 17:53:35 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cg13so56064786pac.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 14:53:35 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id er9si36862958pac.198.2016.09.20.14.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 14:53:34 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id wk8so10947952pab.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 14:53:34 -0700 (PDT)
Date: Tue, 20 Sep 2016 14:53:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in
 new_node_page()
In-Reply-To: <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
Message-ID: <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
References: <1473044391.4250.19.camel@TP420> <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz> <20160912091811.GE14524@dhcp22.suse.cz> <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, Li Zhong <zhong@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, 20 Sep 2016, Vlastimil Babka wrote:

> On 09/12/2016 11:18 AM, Michal Hocko wrote:
> > On Mon 05-09-16 16:18:29, Vlastimil Babka wrote:
> > 
> > > Also OOM is skipped for __GFP_THISNODE
> > > allocations, so we might also consider the same for nodemask-constrained
> > > allocations?
> > > 
> > > > The patch checks whether it is the last node on the system, and if it
> > > is, then
> > > > don't clear the nid in the nodemask.
> > > 
> > > I'd rather see the allocation not OOM, and rely on the fallback in
> > > new_node_page() that doesn't have nodemask. But I suspect it might also
> > > make
> > > sense to treat empty nodemask as something unexpected and put some WARN_ON
> > > (instead of OOM) in the allocator.
> > 
> > To be honest I am really not all that happy about 394e31d2ceb4
> > ("mem-hotplug: alloc new page from a nearest neighbor node when
> > mem-offline") and find it a bit fishy. I would rather re-iterate that
> > patch rather than build new hacks on top.
> 
> OK, IIRC I suggested the main idea of clearing the current node from nodemask
> and relying on nodelist to get us the other nodes sorted by their distance.
> Which I thought was an easy way to get to the theoretically optimal result.
> How would you rewrite it then? (but note that the fix is already mainline).
> 

This is a mess.  Commit 9bb627be47a5 ("mem-hotplug: don't clear the only 
node in new_node_page()") is wrong because it's clearing nid when the next 
node in node_online_map doesn't match.  node_online_map is wrong because 
it includes memoryless nodes.  (Nodes with closest NUMA distance also do 
not need to have adjacent node ids.)

This is all protected by mem_hotplug_begin() and the zonelists will be 
stable.  The solution is to rewrite new_node_page() to work correctly.  
Use node_states[N_MEMORY] as mask, clear page_to_nid(page).  If mask is 
not empty, do

__alloc_pages_nodemask(gfp_mask, 0,
node_zonelist(page_to_nid(page), gfp_mask), &mask) 

and fallback to alloc_page(gfp_mask), which should also be used if the 
mask is empty -- do not try to allocate memory from the empty set of 
nodes.

mm-page_alloc-warn-about-empty-nodemask.patch is a rather ridiculous 
warning to need.  The largest user of a page allocator nodemask is 
mempolicies which makes sure it doesn't pass an empty set.  If it's really 
required, it should at least be unlikely() since the vast majority of 
callers will have ac->nodemask == NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
