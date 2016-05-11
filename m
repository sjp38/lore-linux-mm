Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2711E6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 09:53:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so42935234wme.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 06:53:53 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id z7si38927585wmz.39.2016.05.11.06.53.52
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 06:53:52 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: UBIFS and page migration (take 3)
Date: Wed, 11 May 2016 15:53:41 +0200
Message-Id: <1462974823-3168-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz

During page migrations UBIFS gets confused. We triggered this by using CMA
on two different targets.
It turned out that fallback_migrate_page() is not suitable for UBIFS as it
does not copy the PagePrivate flag. Non-trivial block based filesystems
do not notice since they can use buffer_migrate_page().
UBIFS is using this flag among with PageChecked to account free space.
One possible solution is implementing a ->migratepage() function in UBIFS
which does more or less the same as fallback_migrate_page() but also
copies PagePrivate. I'm not at all sure whether this is the way to go.
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
