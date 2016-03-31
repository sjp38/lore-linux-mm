Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B440A6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:58:45 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id 20so96865wmh.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:58:45 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id lf6si13650356wjb.145.2016.03.31.14.58.44
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 14:58:44 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: UBIFS and page migration (take 2)
Date: Thu, 31 Mar 2016 23:58:31 +0200
Message-Id: <1459461513-31765-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz

During page migrations UBIFS gets confused. We triggered this by using CMA
on two different targets.
It turned out that fallback_migrate_page() is not suitable for UBIFS as it
does not copy the PagePrivate flag.
UBIFS is using this flag among with PageChecked to account free space.
One possible solution is implementing a ->migratepage() function in UBIFS
which does more or less the same as fallback_migrate_page() but also
copies PagePrivate. I'm not at all sure whether this is they way to go.
IMHO either page migration should not happen if ->migratepage() is not implement
or fallback_migrate_page() has to work for all filesystems.

Comments? Flames? :-)

Thanks,
//richard

[PATCH 1/2] mm: Export migrate_page_move_mapping and
[PATCH 2/2] UBIFS: Implement ->migratepage()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
