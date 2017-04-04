Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE9D6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 10:19:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m72so2389868wmb.22
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 07:19:10 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id c63si19950237wmf.25.2017.04.04.07.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 07:19:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 504581C1DBA
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 15:19:08 +0100 (IST)
Date: Tue, 4 Apr 2017 15:19:07 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Fix print order in show_free_areas()
Message-ID: <20170404141907.eomyynht4vlhu2ni@techsingularity.net>
References: <1490377730.30219.2.camel@beget.ru>
 <20170403151111.4c9967329d6d6140e2a652ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170403151111.4c9967329d6d6140e2a652ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, linux-mm@kvack.org

On Mon, Apr 03, 2017 at 03:11:11PM -0700, Andrew Morton wrote:
> On Fri, 24 Mar 2017 20:48:50 +0300 Alexander Polakov <apolyakov@beget.ru> wrote:
> 
> > Better seen in context: https://github.com/torvalds/linux/blob/master/m
> > m/page_alloc.c#L4500
> > 
> > Signed-off-by: Alexander Polyakov <apolyakov@beget.com>
> 
> --- a/mm/page_alloc.c~fix-print-order-in-show_free_areas
> +++ a/mm/page_alloc.c
> @@ -4519,13 +4519,13 @@ void show_free_areas(unsigned int filter
>  			K(node_page_state(pgdat, NR_FILE_MAPPED)),
>  			K(node_page_state(pgdat, NR_FILE_DIRTY)),
>  			K(node_page_state(pgdat, NR_WRITEBACK)),
> +			K(node_page_state(pgdat, NR_SHMEM)),
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
>  			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
>  					* HPAGE_PMD_NR),
>  			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
>  #endif
> -			K(node_page_state(pgdat, NR_SHMEM)),
>  			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>  			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
>  			node_page_state(pgdat, NR_PAGES_SCANNED),
> _
> 
> huh.  It looks like this has been broken for nearly a year, by
> 
> : commit 11fb998986a72aa7e997d96d63d52582a01228c5
> : Author:     Mel Gorman <mgorman@techsingularity.net>
> : AuthorDate: Thu Jul 28 15:46:20 2016 -0700
> : Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> : CommitDate: Thu Jul 28 16:07:41 2016 -0700
> : 
> :     mm: move most file-based accounting to the node
> 

Yes, this was careless. Thanks for catching it Alexander.

> I'm surprised nobody noticed until now.
> 

Probably because vmstat was not affected which is consumed more often
than the output from sysrq or an oom kill message.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
