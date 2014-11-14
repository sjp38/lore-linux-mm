Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5CCA46B00CC
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 08:08:26 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so5052576wiv.5
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 05:08:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx3si49039354wjb.132.2014.11.14.05.08.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 05:08:25 -0800 (PST)
Date: Fri, 14 Nov 2014 14:08:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: anon_vma accumulating for certain load still not addressed
Message-ID: <20141114130822.GC22857@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Andrea Argangeli <andrea@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, LKML <linux-kernel@vger.kernel.org>

Hi,
back in 2012 [1] there was a discussion about a forking load which
accumulates anon_vmas. There was a trivial test case which triggers this
and can potentially deplete the memory by local user.

We have a report for an older enterprise distribution where nsd is
suffering from this issue most probably (I haven't debugged it throughly
but accumulating anon_vma structs over time sounds like a good enough
fit) and has to be restarted after some time to release the accumulated
anon_vma objects.

There was a patch which tried to work around the issue [2] but I do not
see any follow ups nor any indication that the issue would be addressed
in other way. 

The test program from [1] was running for around 39 mins on my laptop
and here is the result:

$ date +%s; grep anon_vma /proc/slabinfo
1415960225
anon_vma           11664  11900    160   25    1 : tunables    0    0    0 : slabdata    476    476      0

$ ./a # The reproducer

$ date +%s; grep anon_vma /proc/slabinfo
1415962592
anon_vma           34875  34875    160   25    1 : tunables    0    0    0 : slabdata   1395   1395      0

$ killall a
$ date +%s; grep anon_vma /proc/slabinfo
1415962607
anon_vma           11277  12175    160   25    1 : tunables    0    0    0 : slabdata    487    487      0

So we have accumulated 23211 objects over that time period before the
offender was killed which released all of them.

The proposed workaround is kind of ugly but do people have a better idea
than reference counting? If not should we merge it?

---
[1] https://lkml.org/lkml/2012/8/15/765
[2] https://lkml.org/lkml/2013/6/3/568
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
