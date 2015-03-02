Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 26A4C6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:55:37 -0500 (EST)
Received: by widem10 with SMTP id em10so15034506wid.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:55:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si22329414wjy.173.2015.03.02.05.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:55:34 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH 0/4] Clarify and cleanup some __GFP_NOFAIL usage
Date: Mon,  2 Mar 2015 14:54:39 +0100
Message-Id: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hi,
from the last discussion about __GFP_NOFAIL it turned out that the flag
cannot be deprecated as easily as MM people hoped for.
The current flag description leads people to inventing their own loops
around GFP_{KERNEL|NOFS} allocations without any fallback failure
policy. This makes the situation much worse for the MM layer because it
is not aware of the hard no-fail requirements.

First patch in this series tries to rephrase the documentation to be
more clear about our intention. __GFP_NOFAIL is generally discouraged
but users shouldn't lie to the allocator if they really cannot have any
failure strategy.

Second patch removes such an open coded retry loop in the jbd2 code
which was introduced exactly because of the deprecation wording. I am
not sure the patch is still required because Ted has mentioned something
about changing this code. If he was faster then we can simply drop
this one. I was hoping for more such opencoded paths but wasn't very
successful. The next plan is to abuse coccinelle to find such patterns.

The last two patches are attempts to get rid of __GFP_NOFAIL when
it seemed they are not needed because there are error paths handled
properly. I am not familiar with that code so I might be clearly
wrong here and I would appreciate double checking from the respective
maintainer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
