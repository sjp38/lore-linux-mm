Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 296CB6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:37:57 -0400 (EDT)
Received: by wgen6 with SMTP id n6so144427480wge.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 02:37:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cr5si20439102wjb.214.2015.04.28.02.37.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 02:37:55 -0700 (PDT)
Date: Tue, 28 Apr 2015 10:37:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/13] mm: meminit: Make __early_pfn_to_nid SMP-safe and
 introduce meminit_pfn_in_nid
Message-ID: <20150428093751.GJ2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429785196-7668-6-git-send-email-mgorman@suse.de>
 <20150427154333.85a1fd2dbc38c7c0888fd4f5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150427154333.85a1fd2dbc38c7c0888fd4f5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 03:43:33PM -0700, Andrew Morton wrote:
> On Thu, 23 Apr 2015 11:33:08 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > __early_pfn_to_nid() in the generic and arch-specific implementations
> > use static variables to cache recent lookups. Without the cache
> > boot times are much higher due to the excessive memblock lookups but
> > it assumes that memory initialisation is single-threaded. Parallel
> > initialisation of struct pages will break that assumption so this patch
> > makes __early_pfn_to_nid() SMP-safe by requiring the caller to cache
> > recent search information. early_pfn_to_nid() keeps the same interface
> > but is only safe to use early in boot due to the use of a global static
> > variable. meminit_pfn_in_nid() is an SMP-safe version that callers must
> > maintain their own state for.
> 
> Seems a bit awkward.
> 

I'm afraid I don't understand which part you mean.

> > +struct __meminitdata mminit_pfnnid_cache global_init_state;
> > +
> > +/* Only safe to use early in boot when initialisation is single-threaded */
> >  int __meminit early_pfn_to_nid(unsigned long pfn)
> >  {
> >  	int nid;
> >  
> > -	nid = __early_pfn_to_nid(pfn);
> > +	/* The system will behave unpredictably otherwise */
> > +	BUG_ON(system_state != SYSTEM_BOOTING);
> 
> Because of this.
> 
> Providing a cache per cpu:
> 
> struct __meminitdata mminit_pfnnid_cache global_init_state[NR_CPUS];
> 
> would be simpler?
> 

It would be simplier in terms of implementation but it's wasteful. We
only need a small number of these caches early in boot. NR_CPUS is
potentially very large.

> 
> Also, `global_init_state' is a poor name for a kernel-wide symbol.

You're right. It's not really global, it's just the one that is used if
the caller does not track their own state. It should have been static and
I renamed it to early_pfnnid_cache.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
