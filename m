Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA0A6B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:21:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p46so1065195wrb.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:21:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si8374471wrb.241.2017.10.17.09.21.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 09:21:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/7 v2] Speed up page cache truncation
Date: Tue, 17 Oct 2017 18:21:13 +0200
Message-Id: <20171017162120.30990-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

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

Andrew, can you please consider merging these patches? Thanks!

Changes since v1:
* Added acks and reviewed-by tags


								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
