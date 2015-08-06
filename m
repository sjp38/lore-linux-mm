Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A7DAB6B0255
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 04:55:42 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so13636544wic.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 01:55:42 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id jy3si11449624wjb.152.2015.08.06.01.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 01:55:41 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so13635657wic.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 01:55:40 -0700 (PDT)
Message-ID: <1438851337.4626.72.camel@gmail.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Thu, 06 Aug 2015 10:55:37 +0200
In-Reply-To: <20150730165803.GA17882@Sligo.logfs.org>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
	 <20150724070420.GF4103@dhcp22.suse.cz>
	 <20150724165627.GA3458@Sligo.logfs.org>
	 <20150727070840.GB11317@dhcp22.suse.cz>
	 <20150727151814.GR9641@Sligo.logfs.org>
	 <20150728133254.GI24972@dhcp22.suse.cz>
	 <20150728170844.GY9641@Sligo.logfs.org>
	 <20150729095439.GD15801@dhcp22.suse.cz>
	 <1438269775.23663.58.camel@gmail.com>
	 <20150730165803.GA17882@Sligo.logfs.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: Michal Hocko <mhocko@kernel.org>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Thu, 2015-07-30 at 09:58 -0700, JA?rn Engel wrote:
> On Thu, Jul 30, 2015 at 05:22:55PM +0200, Mike Galbraith wrote:
> > 
> > I piddled about with the thought that it might be nice to be able to
> > sprinkle cond_resched() about to cut rt latencies without wrecking
> > normal load throughput, cobbled together a cond_resched_rt().
> > 
> > On my little box that was a waste of time, as the biggest hits are block
> > softirq and free_hot_cold_page_list().
> 
> Block softirq is one of our problems as well.  It is a bit of a joke
> that __do_softirq() moves work to ksoftirqd after 2ms, but block softirq
> can take several 100ms in bad cases.

On my little desktop box, one blk_done_softirq() loop iteration can take
up to a few milliseconds, leaving me wondering if breaking that loop
will help a studly box much.  iow, I'd like to know how bad it gets, if
one iteration can be huge, loop breaking there is fairly pointless, and
I can stop fiddling.  Do you happen to know iteration time during a size
huge block softirq hit?  On my little box, loop break/re-raise and
whatnot improves the general case substantially, but doesn't do much at
all for worst case.. or rather the next worst case in a list of unknown
length ;-)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
