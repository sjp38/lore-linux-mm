Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2F306B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:12:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s19-v6so3231902iog.0
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:12:14 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r103-v6si3975412ioi.273.2018.06.27.20.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 20:12:13 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5S38hQe120081
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:12:13 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jukhsfqw3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:12:13 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3CCLI010754
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:12:12 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3CBQH015145
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:12:12 GMT
Received: by mail-oi0-f45.google.com with SMTP id k81-v6so3814400oib.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:12:11 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-3-bhe@redhat.com>
 <20180627095439.GA5924@techadventures.net> <20180627225945.GD8970@localhost.localdomain>
In-Reply-To: <20180627225945.GD8970@localhost.localdomain>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 27 Jun 2018 23:11:35 -0400
Message-ID: <CAGM2reaS=KsD1OTxO9OYGdVuVyQb72ew=XQus2sJ-zAUbTAvpQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/4] mm/sparsemem: Defer the ms->section_mem_map clearing
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: osalvador@techadventures.net, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

Once you remove the ms mentioned by Oscar:
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
On Wed, Jun 27, 2018 at 6:59 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 06/27/18 at 11:54am, Oscar Salvador wrote:
> > On Wed, Jun 27, 2018 at 09:31:14AM +0800, Baoquan He wrote:
> > > In sparse_init(), if CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y, system
> > > will allocate one continuous memory chunk for mem maps on one node and
> > > populate the relevant page tables to map memory section one by one. If
> > > fail to populate for a certain mem section, print warning and its
> > > ->section_mem_map will be cleared to cancel the marking of being present.
> > > Like this, the number of mem sections marked as present could become
> > > less during sparse_init() execution.
> > >
> > > Here just defer the ms->section_mem_map clearing if failed to populate
> > > its page tables until the last for_each_present_section_nr() loop. This
> > > is in preparation for later optimizing the mem map allocation.
> > >
> > > Signed-off-by: Baoquan He <bhe@redhat.com>
> > > ---
> > >  mm/sparse-vmemmap.c |  1 -
> > >  mm/sparse.c         | 12 ++++++++----
> > >  2 files changed, 8 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > > index bd0276d5f66b..640e68f8324b 100644
> > > --- a/mm/sparse-vmemmap.c
> > > +++ b/mm/sparse-vmemmap.c
> > > @@ -303,7 +303,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> > >             ms = __nr_to_section(pnum);
> > >             pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> > >                    __func__);
> > > -           ms->section_mem_map = 0;
> >
> > Since we are deferring the clearing of section_mem_map, I guess we do not need
> >
> > struct mem_section *ms;
> > ms = __nr_to_section(pnum);
> >
> > anymore, right?
>
> Right, good catch, thanks.
>
> I will post a new round to fix this.
>
> >
> > >     }
> > >
> > >     if (vmemmap_buf_start) {
> > > diff --git a/mm/sparse.c b/mm/sparse.c
> > > index 6314303130b0..71ad53da2cd1 100644
> > > --- a/mm/sparse.c
> > > +++ b/mm/sparse.c
> > > @@ -451,7 +451,6 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> > >             ms = __nr_to_section(pnum);
> > >             pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> > >                    __func__);
> > > -           ms->section_mem_map = 0;
> >
> > The same goes here.
> >
> >
> >
> > --
> > Oscar Salvador
> > SUSE L3
>
