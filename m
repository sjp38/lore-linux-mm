Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 755216B0122
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:54:39 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so956966iec.23
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:54:39 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id fo13si41262416icb.28.2014.06.10.16.54.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 16:54:38 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so4653941iec.31
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:54:38 -0700 (PDT)
Date: Tue, 10 Jun 2014 16:54:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
In-Reply-To: <5396B31B.6080706@suse.cz>
Message-ID: <alpine.DEB.2.02.1406101646540.32203@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com> <5390374E.5080708@suse.cz>
 <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com> <53916BB0.3070001@suse.cz> <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com> <53959C11.2000305@suse.cz> <alpine.DEB.2.02.1406091512540.5271@chino.kir.corp.google.com>
 <5396B31B.6080706@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, 10 Jun 2014, Vlastimil Babka wrote:

> > I think the compiler is allowed to turn this into
> > 
> > 	if (ACCESS_ONCE(page_private(page)) > 0 &&
> > 	    ACCESS_ONCE(page_private(page)) < MAX_ORDER)
> > 		low_pfn += (1UL << ACCESS_ONCE(page_private(page))) - 1;
> > 
> > since the inline function has a return value of unsigned long but gcc may
> > not do this.  I think
> > 
> > 	/*
> > 	 * Big fat comment describing why we're using ACCESS_ONCE(), that
> > 	 * we're ok to race, and that this is meaningful only because of
> > 	 * the previous PageBuddy() check.
> > 	 */
> > 	unsigned long pageblock_order = ACCESS_ONCE(page_private(page));
> > 
> > is better.
> 
> I've talked about it with a gcc guy and (although he didn't actually see the
> code so it might be due to me not explaining it perfectly), the compiler will
> inline page_order_unsafe() so that there's effectively.
> 
> unsigned long freepage_order = ACCESS_ONCE(page_private(page));
> 
> and now it cannot just replace all freepage_order occurences with new
> page_private() accesses. So thanks to the inlining, the volatile qualification
> propagates to where it matters. It makes sense to me, but if it's according to
> standard or gcc specific, I don't know.
> 

I hate to belabor this point, but I think gcc does treat it differently.  
If you look at the assembly comparing your patch to if you do

	unsigned long freepage_order = ACCESS_ONCE(page_private(page));

instead, then if you enable annotation you'll see that gcc treats the 
store as page_x->D.y.private in your patch vs. MEM[(volatile long unsigned 
int *)page_x + 48B] with the above.

I don't have the ability to prove that all versions of gcc optimization 
will not choose to reaccess page_private(page) here, but it does show that 
at least gcc 4.6.3 does not consider them to be equivalents.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
