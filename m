Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE4B6B0254
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 07:00:38 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so65157282wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 04:00:38 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id av9si1272687wjc.100.2015.10.09.04.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 04:00:35 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so65154655wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 04:00:33 -0700 (PDT)
From: Nikolay Borisov <kernel@kyup.com>
Subject: Making per-cpu lists draining dependant on a flag
Message-ID: <56179E4F.5010507@kyup.com>
Date: Fri, 9 Oct 2015 14:00:31 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Marian Marinov <mm@1h.com>, SiteGround Operations <operations@siteground.com>

Hello mm people,


I want to ask you the following question which stemmed from analysing
and chasing this particular deadlock:
http://permalink.gmane.org/gmane.linux.kernel/2056730

To summarise it:

For simplicity I will use the following nomenclature:
t1 - kworker/u96:0
t2 - kworker/u98:39
t3 - kworker/u98:7

t1 issues drain_all_pages which generates IPI's, at the same time
however, t2 has already started doing async write of pages
as part of its normal operation but is blocked upon t1 completion of
its IPI (generated from drain_all_pages) since they both work on the
same dm-thin volume. At the same time again, t3 is executing
ext4_finish_bio, which disables interrupts, yet is dependent on t2
completing its writes.  But since it has disabled interrupts, it wont
respond to t1's IPI and at this point a hard lock up occurs. This
happens, since drain_all_pages calls on_each_cpu_mask with the last
argument equal to  "true" meaning "wait until the ipi handler has
finished", which of course will never happen in the described situation.

Based on that I was wondering whether avoiding such situation might
merit making drain_all_pages invocation from
__alloc_pages_direct_reclaim dependent on a particular GFP being passed
e.g. GFP_NOPCPDRAIN or something along those lines?

Alternatively would it be possible to make the IPI asycnrhonous e.g.
calling on_each_cpu_mask with the last argument equal to false?

Regards,
Nikolay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
