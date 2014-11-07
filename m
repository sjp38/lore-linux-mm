Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5A5800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 03:52:15 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id x12so3143080wgg.17
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 00:52:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si14006226wjf.93.2014.11.07.00.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Nov 2014 00:52:14 -0800 (PST)
Date: Fri, 7 Nov 2014 08:52:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RFC] x86,mm: use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA
Message-ID: <20141107085210.GW21422@suse.de>
References: <1415296096-22873-1-git-send-email-wei.liu2@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1415296096-22873-1-git-send-email-wei.liu2@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Liu <wei.liu2@citrix.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Thu, Nov 06, 2014 at 05:48:16PM +0000, Wei Liu wrote:
> In b38af4721 ("x86,mm: fix pte_special versus pte_numa") pte_special()
> (SPECIAL with PRESENT or PROTNONE) was made to complement pte_numa()
> (SPECIAL with neither PRESENT nor PROTNONE). That broke Xen PV guest
> with NUMA balancing support.
> 
> That's because Xen hypervisor sets _PAGE_GLOBAL (_PAGE_GLOBAL /
> _PAGE_PROTNONE in Linux) for guest user space mapping. So in a Xen PV
> guest, when NUMA balancing is enabled, a NUMA hinted PTE ends up
> "SPECIAL (in fact NUMA) with PROTNONE but not PRESENT", which makes
> pte_special() returns true when it shouldn't.
> 
> Fundamentally we only need _PAGE_NUMA and _PAGE_PRESENT to tell
> difference between an unmapped entry and an entry protected for NUMA
> hinting fault. So use _PAGE_BIT_SOFTW2 as _PAGE_BIT_NUMA, adjust
> _PAGE_NUMA_MASK and SWP_OFFSET_SHIFT as needed.
> 
> Suggested-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

I suggest instead that you force automatic NUMA balancing to be disabled
on Xen PV guests until I or someone else finds time to implement Linus'
idea to remove _PAGE_NUMA entirely. It's been on my TODO list for a few
weeks but I still have not reached the point where I'm back working on
upstream material properly.
 
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
