Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C341F6B039A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:45:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q10-v6so7837671edd.20
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 10:45:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h28-v6si2846307edb.288.2018.10.29.10.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 10:45:51 -0700 (PDT)
Date: Mon, 29 Oct 2018 18:45:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181029174549.GN32673@dhcp22.suse.cz>
References: <20181011085509.GS5873@dhcp22.suse.cz>
 <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
 <20181017075257.GF18839@dhcp22.suse.cz>
 <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
 <20181029141210.GJ32673@dhcp22.suse.cz>
 <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz>
 <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz>
 <CAPcyv4goFsZR=O-P_KGrjV8hz0H=nqgYPGSGGLEnmtcagoTYrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4goFsZR=O-P_KGrjV8hz0H=nqgYPGSGGLEnmtcagoTYrA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Mon 29-10-18 10:34:22, Dan Williams wrote:
> On Mon, Oct 29, 2018 at 10:24 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 29-10-18 10:01:28, Alexander Duyck wrote:
> > > On Mon, 2018-10-29 at 17:35 +0100, Michal Hocko wrote:
> [..]
> > > > You are already doing per-page initialization so I fail to see a larger
> > > > unit to operate on.
> > >
> > > I have a patch that makes it so that we can work at a pageblock level
> > > since all of the variables with the exception of only the LRU and page
> > > address fields can be precomputed. Doing that is one of the ways I was
> > > able to reduce page init to 1/3 to 1/4 of the time it was taking
> > > otherwise in the case of deferred page init.
> >
> > You still have to call set_page_links for each page. But let's assume we
> > can do initialization per larger units. Nothing really prevent to hide
> > that into constructor as well.
> 
> A constructor / indirect function call makes sense when there are
> multiple sub-classes of object initialization, on the table I only see
> 3 cases: typical hotplug, base ZONE_DEVICE, ZONE_DEVICE + HMM. I think
> we can look to move the HMM special casing out of line, then we're
> down to 2. Even at 3 cases we're better off open-coding than a
> constructor for such a low number of sub-cases to handle. I do not
> foresee more cases arriving, so I struggle to see what the constructor
> buys us in terms of code readability / maintainability?

I haven't dreamed of ZONE_DEVICE and HMM few years back. But anyway,
let me note that I am not in love with callbacks. I find them to be a
useful abstraction. I can be convinced (by numbers) that special casing
inside the core hotplug code is really beneficial. But let's do that at
a single place.

All I am arguing against throughout this thread is the
memmap_init_zone_device and the whole code duplication just because zone
device need something special.

-- 
Michal Hocko
SUSE Labs
