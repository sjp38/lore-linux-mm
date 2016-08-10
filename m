Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2908B6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 03:51:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so50127420wmz.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 00:51:47 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id l66si6836524wml.74.2016.08.10.00.51.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 00:51:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 9A8D299139
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:51:44 +0000 (UTC)
Date: Wed, 10 Aug 2016 08:51:43 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
Message-ID: <20160810075142.GC8119@techsingularity.net>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
 <87mvkritii.fsf@concordia.ellerman.id.au>
 <20160805072838.GF11268@linux.vnet.ibm.com>
 <87h9azin4g.fsf@concordia.ellerman.id.au>
 <20160805100609.GP2799@techsingularity.net>
 <87d1lhtb3s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87d1lhtb3s.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Aug 10, 2016 at 04:02:47PM +1000, Michael Ellerman wrote:
> > Conceptually it would be cleaner, if expensive, to calculate the real
> > memblock reserves if HASH_EARLY and ditch the dma_reserve, memory_reserve
> > and nr_kernel_pages entirely.
> 
> Why is it expensive? memblock tracks the totals for all memory and
> reserved memory AFAIK, so it should just be a case of subtracting one
> from the other?
> 

I didn't actually check that it tracks the totals. If it does, then the cost
will be negligible in comparison to the total cost of initialising memory.

> > Unfortuantely, aside from the calculation,
> > there is a potential cost due to a smaller hash table that affects everyone,
> > not just ppc64.
> 
> Yeah OK. We could make it an arch hook, or controlled by a CONFIG.
> 
> > However, if the hash table is meant to be sized on the
> > number of available pages then it really should be based on that and not
> > just a made-up number.
> 
> Yeah that seems to make sense.
> 
> The one complication I think is that we may have memory that's marked
> reserved in memblock, but is later freed to the page allocator (eg.
> initrd).
> 

It would be ideal if the amount of reserved memory that is freed later
in the normal case was estimated. If it's a small percentage of memory
then the difference is unlikely to be detectable and avoids ppc64 being
special.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
