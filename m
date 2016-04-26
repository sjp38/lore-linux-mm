Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1C846B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:56:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so11228396lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:56:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id df10si29588858wjb.224.2016.04.26.04.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 04:56:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so3774730wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:56:21 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] scop GFP_NOFS api
Date: Tue, 26 Apr 2016 13:56:10 +0200
Message-Id: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

Hi,
we have discussed this topic at LSF/MM this year. There was a general
interest in the scope GFP_NOFS allocation context among some FS
developers. For those who are not aware of the discussion or the issue
I am trying to sort out (or at least start in that direction) please
have a look at patch 1 which adds memalloc_nofs_{save,restore} api
which basically copies what we have for the scope GFP_NOIO allocation
context. I haven't converted any of the FS myself because that is way
beyond my area of expertise but I would be happy to help with further
changes on the MM front as well as in some more generic code paths.

Dave had an idea on how to further improve the reclaim context to be
less all-or-nothing wrt. GFP_NOFS. In short he was suggesting an opaque
and FS specific cookie set in the FS allocation context and consumed
by the FS reclaim context to allow doing some provably save actions
that would be skipped due to GFP_NOFS normally.  I like this idea and
I believe we can go that direction regardless of the approach taken here.
Many filesystems simply need to cleanup their NOFS usage first before
diving into a more complex changes.

The patch 2 is a debugging aid which warns about explicit allocation
requests from the scope context. This is should help to reduce the
direct usage of the NOFS flags to bare minimum in favor of the scope
API. It is not aimed to be merged upstream. I would hope Andrew took it
into mmotm tree to give it linux-next exposure and allow developers to
do further cleanups.  There is a new kernel command line parameter which
has to be used for the debugging to be enabled.

I think the GFP_NOIO should be seeing the same clean up.

Any feedback is highly appreciated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
