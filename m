Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78D296B0748
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 19:11:20 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s123-v6so7112696qkf.12
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 16:11:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d20-v6sor10114141qtm.24.2018.11.09.16.11.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 16:11:19 -0800 (PST)
Date: Fri, 9 Nov 2018 19:11:16 -0500
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 3/7] mm: Implement new zone specific memblock
 iterator
Message-ID: <20181110001116.gtg7vxz2erbrnxc2@xakep.localdomain>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <154145278071.30046.9022571960145979137.stgit@ahduyck-desk1.jf.intel.com>
 <20181109232654.bi37bdkrqbogbdcx@xakep.localdomain>
 <d511ee6a18da13b9543557db783e6ff3327ca87b.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d511ee6a18da13b9543557db783e6ff3327ca87b.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

> > > +		unsigned long epfn = PFN_DOWN(epa);
> > > +		unsigned long spfn = PFN_UP(spa);
> > > +
> > > +		/*
> > > +		 * Verify the end is at least past the start of the zone and
> > > +		 * that we have at least one PFN to initialize.
> > > +		 */
> > > +		if (zone->zone_start_pfn < epfn && spfn < epfn) {
> > > +			/* if we went too far just stop searching */
> > > +			if (zone_end_pfn(zone) <= spfn)
> > > +				break;
> > 
> > Set *idx = U64_MAX here, then break. This way after we are outside this
> > while loop idx is always equals to U64_MAX.
> 
> Actually I think what you are asking for is the logic that is outside
> of the while loop we are breaking out of. So if you check at the end of
> the function there is the bit of code with the comment "signal end of
> iteration" where I end up setting *idx to ULLONG_MAX, *out_spfn to
> ULONG_MAX, and *out_epfn to 0.
> 
> The general idea I had with the function is that you could use either
> the index or spfn < epfn checks to determine if you keep going or not.

Yes, I meant to remove that *idx = U64_MAX after the loop, it is
confusing to have a loop:

while (*idx != U64_MAX) {
	...
}

*idx = U64_MAX;


So, it is better to set idx to U643_MAX inside the loop before the
break.

> 
> > 
> > > +
> > > +			if (out_spfn)
> > > +				*out_spfn = max(zone->zone_start_pfn, spfn);
> > > +			if (out_epfn)
> > > +				*out_epfn = min(zone_end_pfn(zone), epfn);
> > 
> > Don't we need to verify after adjustment that out_spfn != out_epfn, so
> > there is at least one PFN to initialize?
> 
> We have a few checks that I believe prevent that. Before we get to this
> point we have verified the following:
> 	zone->zone_start < epfn
> 	spfn < epfn
> 
> The other check that should be helping to prevent that is the break
> statement above that is forcing us to exit if spfn is somehow already
> past the end of the zone, that essentially maps out:
> 	spfn < zone_end_pfn(zone)
> 
> So the only check we don't have is:
> 	zone->zone_start < zone_end_pfn(zone)
> 
> If I am not mistaken that is supposed to be a given is it not? I would
> assume we don't have any zones that are completely empty or inverted
> that would be called here do we?


if (zone_end_pfn(zone) <= spfn) won't break

Equal sign in <= here takes care of the case I was thinking. Yes, logic looks good.

Thank you
Pasha
