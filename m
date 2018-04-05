Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99E986B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 05:55:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v191so1051125wmd.1
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 02:55:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n89si3738808wmi.47.2018.04.05.02.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 02:55:52 -0700 (PDT)
Date: Thu, 5 Apr 2018 11:55:50 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: call set_pageblock_order() once for each
 node
Message-ID: <20180405095550.GG6312@dhcp22.suse.cz>
References: <20180329033607.8440-1-richard.weiyang@gmail.com>
 <20180329121109.xg5tfk6dyqzkrgrh@suse.de>
 <20180330010243.GA14446@WeideMacBook-Pro.local>
 <20180403075737.GB5501@dhcp22.suse.cz>
 <20180404012734.GA1841@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404012734.GA1841@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed 04-04-18 09:27:34, Wei Yang wrote:
> On Tue, Apr 03, 2018 at 09:57:37AM +0200, Michal Hocko wrote:
> >On Fri 30-03-18 09:02:43, Wei Yang wrote:
> >> On Thu, Mar 29, 2018 at 01:11:09PM +0100, Mel Gorman wrote:
> >> >On Thu, Mar 29, 2018 at 11:36:07AM +0800, Wei Yang wrote:
> >> >> set_pageblock_order() is a standalone function which sets pageblock_order,
> >> >> while current implementation calls this function on each ZONE of each node
> >> >> in free_area_init_core().
> >> >> 
> >> >> Since free_area_init_node() is the only user of free_area_init_core(),
> >> >> this patch moves set_pageblock_order() up one level to invoke
> >> >> set_pageblock_order() only once on each node.
> >> >> 
> >> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >> >
> >> >The patch looks ok but given that set_pageblock_order returns immediately
> >> >if it has already been called, I expect the benefit is marginal. Was any
> >> >improvement in boot time measured?
> >> 
> >> No, I don't expect measurable improvement from this since the number of nodes
> >> and zones are limited.
> >> 
> >> This is just a code refine from logic point of view.
> >
> >Then, please make sure it is a real refinement. Calling this function
> >per node is only half way to get there as the function is by no means
> >per node.
> >
> 
> Hi, Michal
> 
> I guess you are willing to see this function is only called once for the whole
> system.
> 
> Yes, that is the ideal way, well I don't come up with an elegant way. The best
> way is to move this to free_area_init_nodes(), while you can see not all arch
> use this function.
> 
> Then I have two options:
> 
> A: Move this to free_area_init_nodes() for those arch using it. Call it
> specifically for those arch not using free_area_init_nodes().
> 
> B: call it before setup_arch() in start_kernel()
> 
> Hmm... which one you would prefer? If you have a better idea, that would be
> great.

or
C: do nothing and/or just document why do we call it this way
(convenience).
-- 
Michal Hocko
SUSE Labs
