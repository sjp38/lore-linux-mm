Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDDF6B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 04:05:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so4251686wrd.0
        for <linux-mm@kvack.org>; Thu, 11 May 2017 01:05:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v105si1165889wrb.306.2017.05.11.01.05.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 01:05:42 -0700 (PDT)
Date: Thu, 11 May 2017 10:05:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170511080537.GE26782@dhcp22.suse.cz>
References: <20170510072419.GC31466@dhcp22.suse.cz>
 <3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
 <20170510145726.GM31466@dhcp22.suse.cz>
 <20170510.111943.1940354761418085760.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510.111943.1940354761418085760.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: pasha.tatashin@oracle.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

On Wed 10-05-17 11:19:43, David S. Miller wrote:
> From: Michal Hocko <mhocko@kernel.org>
> Date: Wed, 10 May 2017 16:57:26 +0200
> 
> > Have you measured that? I do not think it would be super hard to
> > measure. I would be quite surprised if this added much if anything at
> > all as the whole struct page should be in the cache line already. We do
> > set reference count and other struct members. Almost nobody should be
> > looking at our page at this time and stealing the cache line. On the
> > other hand a large memcpy will basically wipe everything away from the
> > cpu cache. Or am I missing something?
> 
> I guess it might be clearer if you understand what the block
> initializing stores do on sparc64.  There are no memory accesses at
> all.
> 
> The cpu just zeros out the cache line, that's it.
> 
> No L3 cache line is allocated.  So this "wipe everything" behavior
> will not happen in the L3.

OK, good to know. My undestanding of sparc64 is close to zero.

Anyway, do you agree that doing the struct page initialization along
with other writes to it shouldn't add a measurable overhead comparing
to pre-zeroing of larger block of struct pages?  We already have an
exclusive cache line and doing one 64B write along with few other stores
should be basically the same.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
