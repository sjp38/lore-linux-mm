Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5FC6B0274
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:30:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r9-v6so509635edh.14
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:30:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18-v6si1014837edb.332.2018.07.26.01.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:30:43 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:30:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180726083042.GC28386@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
 <20180724072237.GA28386@dhcp22.suse.cz>
 <e5264f8e-2bb5-7a9b-6352-ad18f04d49c2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5264f8e-2bb5-7a9b-6352-ad18f04d49c2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Thu 26-07-18 10:22:41, David Hildenbrand wrote:
> On 24.07.2018 09:22, Michal Hocko wrote:
> > On Mon 23-07-18 19:12:58, David Hildenbrand wrote:
> >> On 23.07.2018 13:45, Vlastimil Babka wrote:
> >>> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> >>>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> >>>> So reserved pages might be access by dump tools although nobody except
> >>>> the owner should touch them.
> >>>
> >>> Are you sure about that? Or maybe I understand wrong. Maybe it changed
> >>> recently, but IIRC pages that are backing memmap (struct pages) are also
> >>> PG_reserved. And you definitely do want those in the dump.
> >>
> >> I proposed a new flag/value to mask pages that are logically offline but
> >> Michal wanted me to go into this direction.
> >>
> >> While we can special case struct pages in dump tools ("we have to
> >> read/interpret them either way, so we can also dump them"), it smells
> >> like my original attempt was cleaner. Michal?
> > 
> > But we do not have many page flags spare and even if we have one or two
> > this doesn't look like the use for them. So I still think we should try
> > the PageReserved way.
> > 
> 
> So as a summary, the only real approach that would be acceptable is
> using PageReserved + some other identifier to mark pages as "logically
> offline".
> 
> I wonder what identifier could be used, as this has to be consistent for
> all reserved pages (to avoid false positives).
> 
> Using other pageflags in combination might be possible, but then we have
> to make assumptions about all users of PageReserved right now.
> 
> As far as I can see (and as has been discussed), page_type could be
> used. If we don't want to consume a new bit, we could overload/reuse the
> "PG_balloon" bit.
> 
> 
> E.g. "PG_balloon" set -> exclude page from dump

Does each user of PG_balloon check for PG_reserved? If this is the case
then yes this would be OK.
-- 
Michal Hocko
SUSE Labs
