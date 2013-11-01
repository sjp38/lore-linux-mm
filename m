Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6306E6B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 17:11:37 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so4746047pbc.8
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 14:11:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.197])
        by mx.google.com with SMTP id y7si5417203pbi.203.2013.11.01.14.11.35
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 14:11:36 -0700 (PDT)
Message-ID: <1383340291.2653.33.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: cache largest vma
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 01 Nov 2013 14:11:31 -0700
In-Reply-To: <5274114B.7010302@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	 <5274114B.7010302@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-11-01 at 16:38 -0400, KOSAKI Motohiro wrote:
> (11/1/13 4:17 PM), Davidlohr Bueso wrote:
> > While caching the last used vma already does a nice job avoiding
> > having to iterate the rbtree in find_vma, we can improve. After
> > studying the hit rate on a load of workloads and environments,
> > it was seen that it was around 45-50% - constant for a standard
> > desktop system (gnome3 + evolution + firefox + a few xterms),
> > and multiple java related workloads (including Hadoop/terasort),
> > and aim7, which indicates it's better than the 35% value documented
> > in the code.
> >
> > By also caching the largest vma, that is, the one that contains
> > most addresses, there is a steady 10-15% hit rate gain, putting
> > it above the 60% region. This improvement comes at a very low
> > overhead for a miss. Furthermore, systems with !CONFIG_MMU keep
> > the current logic.
> 
> I'm slightly surprised this cache makes 15% hit. Which application
> get a benefit? You listed a lot of applications, but I'm not sure
> which is highly depending on largest vma.

Well I chose the largest vma because it gives us a greater chance of
being already cached when we do the lookup for the faulted address.

The 15% improvement was with Hadoop. According to my notes it was at
~48% with the baseline kernel and increased to ~63% with this patch.

In any case I didn't measure the rates on a per-task granularity, but at
a general system level. When a system is first booted I can see that the
mmap_cache access rate becomes the determinant factor and when adding a
workload it doesn't change much. One exception to this was a kernel
build, where we go from ~50% to ~89% hit rate on a vanilla kernel.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
