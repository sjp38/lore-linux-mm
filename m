Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3CD6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 07:10:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id a46so28713176qte.3
        for <linux-mm@kvack.org>; Tue, 30 May 2017 04:10:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e184si12401782qkd.126.2017.05.30.04.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 04:10:49 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] record errors in mapping when writeback fails on DAX
Date: Tue, 30 May 2017 07:10:44 -0400
Message-Id: <20170530111046.8069-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neilb@suse.com>, willy@infradead.org, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This is part of the preparatory set of patches to pave the way for
improved writeback error reporting. In order to do this correctly, we
need to ensure that DAX marks the mapping with an error when writeback
fails.

I sent the second patch in this series to Ross last week, but he pointed
out that it makes fsync error out more than it should, since we don't
currently clear errors in filemap_write_and_wait and
filemap_write_and_wait_range.

In order to fix that, I think we need the first patch in this set. There
is a some danger that this could end up causing error flags to be
cleared earlier than they were before when write initiation fails in
other filesystems.

Given how racy all of the AS_* flag handling is though, I'm inclined to
just go ahead and merge both of these into linux-next and deal with any
fallout as it arises.

Does that seem like a reasonable plan? If so, Andrew, would you be
willing to take both of these in for linux-next, with an eye toward
merging into v4.13?

Thanks in advance,

Jeff Layton (2):
  mm: clear any AS_* errors when returning from
    filemap_write_and_wait{_range}
  dax: set errors in mapping when writeback fails

 fs/dax.c     | 4 +++-
 mm/filemap.c | 8 ++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
