Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54B7A6B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:18:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f85so11772146pfe.7
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:18:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14si11947521pgf.310.2017.11.06.10.18.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 10:18:38 -0800 (PST)
Date: Mon, 6 Nov 2017 19:18:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap
 allocation failures
Message-ID: <20171106181835.yfngqffiuwzrjtmu@dhcp22.suse.cz>
References: <20171106092228.31098-1-mhocko@kernel.org>
 <1509992067.4140.1.camel@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1509992067.4140.1.camel@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 06-11-17 11:14:27, Khalid Aziz wrote:
> On Mon, 2017-11-06 at 10:22 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > While doing a memory hotplug tests under a heavy memory pressure we
> > have
> > noticed too many page allocation failures when allocating vmemmap
> > memmap
> > backed by huge page
> > ......... deleted .........
> > +
> > +		if (!warned) {
> > +			warn_alloc(gfp_mask, NULL, "vmemmap alloc
> > failure: order:%u", order);
> > +			warned = true;
> > +		}
> >  		return NULL;
> >  	} else
> >  		return __earlyonly_bootmem_alloc(node, size, size,
> 
> This will warn once and only once after a kernel is booted. This
> condition may happen repeatedly over a long period of time with
> significant time span between two such events and it can be useful to
> know if this is happening repeatedly. There might be better ways to
> throttle the rate of warnings, something like warn once and then
> suppress warnings for the next 15 minutes (or pick any other time
> frame). If this condition happens again later, there will be another
> warning.

While this is all true I am not sure we care all that much. The failure
mode is basically not using an optimization. This is not something we
warn normally about. Even the performance degradation is a theoretical
concern which nobody has backed by real life numbers AFAIR.

If we want to make it more sophisticated I would expect some numbers to
back such a change.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
