Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6816B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:02:55 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so6902486qae.27
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 10:02:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e16si3709670qej.53.2014.01.21.10.02.53
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 10:02:53 -0800 (PST)
Date: Tue, 21 Jan 2014 13:02:49 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390327369-bbq8yv0o-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [LSF/MM ATTEND] Memory management -- memory error reporting, ksm
 memory error handling, hugepage migration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

I'd like to attend LSF/MM summit. My main interest is in memory management,
especially memory error handling, hugepage (both hugetlb/thp), and (huge)page
migration. Here is the list of topics which I'm interested in or now developing:

- Fixing memory error reporting issue
  There is a long standing issue on memory error reporting where we could
  consume the corrupted data when memory error occurs on a dirty page.
  This is because of the non-stickiness of AS_EIO on mapping->flags (which is
  cleared once checked in current implementation).
  So the first step to solve this problem is to keep the error contained
  until we confirm the error is solved. And the second step is to improve
  the logging with more information about which page offset of which file
  is affected by the error.
  And the optional step is the error recovery with full page overwriting.
  Now I'm preparing the patches which are based on pagecache tag approach.
  I plan to post the next version's patches until summit to show the progress.

  Non-stickiness of AS_EIO is also the case on the normal IO errors, so it
  could be a generic problem. But it's too big to solve at one time, and
  there was a disucission on the definition of errors in filesystem/block
  layers (http://lwn.net/Articles/548353) and it seems that we don't have
  a solution on it yet. IOW, I'm not sure if we can/should handle memory errors
  and normal IO errors in completely the same manner at least for now.
  So I want to separate the problem and will solve memory error issue at first.

- Memory error handling on ksm page
  Recently ksm pages can be redundant on per-node basis by commit 90bd6fd31c80
  "ksm: allow trees per NUMA node." This means that we have some possibility
  to recover from memory errors on ksm pages, which I think is an improvement.

- Further extension of hugepage migration.
  * thp migration via NUMA system calls
    thp migration is already available in the context of autonuma, but NUMA
    system calls like mbind(2) and move_pages(2) don't support thp (thp will
    be split when we call them on it.) So I think that the support will be
    helpful for users who want to control NUMA memory manually.
  * 1G hugepage migration
    2M hugepage migration is available now, but 1G hugepage migration is
    not ready due to lack of testing. I'm not sure how many users really
    want this feature, but anyway it's one of my development topics.

I hope that we can discuss on these topics.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
