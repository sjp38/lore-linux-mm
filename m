Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2DB46B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 18:59:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b8-v6so3496232qto.13
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:59:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u43-v6si2640199qtk.112.2018.06.27.15.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 15:59:50 -0700 (PDT)
Date: Thu, 28 Jun 2018 06:59:45 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v5 2/4] mm/sparsemem: Defer the ms->section_mem_map
 clearing
Message-ID: <20180627225945.GD8970@localhost.localdomain>
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-3-bhe@redhat.com>
 <20180627095439.GA5924@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627095439.GA5924@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/27/18 at 11:54am, Oscar Salvador wrote:
> On Wed, Jun 27, 2018 at 09:31:14AM +0800, Baoquan He wrote:
> > In sparse_init(), if CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y, system
> > will allocate one continuous memory chunk for mem maps on one node and
> > populate the relevant page tables to map memory section one by one. If
> > fail to populate for a certain mem section, print warning and its
> > ->section_mem_map will be cleared to cancel the marking of being present.
> > Like this, the number of mem sections marked as present could become
> > less during sparse_init() execution.
> > 
> > Here just defer the ms->section_mem_map clearing if failed to populate
> > its page tables until the last for_each_present_section_nr() loop. This
> > is in preparation for later optimizing the mem map allocation.
> > 
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> > ---
> >  mm/sparse-vmemmap.c |  1 -
> >  mm/sparse.c         | 12 ++++++++----
> >  2 files changed, 8 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > index bd0276d5f66b..640e68f8324b 100644
> > --- a/mm/sparse-vmemmap.c
> > +++ b/mm/sparse-vmemmap.c
> > @@ -303,7 +303,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  		ms = __nr_to_section(pnum);
> >  		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> >  		       __func__);
> > -		ms->section_mem_map = 0;
> 
> Since we are deferring the clearing of section_mem_map, I guess we do not need
> 
> struct mem_section *ms;
> ms = __nr_to_section(pnum);
> 
> anymore, right?

Right, good catch, thanks.

I will post a new round to fix this.

> 
> >  	}
> >  
> >  	if (vmemmap_buf_start) {
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 6314303130b0..71ad53da2cd1 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -451,7 +451,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  		ms = __nr_to_section(pnum);
> >  		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> >  		       __func__);
> > -		ms->section_mem_map = 0;
> 
> The same goes here.
> 
> 
> 
> -- 
> Oscar Salvador
> SUSE L3
