Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57C836B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 02:10:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g61-v6so69266plb.10
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 23:10:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p64si6676446pga.492.2018.04.05.23.09.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 23:09:59 -0700 (PDT)
Date: Fri, 6 Apr 2018 08:09:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __GFP_LOW
Message-ID: <20180406060953.GA8286@dhcp22.suse.cz>
References: <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz>
 <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz>
 <20180405201557.GA3666@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405201557.GA3666@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Thu 05-04-18 13:15:57, Matthew Wilcox wrote:
> On Thu, Apr 05, 2018 at 08:54:44PM +0200, Michal Hocko wrote:
[...]
> >From a "user guide" perspective:
> 
> When allocating memory, you can choose:

OK, we already split the documentation into these categories. So we got
at least the structure right ;)
 
>  - What kind of memory to allocate (DMA, NORMAL, HIGHMEM)
>  - Where to get the pages from
>    - Local node only (THISNODE)
>    - Only in compliance with cpuset policy (HARDWALL)
>    - Spread the pages between zones (WRITE)
>    - The movable zone (MOVABLE)
>    - The reclaimable zone (RECLAIMABLE)
>  - What you are willing to do if no free memory is available:
>    - Nothing at all (NOWAIT)
>    - Use my own time to free memory (DIRECT_RECLAIM)
>      - But only try once (NORETRY)
>      - Can call into filesystems (FS)
>      - Can start I/O (IO)
>      - Can sleep (!ATOMIC)
>    - Steal time from other processes to free memory (KSWAPD_RECLAIM)

What does that mean? If I drop the flag, do not steal? Well I do because
they will hit direct reclaim sooner...

>    - Kill other processes to get their memory (!RETRY_MAYFAIL)

Not really for costly orders.

>    - All of the above, and wait forever (NOFAIL)
>    - Take from emergency reserves (HIGH)
>    - ... but not the last parts of the regular reserves (LOW)

What does that mean and how it is different from NOWAIT? Is this about
the low watermark and if yes do we want to teach users about this and
make the whole thing even more complicated?  Does it wake
kswapd? What is the eagerness ordering? LOW, NOWAIT, NORETRY,
RETRY_MAYFAIL, NOFAIL?

-- 
Michal Hocko
SUSE Labs
