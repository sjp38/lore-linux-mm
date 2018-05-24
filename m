Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CABB6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f188-v6so629821wme.2
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:00:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23-v6si4250188edr.80.2018.05.24.01.00.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 01:00:13 -0700 (PDT)
Date: Thu, 24 May 2018 10:00:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: do not warn on offline nodes unless the specific
 node is explicitly requested
Message-ID: <20180524080011.GV20441@dhcp22.suse.cz>
References: <20180523125555.30039-1-mhocko@kernel.org>
 <20180523125555.30039-3-mhocko@kernel.org>
 <11e26a4e-552e-b1dc-316e-ce3e92973556@linux.vnet.ibm.com>
 <20180523140601.GQ20441@dhcp22.suse.cz>
 <094afec3-5682-f99d-81bb-230319c78d5d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <094afec3-5682-f99d-81bb-230319c78d5d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@techadventures.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 24-05-18 08:52:14, Anshuman Khandual wrote:
> On 05/23/2018 07:36 PM, Michal Hocko wrote:
> > On Wed 23-05-18 19:15:51, Anshuman Khandual wrote:
> >> On 05/23/2018 06:25 PM, Michal Hocko wrote:
> >>> when adding memory to a node that is currently offline.
> >>>
> >>> The VM_WARN_ON is just too loud without a good reason. In this
> >>> particular case we are doing
> >>> 	alloc_pages_node(node, GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN, order)
> >>>
> >>> so we do not insist on allocating from the given node (it is more a
> >>> hint) so we can fall back to any other populated node and moreover we
> >>> explicitly ask to not warn for the allocation failure.
> >>>
> >>> Soften the warning only to cases when somebody asks for the given node
> >>> explicitly by __GFP_THISNODE.
> >>
> >> node hint passed here eventually goes into __alloc_pages_nodemask()
> >> function which then picks up the applicable zonelist irrespective of
> >> the GFP flag __GFP_THISNODE.
> > 
> > __GFP_THISNODE should enforce the given node without any fallbacks
> > unless something has changed recently.
> 
> Right. I was just saying requiring given preferred node to be online
> whose zonelist (hence allocation zone fallback order) is getting picked
> up during allocation and warning when that is not online still makes
> sense.

Why? We have a fallback and that is expected to be used. How does
offline differ from depleted node from the semantical point of view?

> We should only hide the warning if the allocation request has
> __GFP_NOWARN.
> 
> > 
> >> Though we can go into zones of other
> >> nodes if the present node (whose zonelist got picked up) does not
> >> have any memory in it's zones. So warning here might not be without
> >> any reason.
> > 
> > I am not sure I follow. Are you suggesting a different VM_WARN_ON?
> 
> I am just suggesting this instead.
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 036846fc00a6..7f860ea29ec6 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -464,7 +464,7 @@ static inline struct page *
>  __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>  {
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> -	VM_WARN_ON(!node_online(nid));
> +	VM_WARN_ON(!(gfp_mask & __GFP_NOWARN) && !node_online(nid));
>  
>  	return __alloc_pages(gfp_mask, order, nid);
>  }

I have considered that but I fail to see why should we warn about
regular GFP_KERNEL allocations as mentioned above. Just consider an
allocation for the preffered node. Do you want to warn just because that
node went offline?
-- 
Michal Hocko
SUSE Labs
