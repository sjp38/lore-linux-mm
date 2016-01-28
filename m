Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEBDB6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:38:05 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so32620551wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:38:05 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id y7si5118213wmg.105.2016.01.28.08.38.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 08:38:04 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id l66so19016147wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:38:04 -0800 (PST)
Date: Thu, 28 Jan 2016 17:38:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: why do we do ALLOC_WMARK_HIGH before going out_of_memory
Message-ID: <20160128163802.GA15953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Argangeli <andrea@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,
__alloc_pages_may_oom just after it manages to get oom_lock we try
to allocate once more with ALLOC_WMARK_HIGH target. I was always
wondering why are we will to actually kill something even though
we are above min wmark. This doesn't make much sense to me. I understand
that this is racy because __alloc_pages_may_oom is called after we have
failed to fulfill the WMARK_MIN target but this means WMARK_HIGH
is highly unlikely as well. So either we should use ALLOC_WMARK_MIN
or get rid of this altogether.

The code has been added before git era by
https://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.11-rc2/2.6.11-rc2-mm2/broken-out/mm-fix-several-oom-killer-bugs.patch

and it doesn't explain this particular decision. It seems to me that
what ever was the reason back then it doesn't hold anymore.

What do you think?
-- 
Michal Hocko
SUSE Labs 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
