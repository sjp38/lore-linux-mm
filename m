Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 811766B000E
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:27:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w18-v6so789440plp.3
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:27:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o23-v6si683749pgv.518.2018.07.26.01.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:27:28 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:27:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-ID: <20180726082723.GB28386@dhcp22.suse.cz>
References: <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <8eb22489-fa6b-9825-bc63-07867a40d59b@redhat.com>
 <20180724131343.GK28386@dhcp22.suse.cz>
 <af5353ee-319e-17ec-3a39-df997a5adf43@redhat.com>
 <20180724133530.GN28386@dhcp22.suse.cz>
 <6c753cae-f8b6-5563-e5ba-7c1fefdeb74e@redhat.com>
 <20180725135147.GN28386@dhcp22.suse.cz>
 <344d5f15-c621-9973-561e-6ed96b29ea88@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <344d5f15-c621-9973-561e-6ed96b29ea88@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Wed 25-07-18 16:20:41, David Hildenbrand wrote:
> On 25.07.2018 15:51, Michal Hocko wrote:
> > On Tue 24-07-18 16:13:09, David Hildenbrand wrote:
> > [...]
> >> So I see right now:
> >>
> >> - Pg_reserved + e.g. new page type (or some other unique identifier in
> >>   combination with Pg_reserved)
> >>  -> Avoid reads of pages we know are offline
> >> - extend is_ram_page()
> >>  -> Fake zero memory for pages we know are offline
> >>
> >> Or even both (avoid reading and don't crash the kernel if it is being done).
> > 
> > I really fail to see how that can work without kernel being aware of
> > PageOffline. What will/should happen if you run an old kdump tool on a
> > kernel with this partially offline memory?
> > 
> 
> New kernel with old dump tool:
> 
> a) we have not fixed up is_ram_page()
> 
> -> crash, as we access memory we shouldn't

this is not acceptable, right? You do not want to crash your crash
kernel ;)

> b) we have fixed up is_ram_page()
> 
> -> We have a callback to check for applicable memory in the hypervisor
> whether the parts are accessible / online or not accessible / offline.
> (e.g. via a device driver that controls a certain memory region)
> 
> -> Don't read, but fake a page full of 0
> 
> 
> So instead of the kernel being aware of it, it asks via is_ram_page()
> the hypervisor.

I am still confused why do we even care about hypervisor. What if
somebody wants to have partial memory hotplug on native OS?
 
> I don't think a) is a problem. AFAICS, we have to update makedumpfile
> for every new kernel. We can perform changes and update makedumpfile
> to be compatible with new dump tools.

Not really. You simply do not crash the kernel just because you are
trying to dump the already crashed kernel.

> E.g. remember SECTION_IS_ONLINE you introduced ? It broke dump
> tools and required

But has it crashed the kernel when reading the dump? If yes then the
whole dumping is fragile as hell...
-- 
Michal Hocko
SUSE Labs
