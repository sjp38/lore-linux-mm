Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28A3F2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 10:57:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g12so9738549wrg.15
        for <linux-mm@kvack.org>; Wed, 10 May 2017 07:57:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si3734941wmh.135.2017.05.10.07.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 07:57:30 -0700 (PDT)
Date: Wed, 10 May 2017 16:57:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170510145726.GM31466@dhcp22.suse.cz>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <fae4a92c-e78c-32cb-606a-8e5087acb13f@oracle.com>
 <20170510072419.GC31466@dhcp22.suse.cz>
 <3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Wed 10-05-17 09:42:22, Pasha Tatashin wrote:
> >
> >Well, I didn't object to this particular part. I was mostly concerned
> >about
> >http://lkml.kernel.org/r/1494003796-748672-4-git-send-email-pasha.tatashin@oracle.com
> >and the "zero" argument for other functions. I guess we can do without
> >that. I _think_ that we should simply _always_ initialize the page at the
> >__init_single_page time rather than during the allocation. That would
> >require dropping __GFP_ZERO for non-memblock allocations. Or do you
> >think we could regress for single threaded initialization?
> >
> 
> Hi Michal,
> 
> Thats exactly right, I am worried that we will regress when there is no
> parallelized initialization of "struct pages" if we force unconditionally do
> memset() in __init_single_page(). The overhead of calling memset() on a
> smaller chunks (64-bytes) may cause the regression, this is why I opted only
> for parallelized case to zero this metadata. This way, we are guaranteed to
> see great improvements from this change without having regressions on
> platforms and builds that do not support parallelized initialization of
> "struct pages".

Have you measured that? I do not think it would be super hard to
measure. I would be quite surprised if this added much if anything at
all as the whole struct page should be in the cache line already. We do
set reference count and other struct members. Almost nobody should be
looking at our page at this time and stealing the cache line. On the
other hand a large memcpy will basically wipe everything away from the
cpu cache. Or am I missing something?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
