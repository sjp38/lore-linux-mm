Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 739A8280322
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:29:30 -0400 (EDT)
Received: by widic2 with SMTP id ic2so39395187wid.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:29:30 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id cd18si9242674wib.106.2015.07.17.06.29.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 06:29:28 -0700 (PDT)
Date: Fri, 17 Jul 2015 15:29:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm, meminit: Allow early_pfn_to_nid to be used
 during runtime
Message-ID: <20150717132922.GN19282@twins.programming.kicks-ass.net>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
 <1437135724-20110-4-git-send-email-mgorman@suse.de>
 <20150717131232.GK19282@twins.programming.kicks-ass.net>
 <20150717131729.GE2561@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717131729.GE2561@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 17, 2015 at 02:17:29PM +0100, Mel Gorman wrote:
> On Fri, Jul 17, 2015 at 03:12:32PM +0200, Peter Zijlstra wrote:
> > On Fri, Jul 17, 2015 at 01:22:04PM +0100, Mel Gorman wrote:
> > >  int __meminit early_pfn_to_nid(unsigned long pfn)
> > >  {
> > > +	static DEFINE_SPINLOCK(early_pfn_lock);
> > >  	int nid;
> > >  
> > > -	/* The system will behave unpredictably otherwise */
> > > -	BUG_ON(system_state != SYSTEM_BOOTING);
> > > +	/* Avoid locking overhead during boot but hotplug must lock */
> > > +	if (system_state != SYSTEM_BOOTING)
> > > +		spin_lock(&early_pfn_lock);
> > >  
> > >  	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
> > > -	if (nid >= 0)
> > > -		return nid;
> > > -	/* just returns 0 */
> > > -	return 0;
> > > +	if (nid < 0)
> > > +		nid = 0;
> > > +
> > > +	if (system_state != SYSTEM_BOOTING)
> > > +		spin_unlock(&early_pfn_lock);
> > > +
> > > +	return nid;
> > >  }
> > 
> > Why the conditional locking?
> 
> Unnecessary during boot when it's inherently serialised. The point of
> the deferred initialisation was to boot as quickly as possible.

Sure, but does it make a measurable difference?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
