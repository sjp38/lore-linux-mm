Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F09D16B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:30:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o60-v6so373802edd.13
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:30:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13-v6si143795edb.49.2018.07.23.05.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 05:30:44 -0700 (PDT)
Date: Mon, 23 Jul 2018 14:30:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180723123043.GD31229@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Mon 23-07-18 13:45:18, Vlastimil Babka wrote:
> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> > Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> > So reserved pages might be access by dump tools although nobody except
> > the owner should touch them.
> 
> Are you sure about that? Or maybe I understand wrong. Maybe it changed
> recently, but IIRC pages that are backing memmap (struct pages) are also
> PG_reserved. And you definitely do want those in the dump.

You are right. reserve_bootmem_region will make all early bootmem
allocations (including those backing memmaps) PageReserved. I have asked
several times but I haven't seen a satisfactory answer yet. Why do we
even care for kdump about those. If they are reserved the nobody should
really look at those specific struct pages and manipulate them. Kdump
tools are using a kernel interface to read the content. If the specific
content is backed by a non-existing memory then they should simply not
return anything.
-- 
Michal Hocko
SUSE Labs
