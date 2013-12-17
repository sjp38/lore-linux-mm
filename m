Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3E16B004D
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:45:52 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2970955eae.41
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:45:51 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si5160578eep.99.2013.12.17.07.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 07:45:51 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC] memcg: some charge path cleanups + css offline vs. charge race fix
Date: Tue, 17 Dec 2013 16:45:25 +0100
Message-Id: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,
the first three patches are an attempt to clean up memcg charging path a
bit. I am already fed up about all the different combinations of mm vs.
memcgp parameters so I have split up the function into two parts:
	* charge mm
	* charge a known memcg
More details are in the patch 1. I think that this makes more sense.
It was also quite surprising that just the code reordering without any
functional changes made the code smaller by 600B.

Second patch is just a trivial follow up, shouldn't be controversial.

The third one tries to remove an exception (bypass) path which was there
from the early days but it never made any sense to me. It always made me
confused so I would more than happy to ditch it.

Finally patch#4 addresses memcg charge vs. memcg_offline race + #5
reverts the workaround which has been merged as a first aid.

What do you think?

Based on the current mmotm (mmotm-2013-12-16-14-29-6)
Michal Hocko (5):
      memcg: cleanup charge routines
      memcg: move stock charge into __mem_cgroup_try_charge_memcg
      memcg: mm == NULL is not allowed for mem_cgroup_try_charge_mm
      memcg: make sure that memcg is not offline when charging
      Revert "mm: memcg: fix race condition between memcg teardown and swapin"

Diffstat:
 mm/memcontrol.c | 361 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 185 insertions(+), 176 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
