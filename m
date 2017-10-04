Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 149126B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:48:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so11992576pfc.7
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:48:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si7634239pgr.641.2017.10.04.01.48.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 01:48:19 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:48:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 03/12] mm: deferred_init_memmap improvements
Message-ID: <20171004084816.ljyw2gdf5gmgtm7z@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-4-pasha.tatashin@oracle.com>
 <20171003125754.2kuqzkstywg7axhd@dhcp22.suse.cz>
 <fc4ef789-d9a8-5dab-6508-f0fe8751b462@oracle.com>
 <d81baa49-b796-7130-4ace-0f14ed59be46@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d81baa49-b796-7130-4ace-0f14ed59be46@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Tue 03-10-17 12:01:08, Pasha Tatashin wrote:
> Hi Michal,
> 
> Are you OK, if I replace DEFERRED_FREE() macro with a function like this:
> 
> /*
>  * Helper for deferred_init_range, free the given range, and reset the
>  * counters
>  */
> static inline unsigned long __def_free(unsigned long *nr_free,
>                                        unsigned long *free_base_pfn,
>                                        struct page **page)
> {
>         unsigned long nr = *nr_free;
> 
>         deferred_free_range(*free_base_pfn, nr);
>         *free_base_pfn = 0;
>         *nr_free = 0;
>         *page = NULL;
> 
>         return nr;
> }
> 
> Since it is inline, and we operate with non-volatile counters, compiler will
> be smart enough to remove all the unnecessary de-references. As a plus, we
> won't be adding any new branches, and the code is still going to stay
> compact.

OK. It is a bit clunky but we are holding too much state there. I
haven't checked whether that can be simplified but this can be always
done later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
