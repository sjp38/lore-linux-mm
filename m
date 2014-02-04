Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 502E46B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 08:29:09 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so4148939wes.13
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 05:29:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si37848wiw.12.2014.02.04.05.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 05:29:07 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 0/6] memcg: some charge path cleanups + css offline vs. charge race fix
Date: Tue,  4 Feb 2014 14:28:54 +0100
Message-Id: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,
this is a second version of the series previously posted here:
http://marc.info/?l=linux-mm&m=138729515304263&w=2. It is based on
3.14-rc1 and I am still testing it but having another eyes on it would
be great because this piece of code is really tricky.

The first four patches are an attempt to clean up memcg charging path a
bit. I am already fed up about all the different combinations of mm vs.
memcgp parameters so I have split up the function into two parts:
        * charge mm
        * charge a known memcg
More details are in the patch 2. I think that this makes more sense.
It was also quite surprising that just the code reordering without any
functional changes made the code smaller by 800B.
Johannes has suggested (http://marc.info/?l=linux-mm&m=139144269917488&w=2)
that mem_cgroup_try_charge_mm is not that helpful because the caller
can resolve the proper memcg by calling try_get_mem_cgroup_from_mm but
the next patch will require a retry if the css becomes offline and we do
not want to duplicate the same logic in each caller.

Patch #4 addresses memcg charge vs. memcg_offline race which is now
worked around by 96f1c58d8534 (mm: memcg: fix race condition between
memcg teardown and swapin). The last patch reverts the workaround.

Changes since v1 (based on comments from Johannes)
- renamed mem_cgroup_bypass_charge to current_bypass_charge
- get rid of try_get_mem_cgroup_from_mm duplication if the mm is charged
- fixed rcu_read_lock recursion bug in try_get_mem_cgroup_from_mm
- dropped memcg->offline and replace it by css_tryget & css_put
- fixed ref leak for kmem CHARGE_RETRY path
- kmem accounting cleanup as well

Michal Hocko (6):
      memcg: do not replicate try_get_mem_cgroup_from_mm in __mem_cgroup_try_charge
      memcg: cleanup charge routines
      memcg: mm == NULL is not allowed for mem_cgroup_try_charge_mm
      memcg: make sure that memcg is not offline when charging
      memcg, kmem: clean up memcg parameter handling
      Revert "mm: memcg: fix race condition between memcg teardown and swapin"

Diffstat says:
 include/linux/memcontrol.h |   4 +-
 mm/memcontrol.c            | 341 +++++++++++++++++++++------------------------
 mm/page_alloc.c            |   2 +-
 3 files changed, 162 insertions(+), 185 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
