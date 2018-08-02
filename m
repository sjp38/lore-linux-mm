Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAFD6B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 04:50:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g5-v6so580493edp.1
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 01:50:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18-v6si1202062eds.294.2018.08.02.01.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 01:50:45 -0700 (PDT)
Date: Thu, 2 Aug 2018 10:50:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180802085043.GC10808@dhcp22.suse.cz>
References: <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Wed 01-08-18 19:03:03, Georgi Nikolov wrote:
> 
> *Georgi Nikolov*
> System Administrator
> www.icdsoft.com <http://www.icdsoft.com>
> 
> On 08/01/2018 11:33 AM, Michal Hocko wrote:
> > On Wed 01-08-18 09:34:23, Vlastimil Babka wrote:
> >> On 07/31/2018 04:05 PM, Florian Westphal wrote:
> >>> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
> >>>>> No, I think that's rather for the netfilter folks to decide. However, it
> >>>>> seems there has been the debate already [1] and it was not found. The
> >>>>> conclusion was that __GFP_NORETRY worked fine before, so it should work
> >>>>> again after it's added back. But now we know that it doesn't...
> >>>>>
> >>>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u
> >>>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
> >>>> already in this list so probably have to wait for their opinion.
> >>> It hasn't changed, I think having OOM killer zap random processes
> >>> just because userspace wants to import large iptables ruleset is not a
> >>> good idea.
> >> If we denied the allocation instead of OOM (e.g. by using
> >> __GFP_RETRY_MAYFAIL), a slightly smaller one may succeed, still leaving
> >> the system without much memory, so it will invoke OOM killer sooner or
> >> later anyway.
> >>
> >> I don't see any silver-bullet solution, unfortunately. If this can be
> >> abused by (multiple) namespaces, then they have to be contained by
> >> kmemcg as that's the generic mechanism intended for this. Then we could
> >> use the __GFP_RETRY_MAYFAIL.
> >> The only limit we could impose to outright deny the allocation (to
> >> prevent obvious bugs/admin mistakes or abuses) could be based on the
> >> amount of RAM, as was suggested in the old thread.
> 
> Can we make this configurable - on/off switch or size above which
> to pass GFP_NORETRY.

Yet another tunable? How do you decide which one to select? Seriously,
configuration knobs sound attractive but they are rarely a good idea.
Either we trust privileged users or we don't and we have kmem accounting
for that.

> Probably hard coded based on amount of RAM is a good idea too.

How do you scale that?

In other words, why don't we simply do the following? Note that this is
not tested. I have also no idea what is the lifetime of this allocation.
Is it bound to any specific process or is it a namespace bound? If the
later then the memcg OOM killer might wipe the whole memcg down without
making any progress. This would make the whole namespace unsuable until
somebody intervenes. Is this acceptable?
---
