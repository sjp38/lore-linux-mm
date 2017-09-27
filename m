Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BEB2F6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:35:08 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id x127so8213086ite.23
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:35:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o77sor5077987ioe.197.2017.09.27.14.35.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 14:35:07 -0700 (PDT)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH 0/2] percpu: fix block iterators and reserved chunk stats
Date: Wed, 27 Sep 2017 16:34:58 -0500
Message-Id: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Luis Henriques <lhenriques@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dennis Zhou <dennisszhou@gmail.com>

Hi everyone,

This patchset includes two bug fixes related to bitmap percpu memory
allocator.

The first is a problem with how the start offset is managed in bytes, but
the bitmaps are traversed in bits. The start offset is maintained to keep
alignment true within the actual allocation area in the chunk. With the
reserved and dynamic chunk, this may unintentionally skip over a portion
proportional to the start offset and PCPU_MIN_ALLOC_SIZE.

The second is an issue reported by Luis in [1]. The allocator was unable
to allocate from the reserved chunk due to the block offset not being
reset within the iterator. This caused subsequently checked  blocks to
check against a potentially higher block offset. This may lead the
iterator to believe it had checked this area in the prior iteration. The
fix is to simply reset the block offset to 0 after it is used allowing
the predicate to always evaluate to true for subsequent blocks.

[1] https://lkml.org/lkml/2017/9/26/506

This patchset contains the following 2 patches:
  0001-percpu-fix-starting-offset-for-chunk-statistics-trav.patch
  0002-percpu-fix-iteration-to-prevent-skipping-over-block.patch

0001 fixes the chunk start offset issue. 0002 fixes the iteration bug.

This patchset is on top of linus#v4.14-rc2 e19b205be4.

diffstats below:

Dennis Zhou (2):
  percpu: fix starting offset for chunk statistics traversal
  percpu: fix iteration to prevent skipping over block

 mm/percpu-stats.c | 2 +-
 mm/percpu.c       | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
