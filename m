Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 120126B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 03:32:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 77so4952285wmm.13
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 00:32:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o32si378453wrb.186.2017.06.09.00.32.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 00:32:47 -0700 (PDT)
Date: Fri, 9 Jun 2017 09:32:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170609073244.GA21764@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <20170603022440.GA11080@WeideMacBook-Pro.local>
 <20170605064343.GE9248@dhcp22.suse.cz>
 <20170606030401.GA2259@WeideMacBook-Pro.local>
 <20170606120314.GL1189@dhcp22.suse.cz>
 <20170607015909.GA6596@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170607015909.GA6596@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 07-06-17 10:10:36, Wei Yang wrote:
[...]
> Hmm... Let me be more specific. With two factors, costly or not, flag set or
> not, we have four combinations. Here it is classified into two categories.
> 
> 1. __GFP_RETRY_MAYFAIL not set
> 
> Brief description on behavior:
>     costly: pick up the shortcut, so no OOM
>     !costly: no shortcut and will OOM I think
> 
> Impact from this patch set:
>     No.

true

> My personal understanding:
>     The allocation without __GFP_RETRY_MAYFAIL is not effected by this patch
>     set.  Since !costly allocation will trigger OOM, this is the reason why
>     "small allocations never fail _practically_", as mentioned in
>     https://lwn.net/Articles/723317/.
> 
> 
> 3. __GFP_RETRY_MAYFAIL set
> 
> Brief description on behavior:
>     costly/!costly: no shortcut here and no OOM invoked
> 
> Impact from this patch set:
>     For those allocations with __GFP_RETRY_MAYFAIL, OOM is not invoked for
>     both.

yes

> My personal understanding:
>     This is the semantic you are willing to introduce in this patch set. By
>     cutting off the OOM invoke when __GFP_RETRY_MAYFAIL is set, you makes this
>     a middle situation between NOFAIL and NORETRY.

yes

>     page_alloc will try some luck to get some free pages without disturb other
>     part of the system. By doing so, the never fail allocation for !costly
>     pages will be "fixed". If I understand correctly, you are willing to make
>     this the default behavior in the future?

I do not think we can make this a default in a foreseeable future
unfortunately. That's why I've made it a gfp modifier in the first
place. I assume many users will opt in by using the flag. In future we
can even help by adding a highlevel GFP_$FOO flag but I am worried that
this would just add to the explosion of existing highlevel gfp masks
(e.g. do we want GFP_NOFS_MAY_FAIL, GFP_USER_MAY_FAIL,
GFP_USER_HIGH_MOVABLE_MAYFAIL etc...)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
