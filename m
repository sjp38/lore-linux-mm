Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C14AD6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 06:45:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 134so2702130wmj.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 03:45:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s62si1794715wms.146.2017.02.22.03.45.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 03:45:23 -0800 (PST)
Date: Wed, 22 Feb 2017 12:45:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170222114521.GJ5753@dhcp22.suse.cz>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
 <20170209135929.GA59297@WeideMacBook-Pro.local>
 <20170222084947.GE5753@dhcp22.suse.cz>
 <20170222105131.GA57616@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222105131.GA57616@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-02-17 18:51:31, Wei Yang wrote:
> On Wed, Feb 22, 2017 at 09:49:47AM +0100, Michal Hocko wrote:
> >On Thu 09-02-17 21:59:29, Wei Yang wrote:
> >> On Tue, Feb 07, 2017 at 04:41:21PM +0100, Michal Hocko wrote:
> >> >On Tue 07-02-17 23:32:47, Wei Yang wrote:
> >> >> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
> >> >[...]
> >> >> >Is there any reason why for_each_mem_pfn_range cannot be changed to
> >> >> >honor the given start/end pfns instead? I can imagine that a small zone
> >> >> >would see a similar pointless iterations...
> >> >> >
> >> >> 
> >> >> Hmm... No special reason, just not thought about this implementation. And
> >> >> actually I just do the similar thing as in zone_spanned_pages_in_node(), in
> >> >> which also return 0 when there is no overlap.
> >> >> 
> >> >> BTW, I don't get your point. You wish to put the check in
> >> >> for_each_mem_pfn_range() definition?
> >> >
> >> >My point was that you are handling one special case (an empty zone) but
> >> >the underlying problem is that __absent_pages_in_range might be wasting
> >> >cycles iterating over memblocks that are way outside of the given pfn
> >> >range. At least this is my understanding. If you fix that you do not
> >> >need the special case, right?
> >> >-- 
> >> >Michal Hocko
> >> >SUSE Labs
> >> 
> >> > Not really, sorry, this area is full of awkward and subtle code when new
> >> > changes build on top of previous awkwardness/surprises. Any cleanup
> >> > would be really appreciated. That is the reason I didn't like the
> >> > initial check all that much.
> >> 
> >> Looks my fetchmail failed to get your last reply. So I copied it here.
> >> 
> >> Yes, the change here looks not that nice, while currently this is what I can't
> >> come up with.
> >
> >THen I will suggest dropping this patch from the mmotm tree because it
> >doesn't sound like a big improvement and I would encourage you or
> >anybody else to take a deeper look and unclutter this area to be more
> >readable and better maintainable.
> 
> Hi, Michal
> 
> I don't get your point, which part of the code makes you feel uncomfortable?

It adds a check which would better be handled at a different level. I've
tried to explain what are my concerns about quick&dirty solutions in
this area. I would agree to add the check as a immediate workaround if
this had some measurable benefits but the changelog doesn't mention
any. So I do not really see this as an improvement in the end. If we
want to address the suboptimal code, let's do it properly rather than
spewing ifs all over the code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
