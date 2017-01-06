Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 926546B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 09:18:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u5so1136368291pgi.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:18:57 -0800 (PST)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id b129si4923560pfg.149.2017.01.06.06.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 06:18:56 -0800 (PST)
Received: by mail-pf0-f193.google.com with SMTP id y68so30054445pfb.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:18:56 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [DEBUG PATCH 0/2] debug explicit GFP_NO{FS,IO} usage from the scope context
Date: Fri,  6 Jan 2017 15:18:43 +0100
Message-Id: <20170106141845.24362-1-mhocko@kernel.org>
In-Reply-To: <20170106141107.23953-1-mhocko@kernel.org>
References: <20170106141107.23953-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

These two patches should help to identify explicit GFP_NO{FS,IO} usage
from withing a scope context and reduce such a usage as a result. Such
a usage can be changed to the full GFP_KERNEL because all the calls
from within the NO{FS,IO} scope will drop the __GFP_FS resp. __GFP_IO
automatically and if the function is called outside of the scope then
we do not need to restrict it to NOFS/NOIO as long as all the reclaim
recursion unsafe contexts are marked properly. This means that each such
a reported allocation site has to be checked before converted.

The debugging has to be enabled explicitly by a kernel command line
parameter and then it reports the stack trace of the allocation and
also the function which has started the current scope.

These two patches are _not_ intended to be merged and they are only
aimed at debugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
