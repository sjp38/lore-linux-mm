Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 175276B0394
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:34:36 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d34so7098727otb.10
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 10:34:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9-v6sor10351825oif.163.2018.10.29.10.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 10:34:34 -0700 (PDT)
MIME-Version: 1.0
References: <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
 <20181010185242.GP5873@dhcp22.suse.cz> <20181011085509.GS5873@dhcp22.suse.cz>
 <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com> <20181017075257.GF18839@dhcp22.suse.cz>
 <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com> <20181029141210.GJ32673@dhcp22.suse.cz>
 <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
 <20181029163528.GL32673@dhcp22.suse.cz> <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
 <20181029172415.GM32673@dhcp22.suse.cz>
In-Reply-To: <20181029172415.GM32673@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Oct 2018 10:34:22 -0700
Message-ID: <CAPcyv4goFsZR=O-P_KGrjV8hz0H=nqgYPGSGGLEnmtcagoTYrA@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: alexander.h.duyck@linux.intel.com, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Mon, Oct 29, 2018 at 10:24 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-10-18 10:01:28, Alexander Duyck wrote:
> > On Mon, 2018-10-29 at 17:35 +0100, Michal Hocko wrote:
[..]
> > > You are already doing per-page initialization so I fail to see a larger
> > > unit to operate on.
> >
> > I have a patch that makes it so that we can work at a pageblock level
> > since all of the variables with the exception of only the LRU and page
> > address fields can be precomputed. Doing that is one of the ways I was
> > able to reduce page init to 1/3 to 1/4 of the time it was taking
> > otherwise in the case of deferred page init.
>
> You still have to call set_page_links for each page. But let's assume we
> can do initialization per larger units. Nothing really prevent to hide
> that into constructor as well.

A constructor / indirect function call makes sense when there are
multiple sub-classes of object initialization, on the table I only see
3 cases: typical hotplug, base ZONE_DEVICE, ZONE_DEVICE + HMM. I think
we can look to move the HMM special casing out of line, then we're
down to 2. Even at 3 cases we're better off open-coding than a
constructor for such a low number of sub-cases to handle. I do not
foresee more cases arriving, so I struggle to see what the constructor
buys us in terms of code readability / maintainability?
