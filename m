Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9621828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 17:01:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ts6so420889627pac.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 14:01:38 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id m189si5809377pfm.259.2016.07.05.14.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 14:01:38 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id h14so73212252pfe.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 14:01:37 -0700 (PDT)
Date: Tue, 5 Jul 2016 14:01:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when terminating
 freeing scanner
In-Reply-To: <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
Message-ID: <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com> <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org

On Thu, 30 Jun 2016, Vlastimil Babka wrote:

> >  Note: I really dislike the low watermark check in split_free_page() and
> >  consider it poor software engineering.  The function should split a free
> >  page, nothing more.  Terminating memory compaction because of a low
> >  watermark check when we're simply trying to migrate memory seems like an
> >  arbitrary heuristic.  There was an objection to removing it in the first
> >  proposed patch, but I think we should really consider removing that
> >  check so this is simpler.
> 
> There's a patch changing it to min watermark (you were CC'd on the series). We
> could argue whether it belongs to split_free_page() or some wrapper of it, but
> I don't think removing it completely should be done. If zone is struggling
> with order-0 pages, a functionality for making higher-order pages shouldn't
> make it even worse. It's also not that arbitrary, even if we succeeded the
> migration and created a high-order page, the higher-order allocation would
> still fail due to watermark checks. Worse, __compact_finished() would keep
> telling the compaction to continue, creating an even longer lag, which is also
> against your recent patches.
> 

I'm suggesting we shouldn't check any zone watermark in split_free_page(): 
that function should just split the free page.

I don't find our current watermark checks to determine if compaction is 
worthwhile to be invalid, but I do think that we should avoid checking or 
acting on any watermark in isolate_freepages() itself.  We could do more 
effective checking in __compact_finished() to determine if we should 
terminate compaction, but the freeing scanner feels like the wrong place 
to do it -- it's also expensive to check while gathering free pages for 
memory that we have already successfully isolated as part of the 
iteration.

Do you have any objection to this fix for 4.7?

Joonson and/or Minchan, does this address the issue that you reported?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
