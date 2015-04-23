Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2F76B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:30:46 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so16428917wic.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:30:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si15077901wix.109.2015.04.23.09.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 09:30:44 -0700 (PDT)
Date: Thu, 23 Apr 2015 17:30:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v3
Message-ID: <20150423163039.GB2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429804437.24139.3@cpanel21.proisp.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1429804437.24139.3@cpanel21.proisp.no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On Thu, Apr 23, 2015 at 11:53:57PM +0800, Daniel J Blueman wrote:
> On Thu, Apr 23, 2015 at 6:33 PM, Mel Gorman <mgorman@suse.de> wrote:
> >The big change here is an adjustment to the topology_init path
> >that caused
> >soft lockups on Waiman and Daniel Blue had reported it was an
> >expensive
> >function.
> >
> >Changelog since v2
> >o Reduce overhead of topology_init
> >o Remove boot-time kernel parameter to enable/disable
> >o Enable on UMA
> >
> >Changelog since v1
> >o Always initialise low zones
> >o Typo corrections
> >o Rename parallel mem init to parallel struct page init
> >o Rebase to 4.0
> []
> 
> Splendid work! On this 256c setup, topology_init now takes 185ms.
> 
> This brings the kernel boot time down to 324s [1].

Good stuff. Am I correct in thinking that the vanilla kernel takes 732s?

> It turns out that
> one memset is responsible for most of the time setting up the the
> PUDs and PMDs; adapting memset to using non-temporal writes [3]
> avoids generating RMW cycles, bringing boot time down to 186s [2].
> 
> If this is a possibility, I can split this patch and map other
> arch's memset_nocache to memset, or change the callsite as
> preferred; comments welcome.
> 

In general, I see no problem with the patch and that it would be useful
going in before or after this series. I would suggest you splt this into
three patches. The first that is an asm-generic alias of memset_nocache
to memset with documentation saying it's optional for an architecture to
implement. The second would be your implementation for x86 that needs to
go to the x86 maintainers. The third would then be the memblock.c change.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
