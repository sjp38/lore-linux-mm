Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF55A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 04:51:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so16192296pgu.18
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:51:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si15035172plj.129.2018.12.19.01.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 01:51:13 -0800 (PST)
Date: Wed, 19 Dec 2018 10:51:10 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219095110.GB5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed 19-12-18 04:46:56, Wei Yang wrote:
> Below is a brief call flow for __offline_pages() and
> alloc_contig_range():
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()
> 
> Current logic is: isolate and drain pcp list for each pageblock and
> drain pcp list again. This is not necessary and we could just drain pcp
> list once after isolate this whole range.
> 
> The reason is start_isolate_page_range() will set the migrate type of
> a range to MIGRATE_ISOLATE. After doing so, this range will never be
> allocated from Buddy, neither to a real user nor to pcp list.

But it is important to note that those pages still can be allocated from
the pcp lists until we do drain_all_pages().

One thing that I really do not like about this patch (and I believe I
have mentioned that previously) that you rely on callers to do the right
thing. The proper fix would be to do the draining in
start_isolate_page_range and remove them from callers. Also what does
prevent start_isolate_page_range to work on multiple zones? At least
contiguous allocator can do that in principle.

So no I do not like this patch, it is not an improvement.
-- 
Michal Hocko
SUSE Labs
