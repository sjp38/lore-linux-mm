Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFA16B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:53:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x20-v6so15988374eda.21
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 00:53:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c11-v6si4014855edk.208.2018.10.17.00.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 00:52:58 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:52:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181017075257.GF18839@dhcp22.suse.cz>
References: <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
 <20181010095838.GG5873@dhcp22.suse.cz>
 <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com>
 <20181010172451.GK5873@dhcp22.suse.cz>
 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
 <20181010185242.GP5873@dhcp22.suse.cz>
 <20181011085509.GS5873@dhcp22.suse.cz>
 <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, yi.z.zhang@linux.intel.com

On Thu 11-10-18 10:38:39, Alexander Duyck wrote:
> On 10/11/2018 1:55 AM, Michal Hocko wrote:
> > On Wed 10-10-18 20:52:42, Michal Hocko wrote:
> > [...]
> > > My recollection was that we do clear the reserved bit in
> > > move_pfn_range_to_zone and we indeed do in __init_single_page. But then
> > > we set the bit back right afterwards. This seems to be the case since
> > > d0dc12e86b319 which reorganized the code. I have to study this some more
> > > obviously.
> > 
> > so my recollection was wrong and d0dc12e86b319 hasn't really changed
> > much because __init_single_page wouldn't zero out the struct page for
> > the hotplug contex. A comment in move_pfn_range_to_zone explains that we
> > want the reserved bit because pfn walkers already do see the pfn range
> > and the page is not fully associated with the zone until it is onlined.
> > 
> > I am thinking that we might be overzealous here. With the full state
> > initialized we shouldn't actually care. pfn_to_online_page should return
> > NULL regardless of the reserved bit and normal pfn walkers shouldn't
> > touch pages they do not recognize and a plain page with ref. count 1
> > doesn't tell much to anybody. So I _suspect_ that we can simply drop the
> > reserved bit setting here.
> 
> So this has me a bit hesitant to want to just drop the bit entirely. If
> nothing else I think I may wan to make that a patch onto itself so that if
> we aren't going to set it we just drop it there. That way if it does cause
> issues we can bisect it to that patch and pinpoint the cause.

Yes a patch on its own make sense for bisectability.

> > Regarding the post initialization required by devm_memremap_pages and
> > potentially others. Can we update the altmap which is already a way how
> > to get alternative struct pages by a constructor which we could call
> > from memmap_init_zone and do the post initialization? This would reduce
> > the additional loop in the caller while it would still fit the overall
> > design of the altmap and the core hotplug doesn't have to know anything
> > about DAX or whatever needs a special treatment.
> > 
> > Does that make any sense?
> 
> I think the only thing that is currently using the altmap is the ZONE_DEVICE
> memory init. Specifically I think it is only really used by the
> devm_memremap_pages version of things, and then only under certain
> circumstances. Also the HMM driver doesn't pass an altmap. What we would
> really need is a non-ZONE_DEVICE users of the altmap to really justify
> sticking with that as the preferred argument to pass.

I am not aware of any upstream HMM user so I am not sure what are the
expectations there. But I thought that ZONE_DEVICE users use altmap. If
that is not generally true then we certainly have to think about a
better interface.
 
> For those two functions it currently makes much more sense to pass the
> dev_pagemap pointer and then reference the altmap from there. Otherwise we
> are likely starting to look at something that would be more of a dirty hack
> where we are passing a unused altmap in order to get to the dev_pagemap so
> that we could populate the page.

If dev_pagemap is a general abstraction then I agree.
-- 
Michal Hocko
SUSE Labs
