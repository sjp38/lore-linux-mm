Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2D36B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:53:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 198so368280wmg.6
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:53:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si5260934edd.36.2017.11.03.06.53.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 06:53:51 -0700 (PDT)
Date: Fri, 3 Nov 2017 14:53:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm: buddy page accessed before initialized
Message-ID: <20171103135349.gsotgdjwo5sqe47y@dhcp22.suse.cz>
References: <20171102170221.7401-1-pasha.tatashin@oracle.com>
 <20171102170221.7401-2-pasha.tatashin@oracle.com>
 <20171103092703.63qyafmg7rnpoqab@dhcp22.suse.cz>
 <CAOAebxvXz2+N36QLo5xdJzbCfCPeC5E3a1p0PBTtN5ZXNNYG8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxvXz2+N36QLo5xdJzbCfCPeC5E3a1p0PBTtN5ZXNNYG8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri 03-11-17 09:47:30, Pavel Tatashin wrote:
> Hi Michal,
> 
> There is a small regression, on the largest x86 machine I have access to:
> Before:
> node 1 initialised, 32471632 pages in 901ms
> After:
> node 1 initialised, 32471632 pages in 1128ms
> 
> One node contains 128G of memory (overal 1T in 8 nodes). This
> regression is going to be solved by this work:
> https://patchwork.kernel.org/patch/9920953/, other than that I do not
> know a better solution. The overall performance is still much better
> compared to before this project.

OK, I think that is completely acceptable for now. We can always
optimize for a better result later.

> Also, thinking about this problem some more, it is safer to split the
> initialization, and freeing parts into two functions:
> 
> In deferred_init_memmap()
> 1574         for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> 1575                 spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> 1576                 epfn = min_t(unsigned long, zone_end_pfn(zone),
> PFN_DOWN(epa));
> 1577                 nr_pages += deferred_init_range(nid, zid, spfn, epfn);
> 1578         }
> 
> Replace with two loops:
> First loop, calls a function that initializes the given range, the 2nd
> loop calls a function that frees it. This way we won't get a potential
> problem where buddy page is computed from the next range that has not
> yet been initialized. And it is also going to be easier to multithread
> later: multi-thread the first loop, wait for it to finish,
> multi-thread the 2nd loop wait for it to finish.

OK, but let's do that as a separate patch. What you have here is good
for now IMHO. My ack applies. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
