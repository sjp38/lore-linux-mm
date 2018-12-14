Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73A108E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:57:17 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s71so3287217pfi.22
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 19:57:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k189si3013133pgd.589.2018.12.13.19.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 19:57:16 -0800 (PST)
Date: Thu, 13 Dec 2018 19:57:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-Id: <20181213195712.1e7bacce774c403e82fe9fab@linux-foundation.org>
In-Reply-To: <20181214023912.77474-1-richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Fri, 14 Dec 2018 10:39:12 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> Below is a brief call flow for __offline_pages()

Offtopic...

set_migratetype_isolate() has the comment

	/*
	 * immobile means "not-on-lru" pages. If immobile is larger than
	 * removable-by-driver pages reported by notifier, we'll fail.
	 */

what the heck does that mean?  It used to talk about unmovable pages,
but this was mysteriously changed to use the unique term "immobile" by
Minchan's ee6f509c32 ("mm: factor out memory isolate functions"). 
Could someone please take a look?


> and
> alloc_contig_range():
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()
> 
> Since set_migratetype_isolate() is only used in
> start_isolate_page_range(), which is just used in __offline_pages() and
> alloc_contig_range(). And both of them call drain_all_pages() if every
> check looks good. This means it is not necessary call drain_all_pages()
> in each iteration of set_migratetype_isolate().
>
> By doing so, the logic seems a little bit clearer.
> set_migratetype_isolate() handles pages in Buddy, while
> drain_all_pages() takes care of pages in pcp.

Well.  drain_all_pages() moves pages from pcp to buddy so I'm not sure
that argument holds water.

Can we step back a bit and ask ourselves what all these draining
operations are actually for?  What is the intent behind each callsite? 
Figuring that out (and perhaps even documenting it!) would help us
decide the most appropriate places from which to perform the drain.
