Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23567828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:45:25 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id c1so17664129lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:45:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si8802406wjv.91.2016.06.21.08.45.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 08:45:23 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/3 v1] dax: Clear dirty bits after flushing caches
Date: Tue, 21 Jun 2016 17:45:12 +0200
Message-Id: <1466523915-14644-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Hello,

currently we never clear dirty bits in the radix tree of a DAX inode. Thus
fsync(2) or even periodical writeback flush all the dirty pfns again and
again. This patches implement clearing of the dirty tag in the radix tree
so that we issue flush only when needed.

The difficulty with clearing the dirty tag is that we have to protect against
a concurrent page fault setting the dirty tag and writing new data into the
page. So we need a lock serializing page fault and clearing of the dirty tag
and write-protecting PTEs (so that we get another pagefault when pfn is written
to again and we have to set the dirty tag again).

The effect of the patch set is easily visible:

Writing 1 GB of data via mmap, then fsync twice.

Before this patch set both fsyncs take ~205 ms on my test machine, after the
patch set the first fsync takes ~283 ms (the additional cost of walking PTEs,
clearing dirty bits etc. is very noticeable), the second fsync takes below
1 us.

As a bonus, these patches make filesystem freezing for DAX filesystems
reliable because mappings are now properly writeprotected while freezing the
fs.

Patches have passed xfstests for both xfs and ext4.

So far the patches don't work with PMD pages - that's next on my todo list.

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
