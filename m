Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E280F6B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:19:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l188so61860902pfc.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:19:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f30si6894558plf.719.2017.10.10.08.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:19:50 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/7 v1] Speed up page cache truncation
Date: Tue, 10 Oct 2017 17:19:30 +0200
Message-Id: <20171010151937.26984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Hello,

when rebasing our enterprise distro to a newer kernel (from 4.4 to 4.12) we
have noticed a regression in bonnie++ benchmark when deleting files.
Eventually we have tracked this down to a fact that page cache truncation got
slower by about 10%. There were both gains and losses in the above interval of
kernels but we have been able to identify that commit 83929372f629 "filemap:
prepare find and delete operations for huge pages" caused about 10% regression
on its own.

After some investigation it didn't seem easily possible to fix the regression
while maintaining the THP in page cache functionality so we've decided to
optimize the page cache truncation path instead to make up for the change.
This series is a result of that effort.

Patch 1 is an easy speedup of cancel_dirty_page(). Patches 2-6 refactor page
cache truncation code so that it is easier to batch radix tree operations.
Patch 7 implements batching of deletes from the radix tree which more than
makes up for the original regression.

What do people think about this series?

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
