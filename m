Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D19CE6B0380
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:56:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id u6-v6so8178458eds.10
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 08:56:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26-v6si4888193ejd.160.2018.10.29.08.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 08:56:58 -0700 (PDT)
Date: Mon, 29 Oct 2018 16:56:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181029155656.GK32673@dhcp22.suse.cz>
References: <20181010095838.GG5873@dhcp22.suse.cz>
 <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com>
 <20181010172451.GK5873@dhcp22.suse.cz>
 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
 <20181010185242.GP5873@dhcp22.suse.cz>
 <20181011085509.GS5873@dhcp22.suse.cz>
 <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
 <20181017075257.GF18839@dhcp22.suse.cz>
 <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
 <CAPcyv4gZZcuWFLzRpyJcAxtGEPTDkpwkG3J0Z4Q1u790+7W2Ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gZZcuWFLzRpyJcAxtGEPTDkpwkG3J0Z4Q1u790+7W2Ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Mon 29-10-18 08:49:46, Dan Williams wrote:
> On Wed, Oct 17, 2018 at 8:02 AM Alexander Duyck
> <alexander.h.duyck@linux.intel.com> wrote:
> >
> > On 10/17/2018 12:52 AM, Michal Hocko wrote:
> > > On Thu 11-10-18 10:38:39, Alexander Duyck wrote:
> > >> On 10/11/2018 1:55 AM, Michal Hocko wrote:
> > >>> On Wed 10-10-18 20:52:42, Michal Hocko wrote:
> > >>> [...]
> > >>>> My recollection was that we do clear the reserved bit in
> > >>>> move_pfn_range_to_zone and we indeed do in __init_single_page. But then
> > >>>> we set the bit back right afterwards. This seems to be the case since
> > >>>> d0dc12e86b319 which reorganized the code. I have to study this some more
> > >>>> obviously.
> > >>>
> > >>> so my recollection was wrong and d0dc12e86b319 hasn't really changed
> > >>> much because __init_single_page wouldn't zero out the struct page for
> > >>> the hotplug contex. A comment in move_pfn_range_to_zone explains that we
> > >>> want the reserved bit because pfn walkers already do see the pfn range
> > >>> and the page is not fully associated with the zone until it is onlined.
> > >>>
> > >>> I am thinking that we might be overzealous here. With the full state
> > >>> initialized we shouldn't actually care. pfn_to_online_page should return
> > >>> NULL regardless of the reserved bit and normal pfn walkers shouldn't
> > >>> touch pages they do not recognize and a plain page with ref. count 1
> > >>> doesn't tell much to anybody. So I _suspect_ that we can simply drop the
> > >>> reserved bit setting here.
> > >>
> > >> So this has me a bit hesitant to want to just drop the bit entirely. If
> > >> nothing else I think I may wan to make that a patch onto itself so that if
> > >> we aren't going to set it we just drop it there. That way if it does cause
> > >> issues we can bisect it to that patch and pinpoint the cause.
> > >
> > > Yes a patch on its own make sense for bisectability.
> >
> > For now I think I am going to back off of this. There is a bunch of
> > other changes that need to happen in order for us to make this work. As
> > far as I can tell there are several places that are relying on this
> > reserved bit.
> 
> When David Hildebrand and I looked it was only the hibernation code
> that we thought needed changing.

More details please?

-- 
Michal Hocko
SUSE Labs
