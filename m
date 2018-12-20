Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9298E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:52:54 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t10so1631123plo.13
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:52:54 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id x8si17803631pll.187.2018.12.20.07.52.52
        for <linux-mm@kvack.org>;
        Thu, 20 Dec 2018 07:52:52 -0800 (PST)
Date: Thu, 20 Dec 2018 16:52:51 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220155247.qbyptzk35xr7ey72@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
 <20181220134132.6ynretwlndmyupml@d104.suse.de>
 <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
 <20181220153237.bhepsqw27mjmc4g5@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220153237.bhepsqw27mjmc4g5@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 03:32:37PM +0000, Wei Yang wrote:
> Now let's go back to see how to calculate new_iter. From the chart
> above, we can see this formula stands for all three cases:
> 
>     new_iter = round_up(iter + 1, page_size(HugePage))
> 
> So it looks the first version is correct.

Let us assume:

* iter = 0 (page first of the pageblock)
* page is a tail
* hugepage is 2mb

So we have the following:

iter = round_up(iter + 1, 1<<compound_order(head)) - 1;

which translates to:

iter = round_up(1, 512) - 1 = 511;

Then iter will be incremented to 512, and we break the loop.

The outcome of this is that ouf ot 512 pages, we only scanned 1,
and we skipped all the other 511 pages by mistake.

-- 
Oscar Salvador
SUSE L3
