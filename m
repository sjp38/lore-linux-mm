Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 793526B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:27:52 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so63988181wgd.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:27:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jx2si2710559wjc.7.2015.03.19.07.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 07:27:51 -0700 (PDT)
Date: Thu, 19 Mar 2015 15:27:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150319142749.GE12466@dhcp22.suse.cz>
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
To: NeilBrown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-03-15 14:55:58, Michal Hocko wrote:
> On Thu 19-03-15 08:38:35, Neil Brown wrote:
> [...]
> > Nearly half the places in the kernel which call mapping_gfp_mask() remove the
> > __GFP_FS bit.
> > 
> > That suggests to me that it might make sense to have
> >    mapping_gfp_mask_fs()
> > and
> >    mapping_gfp_mask_nofs()
> >
> > and let the presence of __GFP_FS (and __GFP_IO) be determined by the
> > call-site rather than the filesystem.
> 
> Sounds reasonable to me but filesystems tend to use this in a very
> different ways.
> - xfs drops GFP_FS in xfs_setup_inode so all page cache allocations are
>   NOFS.
> - reiserfs drops GFP_FS only before calling read_mapping_page in
>   reiserfs_get_page and never restores the original mask.
> - btrfs doesn't seem to rely on mapping_gfp_mask for anything other than
>   btree_inode (unless it gets inherrited in a way I haven't noticed).
> - ext* doesn't seem to rely on the mapping gfp mask at all.
> 
> So it is not clear to me how we should change that into callsites. But I
> guess we can change at least the page fault path like the following. I
> like it much more than the previous way which is too hackish.

But this is racy instead... And I do not think we can make it raceless
so scratch this and get back to the original approach.
[...]
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
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
>  		return ret;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
