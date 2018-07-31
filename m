Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A37716B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:17:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y18-v6so1585717wma.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:17:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15-v6sor365846wmc.64.2018.07.31.06.17.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 06:17:44 -0700 (PDT)
Date: Tue, 31 Jul 2018 15:17:42 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731131742.GB473@techadventures.net>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731130434.GL4557@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731130434.GL4557@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 03:04:34PM +0200, Michal Hocko wrote:
> On Tue 31-07-18 08:49:11, Pavel Tatashin wrote:
> > Hi Oscar,
> > 
> > Have you looked into replacing __paginginit via __meminit ? What is
> > the reason to keep both?
> 
> All these init variants make my head spin so reducing their number is
> certainly a desirable thing to do. b5a0e01132943 has added this variant
> so it might give a clue about the dependencies.

Looking at b5a0e011329431b90d315eaf6ca5fdb41df7a117, I cannot really see why
this was not done in init.h
Maybe the comitter did not want to hack directly into __meminit.

I think that __paginginit was a way to abstract the whole thing without having
to modify init.h directly.

I guess we could get rid of it and so something like:

#ifdef CONFIG_MEMORY_HOTPLUG
 #define __meminit        __section(.meminit.text) __cold notrace \
                                                  __latent_entropy
#else
#define __meminit       __init
#endif

And then we would have to replace __paginginit with __meminit.

But honestly, puting an #ifdef in init.h feels a bit wierd to me,
although I do not really have a strong opinion here.

Thanks
-- 
Oscar Salvador
SUSE L3
