Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F32C6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 15:38:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so109585196pfl.6
        for <linux-mm@kvack.org>; Mon, 15 May 2017 12:38:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si4536482plc.82.2017.05.15.12.38.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 12:38:23 -0700 (PDT)
Date: Mon, 15 May 2017 21:38:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170515193817.GC7551@dhcp22.suse.cz>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Mon 15-05-17 14:12:10, Pasha Tatashin wrote:
> Hi Michal,
> 
> After looking at your suggested memblock_virt_alloc_core() change again, I
> decided to keep what I have. I do not want to inline
> memblock_virt_alloc_internal(), because it is not a performance critical
> path, and by inlining it we will unnecessarily increase the text size on all
> platforms.

I do not insist but I would really _prefer_ if the bool zero argument
didn't proliferate all over the memblock API.
 
> Also, because it will be very hard to make sure that no platform regresses
> by making memset() default in _memblock_virt_alloc_core() (as I already
> showed last week at least sun4v SPARC64 will require special changes in
> order for this to work), I decided to make it available only for "deferred
> struct page init" case. As, what is already in the patch.

I do not think this is the right approach. Your measurements just show
that sparc could have a more optimized memset for small sizes. If you
keep the same memset only for the parallel initialization then you
just hide this fact. I wouldn't worry about other architectures. All
sane architectures should simply work reasonably well when touching a
single or only few cache lines at the same time. If some arches really
suffer from small memsets then the initialization should be driven by a
specific ARCH_WANT_LARGE_PAGEBLOCK_INIT rather than making this depend
on DEFERRED_INIT. Or if you are too worried then make it opt-in and make
it depend on ARCH_WANT_PER_PAGE_INIT and make it enabled for x86 and
sparc after memset optimization.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
