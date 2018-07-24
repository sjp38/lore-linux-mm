Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91D996B0273
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 04:54:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f13-v6so1459130edr.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 01:54:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18-v6si698329edf.80.2018.07.24.01.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 01:54:01 -0700 (PDT)
Date: Tue, 24 Jul 2018 10:53:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180724085358.GG28386@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <d4528eb7-9d8b-4073-afad-d8dd1390aa91@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4528eb7-9d8b-4073-afad-d8dd1390aa91@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Tue 24-07-18 10:46:20, David Hildenbrand wrote:
> On 24.07.2018 09:25, Michal Hocko wrote:
> > On Mon 23-07-18 19:20:43, David Hildenbrand wrote:
> >> On 23.07.2018 14:30, Michal Hocko wrote:
> >>> On Mon 23-07-18 13:45:18, Vlastimil Babka wrote:
> >>>> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> >>>>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> >>>>> So reserved pages might be access by dump tools although nobody except
> >>>>> the owner should touch them.
> >>>>
> >>>> Are you sure about that? Or maybe I understand wrong. Maybe it changed
> >>>> recently, but IIRC pages that are backing memmap (struct pages) are also
> >>>> PG_reserved. And you definitely do want those in the dump.
> >>>
> >>> You are right. reserve_bootmem_region will make all early bootmem
> >>> allocations (including those backing memmaps) PageReserved. I have asked
> >>> several times but I haven't seen a satisfactory answer yet. Why do we
> >>> even care for kdump about those. If they are reserved the nobody should
> >>> really look at those specific struct pages and manipulate them. Kdump
> >>> tools are using a kernel interface to read the content. If the specific
> >>> content is backed by a non-existing memory then they should simply not
> >>> return anything.
> >>>
> >>
> >> "new kernel" provides an interface to read memory from "old kernel".
> >>
> >> The new kernel has no idea about
> >> - which memory was added/online in the old kernel
> >> - where struct pages of the old kernel are and what their content is
> >> - which memory is save to touch and which not
> >>
> >> Dump tools figure all that out by interpreting the VMCORE. They e.g.
> >> identify "struct pages" and see if they should be dumped. The "new
> >> kernel" only allows to read that memory. It cannot hinder to crash the
> >> system (e.g. if a dump tool would try to read a hwpoison page).
> >>
> >> So how should the "new kernel" know if a page can be touched or not?
> > 
> > I am sorry I am not familiar with kdump much. But from what I remember
> > it reads from /proc/vmcore and implementation of this interface should
> > simply return EINVAL or alike when you try to dump inaccessible memory
> > range.
> 
> I assume the main problem with this approach is that we would always
> have to fallback to reading old memory from vmcore page by page. e.g.
> makedumpfile will always try to read bigger bunches. I also assume the
> reason HWPOISON is handled in dump tools instead of in the kernel using
> the mechanism you describe is the case.

Is falling back to page-by-page for some ranges a real problem? I mean
most of pages will simply be there so you can go in larger chunks. Once
you get EINVAL, you just fall back to page-by-page for that particular
range.
-- 
Michal Hocko
SUSE Labs
