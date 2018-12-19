Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 908C98E0008
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 18:39:22 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so17947157pgb.7
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:39:22 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id a11si16352078pga.198.2018.12.19.15.39.20
        for <linux-mm@kvack.org>;
        Wed, 19 Dec 2018 15:39:21 -0800 (PST)
Date: Thu, 20 Dec 2018 00:39:18 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219142528.yx6ravdyzcqp5wtd@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 19, 2018 at 02:25:28PM +0000, Wei Yang wrote:
> >-			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
> >+			skip_pages = (1 << compound_order(head)) - (page - head);
> >+			iter = round_up(iter + 1, skip_pages) - 1;
> 
> The comment of round_up says round up to next specified power of 2.  And
> second parameter must be a power of 2.
> 
> Look skip_pages not satisfy this.

I thought that gigantic pages were always allocated on 1GB aligned.
At least alloc_gigantic_page() looks for 1GB range, aligned to that.
But I see that in alloc_contig_range(), the boundaries can differ.

Anyway, unless I am missing something, I think that we could just
get rid of the round_up() and do something like:

<--
skip_pages = (1 << compound_order(head)) - (page - head);
iter = skip_pages - 1;
-->

which looks more simple IMHO.

It should just work for 2MB and 1GB Hugepages.
-- 
Oscar Salvador
SUSE L3
