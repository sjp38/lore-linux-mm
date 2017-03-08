Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3C3831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:22:54 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y51so9093103wry.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:22:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r205si7539968wma.48.2017.03.08.01.22.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 01:22:53 -0800 (PST)
Date: Wed, 8 Mar 2017 10:22:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170308092251.GC11028@dhcp22.suse.cz>
References: <20170307141020.29107-1-mhocko@kernel.org>
 <20170307150845.075cceea71647bfeba3c5e22@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307150845.075cceea71647bfeba3c5e22@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 07-03-17 15:08:45, Andrew Morton wrote:
> On Tue,  7 Mar 2017 15:10:20 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > __vmalloc* allows users to provide gfp flags for the underlying
> > allocation. This API is quite popular
> > $ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
> > 77
> > 
> > the only problem is that many people are not aware that they really want
> > to give __GFP_HIGHMEM along with other flags because there is really no
> > reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
> > which are mapped to the kernel vmalloc space. About half of users don't
> > use this flag, though. This signals that we make the API unnecessarily
> > too complex.
> > 
> > This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> > be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> > are simplified and drop the flag.
> 
> hm.  What happens if a caller wants only lowmem pages?  Drivers do
> weird stuff...
 
Yes they do and we have vmalloc_32 API which works as intended because
GFP_VMALLOC32 contains GFP_DMA32 and that will override __GFP_HIGHMEM.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
