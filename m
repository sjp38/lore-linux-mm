Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85BDE6B7854
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 06:59:04 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h40-v6so3553726edb.2
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 03:59:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8-v6si3915845edb.116.2018.09.06.03.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 03:59:03 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2208ad4d-e5eb-fc53-cdc8-a351f2b6b9d1@suse.cz>
Date: Thu, 6 Sep 2018 12:59:00 +0200
MIME-Version: 1.0
In-Reply-To: <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On 08/30/2018 12:54 AM, Zi Yan wrote:
> 
> Thanks for your patch.
> 
> I tested it against Linusa??s tree with a??memhog -r3 130ga?? in a two-socket machine with 128GB memory on
> each node and got the results below. I expect this test should fill one node, then fall back to the other.
> 
> 1. madvise(MADV_HUGEPAGE) + defrag = {always, madvise, defer+madvise}: no swap, THPs are allocated in the fallback node.
> 2. madvise(MADV_HUGEPAGE) + defrag = defer: pages got swapped to the disk instead of being allocated in the fallback node.

Hmm this is GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE.
No direct reclaim, so it would have to be kswapd causing the swapping? I
wouldn't expect it to be significant and over-reclaiming. What exactly
is your definition of "pages got swapped"?

> 3. no madvise, THP is on by default + defrag = {always, defer, defer+madvise}: pages got swapped to the disk instead of
> being allocated in the fallback node.

So this should be the most common case (no madvise, THP on). If it's
causing too much reclaim, it's not good IMHO.

depending on defrag:
defer (the default) = same as above, so it would have to be kswapd
always = GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM | __GFP_NORETRY |
__GFP_THISNODE
  - so direct reclaim also overreclaims despite __GFP_NORETRY?
defer+madvise = same as defer

Vlastimil
