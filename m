Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAC16B788E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:27:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w42-v6so3441061eda.23
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:27:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j62-v6si924020edb.79.2018.09.06.04.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:27:53 -0700 (PDT)
Date: Thu, 6 Sep 2018 13:27:52 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180906112752.GQ14951@dhcp22.suse.cz>
References: <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <20180830064732.GA2656@dhcp22.suse.cz>
 <4b23ded6-c1a0-eb13-4537-b9bc4bfb9cc9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b23ded6-c1a0-eb13-4537-b9bc4bfb9cc9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Thu 06-09-18 13:18:52, Vlastimil Babka wrote:
> On 08/30/2018 08:47 AM, Michal Hocko wrote:
> > -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> > +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> > +	gfp_t this_node = 0;
> > +	struct mempolicy *pol;
> > +
> > +#ifdef CONFIG_NUMA
> > +	/* __GFP_THISNODE makes sense only if there is no explicit binding */
> > +	pol = get_vma_policy(vma, addr);
> > +	if (pol->mode != MPOL_BIND)
> > +		this_node = __GFP_THISNODE;
> > +	mpol_cond_put(pol);
> 
> The code is better without the hack in alloc_pages_vma() but I'm not
> thrilled about getting vma policy here and then immediately again in
> alloc_pages_vma(). But if it can't be helped...

The whole function is an act of beauty isn't it. I wanted to get the
policy from the caller but that would be even more messy so I've tried
to keep it in the ugly corner and have it hidden there. You should ask
your friends to read alloc_hugepage_direct_gfpmask unless they have done
something terribly wrong.
-- 
Michal Hocko
SUSE Labs
