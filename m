Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42E946B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:50:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k71so11828810wrc.15
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:50:27 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y28si5859453edi.306.2017.08.10.00.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 00:50:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d40so2028527wma.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:50:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 0/2] mm, oom: do not grant oom victims full memory reserves access
Date: Thu, 10 Aug 2017 09:50:17 +0200
Message-Id: <20170810075019.28998-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a second version of the series previously posted [1]. Tetsuo
has noticed a bug I've introduced during the rebase and also pointed
out reserves access changes on nommu arches which I have addressed
as well. Mel had some more feedback which is hopefully addressed as
well. There were no further comments so I am reposting and asking for
inclusion.

this is a part of a larger series I posted back in Oct last year [2]. I
have dropped patch 3 because it was incorrect and patch 4 is not
applicable without it.

The primary reason to apply patch 1 is to remove a risk of the complete
memory depletion by oom victims. While this is a theoretical risk right
now there is a demand for memcg aware oom killer which might kill all
processes inside a memcg which can be a lot of tasks. That would make
the risk quite real.

This issue is addressed by limiting access to memory reserves. We no
longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
instead. See Patch 1 for more details. Patch 2 is a trivial follow up
cleanup.

I would still like to get rid of TIF_MEMDIE completely but I do not have
time to do it now and it is not a pressing issue.

[1] http://lkml.kernel.org/r/20170727090357.3205-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20161004090009.7974-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
