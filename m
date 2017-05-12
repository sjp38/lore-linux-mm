Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E44E6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:56:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j28so29397758pfk.14
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:56:19 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id l193si3849652pga.7.2017.05.12.09.56.18
        for <linux-mm@kvack.org>;
        Fri, 12 May 2017 09:56:18 -0700 (PDT)
Date: Fri, 12 May 2017 12:56:16 -0400 (EDT)
Message-Id: <20170512.125616.2184259340380386583.davem@davemloft.net>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <9088ad7e-8b3b-8eba-2fdf-7b0e36e4582e@oracle.com>
References: <20170510145726.GM31466@dhcp22.suse.cz>
	<ab667486-54a0-a36e-6797-b5f7b83c10f7@oracle.com>
	<9088ad7e-8b3b-8eba-2fdf-7b0e36e4582e@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com

From: Pasha Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 11 May 2017 16:47:05 -0400

> So, moving memset() into __init_single_page() benefits Intel. I am
> actually surprised why memset() is so slow on intel when it is called
> from memblock. But, hurts SPARC, I guess these membars at the end of
> memset() kills the performance.

Perhaps an x86 expert can chime in, but it might be the case that past
a certain size, the microcode for the enhanced stosb uses non-temporal
stores or something like that.

As for sparc64, yes we can get really killed by the transactional cost
of memset because of the membars.

But I wonder, for a single page struct, if we even use the special
stores and thus eat the membar cost.  struct page is only 64 bytes,
and the cutoff in the Niagara4 bzero implementation is "64 + (64 - 8)"
so indeed the initializing stores will not even be used.

So sparc64 will only use initializing stores and do the membars if
at least 2 pages are cleared at a time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
