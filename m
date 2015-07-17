Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF201280319
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:17:34 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so82027425wgk.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:17:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr2si19464858wjc.163.2015.07.17.06.17.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 06:17:33 -0700 (PDT)
Date: Fri, 17 Jul 2015 14:17:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm, meminit: Allow early_pfn_to_nid to be used
 during runtime
Message-ID: <20150717131729.GE2561@suse.de>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
 <1437135724-20110-4-git-send-email-mgorman@suse.de>
 <20150717131232.GK19282@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150717131232.GK19282@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 17, 2015 at 03:12:32PM +0200, Peter Zijlstra wrote:
> On Fri, Jul 17, 2015 at 01:22:04PM +0100, Mel Gorman wrote:
> >  int __meminit early_pfn_to_nid(unsigned long pfn)
> >  {
> > +	static DEFINE_SPINLOCK(early_pfn_lock);
> >  	int nid;
> >  
> > -	/* The system will behave unpredictably otherwise */
> > -	BUG_ON(system_state != SYSTEM_BOOTING);
> > +	/* Avoid locking overhead during boot but hotplug must lock */
> > +	if (system_state != SYSTEM_BOOTING)
> > +		spin_lock(&early_pfn_lock);
> >  
> >  	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
> > -	if (nid >= 0)
> > -		return nid;
> > -	/* just returns 0 */
> > -	return 0;
> > +	if (nid < 0)
> > +		nid = 0;
> > +
> > +	if (system_state != SYSTEM_BOOTING)
> > +		spin_unlock(&early_pfn_lock);
> > +
> > +	return nid;
> >  }
> 
> Why the conditional locking?

Unnecessary during boot when it's inherently serialised. The point of
the deferred initialisation was to boot as quickly as possible.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
