Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD2B6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 02:17:36 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so48043521wid.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 23:17:35 -0700 (PDT)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id by10si1515551wjb.148.2015.06.30.23.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 23:17:34 -0700 (PDT)
Received: by wgqq4 with SMTP id q4so27278392wgq.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 23:17:33 -0700 (PDT)
Date: Wed, 1 Jul 2015 08:17:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
Message-ID: <20150701061731.GB6286@dhcp22.suse.cz>
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435677437-16717-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Marian Marinov <mm@1h.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

On Tue 30-06-15 17:17:17, Michal Hocko wrote:
[...]
> Hi,
> the issue has been reported http://marc.info/?l=linux-kernel&m=143522730927480.
> This obviously requires a patch ot make ext4_ext_grow_indepth call
> sb_getblk with the GFP_NOFS mask but that one makes sense on its own
> and Ted has mentioned he will push it. I haven't marked the patch for
> stable yet. This is the first time the issue has been reported and
> ext4 writeout code has changed considerably in 3.11 and I am not sure
> the issue was present before. e62e384e9da8 which has introduced the
> wait_on_page_writeback has been merged in 3.6 which is quite some time
> ago. If we go with stable I would suggest marking it for 3.11+ and it
> should obviously go with the ext4_ext_grow_indepth fix.

After Dave's additional explanation
(http://marc.info/?l=linux-ext4&m=143570521212215) it is clear that the
lack of __GFP_FS check was wrong from the very beginning. XFS is doing
the similar thing from before the e62e384e9da8 was merged. I guess we
were just lucky not to hit this problem sooner.

That being said I think the patch should be marked for stable and the
changelog updated:

As per David Chinner the xfs is doing similar thing since 2.6.15 already
so ext4 is not the only affected filesystem. Moreover he notes:
: For example: IO completion might require unwritten extent conversion
: which executes filesystem transactions and GFP_NOFS allocations. The
: writeback flag on the pages can not be cleared until unwritten
: extent conversion completes. Hence memory reclaim cannot wait on
: page writeback to complete in GFP_NOFS context because it is not
: safe to do so, memcg reclaim or otherwise.

Cc: stable # 3.6+
Fixes: e62e384e9da8 ("memcg: prevent OOM with too many dirty pages")

Andrew let me know whether I should repost the patch with the updated
changelog or you can take it from here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
