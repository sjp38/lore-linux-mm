Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 513CB2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:19:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d127so27470930pga.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:19:46 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id 1si3340807pgq.372.2017.05.10.08.19.45
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 08:19:45 -0700 (PDT)
Date: Wed, 10 May 2017 11:19:43 -0400 (EDT)
Message-Id: <20170510.111943.1940354761418085760.davem@davemloft.net>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170510145726.GM31466@dhcp22.suse.cz>
References: <20170510072419.GC31466@dhcp22.suse.cz>
	<3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
	<20170510145726.GM31466@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: pasha.tatashin@oracle.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 10 May 2017 16:57:26 +0200

> Have you measured that? I do not think it would be super hard to
> measure. I would be quite surprised if this added much if anything at
> all as the whole struct page should be in the cache line already. We do
> set reference count and other struct members. Almost nobody should be
> looking at our page at this time and stealing the cache line. On the
> other hand a large memcpy will basically wipe everything away from the
> cpu cache. Or am I missing something?

I guess it might be clearer if you understand what the block
initializing stores do on sparc64.  There are no memory accesses at
all.

The cpu just zeros out the cache line, that's it.

No L3 cache line is allocated.  So this "wipe everything" behavior
will not happen in the L3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
