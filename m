Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E82746B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:06:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v102so21535321wrc.8
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 02:06:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l123si7258641wml.156.2017.06.12.02.06.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 02:06:58 -0700 (PDT)
Date: Mon, 12 Jun 2017 11:06:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170612090656.GD7476@dhcp22.suse.cz>
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-5-mhocko@kernel.org>
 <a41926b2-1e49-d6a6-f92e-5ebf2fa101e3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a41926b2-1e49-d6a6-f92e-5ebf2fa101e3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 08-06-17 10:38:06, Vlastimil Babka wrote:
> On 06/08/2017 09:45 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > alloc_huge_page_nodemask tries to allocate from any numa node in the
> > allowed node mask. This might lead to filling up low NUMA nodes while
> > others are not used. We can reduce this risk by introducing a concept
> > of the preferred node similar to what we have in the regular page
> > allocator. We will start allocating from the preferred nid and then
> > iterate over all allowed nodes until we try them all. Introduce
> > for_each_node_mask_preferred helper which does the iteration and reuse
> > the available preferred node in new_page_nodemask which is currently
> > the only caller of alloc_huge_page_nodemask.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> That's better, yeah. I don't think it would be too hard to use a
> zonelist though. What do others think?

OK, so I've given it a try. This is untested yet but it doesn't look all
that bad. dequeue_huge_page_node will most proably see some clean up on
top but I've kept it for simplicity for now.
---
