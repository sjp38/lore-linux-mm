Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1326B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 23:57:16 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so96234379pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 20:57:15 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id tk2si6871190pab.87.2015.03.19.20.57.13
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 20:57:14 -0700 (PDT)
Date: Fri, 20 Mar 2015 14:57:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150320035710.GI28621@dastard>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <20150318154540.GN17241@dhcp22.suse.cz>
 <20150319083835.2115ba11@notabene.brown>
 <20150319135558.GD12466@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150319135558.GD12466@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 19, 2015 at 02:55:58PM +0100, Michal Hocko wrote:
> @@ -2701,13 +2701,24 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
>  {
>  	struct vm_fault vmf;
>  	int ret;
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	gfp_t mapping_gfp;
>  
>  	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
>  	vmf.pgoff = pgoff;
>  	vmf.flags = flags;
>  	vmf.page = NULL;
>  
> +	/*
> +	 * Some filesystems always drop __GFP_FS to prevent from reclaim
> +	 * recursion back to FS code. This is not the case here because
> +	 * we are at the top of the call chain. Add GFP_FS flags to prevent
> +	 * from premature OOM killer.
> +	 */
> +	mapping_gfp = mapping_gfp_mask(mapping);
> +	mapping_set_gfp_mask(mapping, mapping_gfp | __GFP_FS | __GFP_IO);
>  	ret = vma->vm_ops->fault(vma, &vmf);
> +	mapping_set_gfp_mask(mapping, mapping_gfp);

Urk! The inode owns the mapping and makes these decisions, not the
page fault path. These mapping flags may be set for reasons you
don't expect or know about (e.g. a subsystem specific shrinker
constraint) so paths like this have no business clearing flags they
don't own.

cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
