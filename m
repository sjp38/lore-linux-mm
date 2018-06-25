Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90D286B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 13:53:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g22-v6so1661863eds.22
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:53:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10-v6si7085652edi.309.2018.06.25.10.53.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 10:53:15 -0700 (PDT)
Date: Mon, 25 Jun 2018 19:53:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
Message-ID: <20180625175225.GQ28965@dhcp22.suse.cz>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
 <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de>
 <1529938470.14039.134.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529938470.14039.134.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>

On Mon 25-06-18 14:56:26, Kani Toshimitsu wrote:
> On Sun, 2018-06-24 at 15:19 +0200, Thomas Gleixner wrote:
> > On Wed, 16 May 2018, Toshi Kani wrote:
> > 
> > > This series fixes two issues in the x86 ioremap free page handlings
> > > for pud/pmd mappings.
> > > 
> > > Patch 01 fixes BUG_ON on x86-PAE reported by Joerg.  It disables
> > > the free page handling on x86-PAE.
> > > 
> > > Patch 02-03 fixes a possible issue with speculation which can cause
> > > stale page-directory cache.
> > >  - Patch 02 is from Chintan's v9 01/04 patch [1], which adds a new arg
> > >    'addr', with my merge change to patch 01.
> > >  - Patch 03 adds a TLB purge (INVLPG) to purge page-structure caches
> > >    that may be cached by speculation.  See the patch descriptions for
> > >    more detal.
> > 
> > Toshi, Joerg, Michal!
> 
> Hi Thomas,
> 
> Thanks for checking. I was about to ping as well.
> 
> > I'm failing to find a conclusion of this discussion. Can we finally make
> > some progress with that?
> 
> I have not heard from Joerg since I last replied to his comments to
> Patch 3/3 -- I did my best to explain that there was no issue in the
> single page allocation in pud_free_pmd_page().  From my perspective, the
>  v3 series is good to go.

Well, I admit that this not my area but I agree with Joerg that
allocating memory inside afunction that is supposed to free page table
is far from ideal. More so that the allocation is hardcoded GFP_KERNEL.
We already have this antipattern in functions to allocate page tables
and it has turned to be maintenance PITA longterm. So if there is a way
around that then I would strongly suggest finding a different solution.

Whether that is sufficient to ditch the whole series is not my call
though.
-- 
Michal Hocko
SUSE Labs
