Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8946B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:26:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so4073630wmu.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:26:14 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id h82si20520635wmh.163.2017.02.01.01.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 01:26:13 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u63so4473583wmu.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:26:12 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] fix few OOM victim allocation runaways
Date: Wed,  1 Feb 2017 10:26:00 +0100
Message-Id: <20170201092603.9523-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hi,
these three patches tried to address a simple OOM victim runaways when
the oom victim can deplete the memory reserve completely. Tetsuo was able
to trigger the depletion in the write(2) path and I believe the similar
is possible for the read part. Vmalloc would be a bit harder but still
not impossible.

Unfortunately I do not see a better way around this issue as long as we
give OOM victims access to memory reserves without any limits. I have
tried to limit this access [1] which would help at least to keep some
memory for emergency actions. Anyway, even if we limit the amount of
reserves the OOM victim can consume it is still preferable to back off
before accessible reserves are depleted.

Tetsuo was suggesting introducing __GFP_KILLABLE which would fail the
allocation rather than consuming the reserves. I see two problems with
this approach.
        1) in order this flags work as expected all the blocking
        operations in the allocator call chain (including the direct
        reclaim) would have to be killable and this is really non
        trivial to achieve. Especially when we do not have any control
        over shrinkers.
        2) even if the above could be dealt with we would still have to
        find all the places which do allocation in the loop based on
        the user request. So it wouldn't be simpler than an explicit
        fatal_signal_pending check.

Thoughts?
Michal Hocko (3):
      fs: break out of iomap_file_buffered_write on fatal signals
      mm, fs: check for fatal signals in do_generic_file_read
      vmalloc: back of when the current is killed

 fs/dax.c     | 5 +++++
 fs/iomap.c   | 3 +++
 mm/filemap.c | 5 +++++
 mm/vmalloc.c | 5 +++++
 4 files changed, 18 insertions(+)

[1] http://lkml.kernel.org/r/20161004090009.7974-2-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
