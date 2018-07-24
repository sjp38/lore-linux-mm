Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0601A6B0284
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:19:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l1-v6so1624514edi.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 04:19:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z27-v6si1540335edd.440.2018.07.24.04.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 04:19:16 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:19:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180724111913.GH28386@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <dca091d3-4c3d-eff5-57f8-a9a45050198d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dca091d3-4c3d-eff5-57f8-a9a45050198d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Tue 24-07-18 11:47:02, Vlastimil Babka wrote:
> On 07/23/2018 02:30 PM, Michal Hocko wrote:
> > On Mon 23-07-18 13:45:18, Vlastimil Babka wrote:
> >> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> >>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> >>> So reserved pages might be access by dump tools although nobody except
> >>> the owner should touch them.
> >>
> >> Are you sure about that? Or maybe I understand wrong. Maybe it changed
> >> recently, but IIRC pages that are backing memmap (struct pages) are also
> >> PG_reserved. And you definitely do want those in the dump.
> > 
> > You are right. reserve_bootmem_region will make all early bootmem
> > allocations (including those backing memmaps) PageReserved. I have asked
> > several times but I haven't seen a satisfactory answer yet. Why do we
> > even care for kdump about those. If they are reserved the nobody should
> > really look at those specific struct pages and manipulate them. Kdump
> > tools are using a kernel interface to read the content. If the specific
> > content is backed by a non-existing memory then they should simply not
> > return anything.
> 
> When creating a crashdump, I definitely need the pages containing memmap
> included in the dump, so I can inspect the struct pages. But this is a
> bit recursive issue, so I'll try making it clearer:
> 
> 1) there are kernel pages with data (e.g. slab) that I typically need in
> the dump, and are not PageReserved
> 2) there are struct pages for pages 1) in the memmap that physically
> hold the pageflags for 1), and these are PageReserved
> 3) there are struct pages for pages 2) somewhere else in the memmap,
> physically hold the pageflags for 2). They are probably also
> PageReserved themselves ? and self-referencing.
> 
> Excluding PageReserved from dump means there won't be cases 2) and 3) in
> the dump, which at least for case 2) is making such dump almost useless
> in many cases.

Yes, we cannot simply exclude all PageReserved pages. I was merely
suggesting to rule out new special PageReserved pages that are denoting 
offline pages. The same could be applied to HWPoison pages
-- 
Michal Hocko
SUSE Labs
