Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9226B0071
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:44 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so1706257iec.37
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:43 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id gb3si5341044igd.36.2014.06.12.14.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 14:48:43 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so8198962igb.8
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:43 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:48:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
In-Reply-To: <53999563.9060105@suse.cz>
Message-ID: <alpine.DEB.2.02.1406121446070.12437@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com> <5390374E.5080708@suse.cz>
 <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com> <53916BB0.3070001@suse.cz> <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com> <53959C11.2000305@suse.cz> <alpine.DEB.2.02.1406091512540.5271@chino.kir.corp.google.com>
 <5396B31B.6080706@suse.cz> <alpine.DEB.2.02.1406101646540.32203@chino.kir.corp.google.com> <5398492E.3070406@suse.cz> <alpine.DEB.2.02.1406111720370.11536@chino.kir.corp.google.com> <53999563.9060105@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Thu, 12 Jun 2014, Vlastimil Babka wrote:

> > Ok, and I won't continue to push the point.
> 
> I'd rather know I'm correct and not just persistent enough :) If you confirm
> that your compiler behaves differently, then maybe making page_order_unsafe a
> #define instead of inline function would prevent this issue?
> 

The reason I was hesitatnt is because there's no way I can prove under all 
possible circumstances in which page_order_unsafe() could be used that gcc 
won't make the decision to reaccess.  I personally didn't think that doing

	if (PageBuddy(page)) {
		/*
		 * Racy check since we know PageBuddy() is true and we do
		 * some sanity checking on this scan to ensure it is an
		 * appropriate order.
		 */
		unsigned long order = ACCESS_ONCE(page_private(page));
		...
	}

was too much of a problem and actually put the ACCESS_ONCE() in the 
context in which it matters rather than hiding behind an inline function.

> > I think the lockless
> > suitable_migration_target() call that looks at page_order() is fine in the
> > free scanner since we use it as a racy check, but it might benefit from
> > either a comment describing the behavior or a sanity check for
> > page_order(page) <= MAX_ORDER as you've done before.
> 
> OK, I'll add that.
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
