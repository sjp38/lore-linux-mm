Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8D2440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:03:21 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k192so103000261ith.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:03:21 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id p132si1672318itb.11.2017.07.14.02.03.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 02:03:20 -0700 (PDT)
Message-ID: <1500022977.2865.88.camel@kernel.crashing.org>
Subject: Re: Potential race in TLB flush batching?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 14 Jul 2017 19:02:57 +1000
In-Reply-To: <20170714083114.zhaz3pszrklnrn52@suse.de>
References: <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
	 <20170711092935.bogdb4oja6v7kilq@suse.de>
	 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
	 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
	 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
	 <20170711155312.637eyzpqeghcgqzp@suse.de>
	 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
	 <20170711191823.qthrmdgqcd3rygjk@suse.de>
	 <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
	 <1500015641.2865.81.camel@kernel.crashing.org>
	 <20170714083114.zhaz3pszrklnrn52@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, 2017-07-14 at 09:31 +0100, Mel Gorman wrote:
> It may also be only a gain on a limited number of architectures depending
> on exactly how an architecture handles flushing. At the time, batching
> this for x86 in the worse-case scenario where all pages being reclaimed
> were mapped from multiple threads knocked 24.4% off elapsed run time and
> 29% off system CPU but only on multi-socket NUMA machines. On UMA, it was
> barely noticable. For some workloads where only a few pages are mapped or
> the mapped pages on the LRU are relatively sparese, it'll make no difference.
> 
> The worst-case situation is extremely IPI intensive on x86 where many
> IPIs were being sent for each unmap. It's only worth even considering if
> you see that the time spent sending IPIs for flushes is a large portion
> of reclaim.

Ok, it would be interesting to see how that compares to powerpc with
its HW tlb invalidation broadcasts. We tend to hate them and prefer
IPIs in most cases but maybe not *this* case .. (mostly we find that
IPI + local inval is better for large scale invals, such as full mm on
exit/fork etc...).

In the meantime I found the original commits, we'll dig and see if it's
useful for us.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
