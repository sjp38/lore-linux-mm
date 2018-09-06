Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7B7C6B787B
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:18:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c25-v6so3451792edb.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:18:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e37-v6si1621367ede.202.2018.09.06.04.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:18:53 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <20180830064732.GA2656@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4b23ded6-c1a0-eb13-4537-b9bc4bfb9cc9@suse.cz>
Date: Thu, 6 Sep 2018 13:18:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180830064732.GA2656@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On 08/30/2018 08:47 AM, Michal Hocko wrote:
> -static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	gfp_t this_node = 0;
> +	struct mempolicy *pol;
> +
> +#ifdef CONFIG_NUMA
> +	/* __GFP_THISNODE makes sense only if there is no explicit binding */
> +	pol = get_vma_policy(vma, addr);
> +	if (pol->mode != MPOL_BIND)
> +		this_node = __GFP_THISNODE;
> +	mpol_cond_put(pol);

The code is better without the hack in alloc_pages_vma() but I'm not
thrilled about getting vma policy here and then immediately again in
alloc_pages_vma(). But if it can't be helped...
