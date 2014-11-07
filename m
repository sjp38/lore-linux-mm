Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id E5475800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 05:45:37 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id v1so1526520yhn.12
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 02:45:37 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id q205si12085yka.176.2014.11.07.02.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Nov 2014 02:45:33 -0800 (PST)
Date: Fri, 7 Nov 2014 10:45:32 +0000
From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH RFC] x86,mm: use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA
Message-ID: <20141107104531.GA28188@zion.uk.xensource.com>
References: <1415296096-22873-1-git-send-email-wei.liu2@citrix.com>
 <20141107085210.GW21422@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141107085210.GW21422@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Wei Liu <wei.liu2@citrix.com>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Fri, Nov 07, 2014 at 08:52:10AM +0000, Mel Gorman wrote:
> On Thu, Nov 06, 2014 at 05:48:16PM +0000, Wei Liu wrote:
> > In b38af4721 ("x86,mm: fix pte_special versus pte_numa") pte_special()
> > (SPECIAL with PRESENT or PROTNONE) was made to complement pte_numa()
> > (SPECIAL with neither PRESENT nor PROTNONE). That broke Xen PV guest
> > with NUMA balancing support.
> > 
> > That's because Xen hypervisor sets _PAGE_GLOBAL (_PAGE_GLOBAL /
> > _PAGE_PROTNONE in Linux) for guest user space mapping. So in a Xen PV
> > guest, when NUMA balancing is enabled, a NUMA hinted PTE ends up
> > "SPECIAL (in fact NUMA) with PROTNONE but not PRESENT", which makes
> > pte_special() returns true when it shouldn't.
> > 
> > Fundamentally we only need _PAGE_NUMA and _PAGE_PRESENT to tell
> > difference between an unmapped entry and an entry protected for NUMA
> > hinting fault. So use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA, adjust
> > _PAGE_NUMA_MASK and SWP_OFFSET_SHIFT as needed.
> > 
> > Suggested-by: David Vrabel <david.vrabel@citrix.com>
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> 
> I suggest instead that you force automatic NUMA balancing to be disabled
> on Xen PV guests until I or someone else finds time to implement Linus'
> idea to remove _PAGE_NUMA entirely. It's been on my TODO list for a few
> weeks but I still have not reached the point where I'm back working on
> upstream material properly.
>  

No problem. Thanks for the suggestion.

Wei.

> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
