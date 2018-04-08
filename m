Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A3C186B0260
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 02:51:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w17so3831310qkb.19
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 23:51:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w61si6077711qte.40.2018.04.07.23.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 23:51:03 -0700 (PDT)
Date: Sun, 8 Apr 2018 14:50:55 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 2/4] mm/sparsemem: Defer the ms->section_mem_map
 clearing
Message-ID: <20180408065055.GA19345@localhost.localdomain>
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-3-bhe@redhat.com>
 <8e147320-50f5-f809-31d2-992c35ecc418@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e147320-50f5-f809-31d2-992c35ecc418@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

Hi Dave,

Thanks a lot for your careful reviewing!

On 04/06/18 at 07:23am, Dave Hansen wrote:
> On 02/27/2018 07:26 PM, Baoquan He wrote:
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
> >  	}
> 
> I think you might have been trying to say this in the description, but I
> was not able to parse it out of there.  What is in ms->section_mem_map
> that needs to get cleared?
> 
> It *looks* like memory_present() uses ms->section_mem_map to just mark
> which sections are online relatively early in boot.  We need this
> clearing to mark that they are effectively *not* present any longer.
> Correct?
> 
> I guess the concern here is that if you miss any of the error sites,
> we'll end up with a bogus, non-null ms->section_mem_map.  Do we handle
> that nicely?
> 
> Should the " = 0" instead be clearing SECTION_MARKED_PRESENT or
> something?  That would make it easier to match the code up with the code
> that it is effectively undoing.


Not sure if I understand your question correctly. From memory_present(),
information encoded into ms->section_mem_map including numa node,
SECTION_IS_ONLINE and SECTION_MARKED_PRESENT. Not sure if it's OK to only
clear SECTION_MARKED_PRESENT.  People may wrongly check SECTION_IS_ONLINE
and do something on this memory section?

Thanks
Baoquan
