Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id DA3256B0071
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:41:54 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so2001436wiv.0
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:41:54 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si3215843wiw.17.2014.12.05.08.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 08:41:53 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 0/4] OOM vs PM freezer fixes
Date: Fri,  5 Dec 2014 17:41:42 +0100
Message-Id: <1417797707-31699-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20141110163055.GC18373@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hi,
here is another take at OOM vs. PM freezer interaction fixes/cleanups.
First three patches are fixes for an unlikely cases when OOM races with
the PM freezer which should be closed completely finally. The last patch
is a simple code enhancement which is not needed strictly speaking but
it is nice to have IMO.

Both OOM killer and PM freezer are quite subtle so I hope I haven't
missing anything. Any feedback is highly appreciated. I am also
interested about feedback for the used approach. To be honest I am not
really happy about spreading TIF_MEMDIE checks into freezer (patch 1)
but I didn't find any other way for detecting OOM killed tasks.

Changes are based on top of Linus tree (3.18-rc3).

Michal Hocko (4):
      OOM, PM: Do not miss OOM killed frozen tasks
      OOM, PM: make OOM detection in the freezer path raceless
      OOM, PM: handle pm freezer as an OOM victim correctly
      OOM: thaw the OOM victim if it is frozen

Diffstat says:
 drivers/tty/sysrq.c    |  6 ++--
 include/linux/oom.h    | 39 ++++++++++++++++------
 kernel/freezer.c       | 15 +++++++--
 kernel/power/process.c | 60 +++++++++-------------------------
 mm/memcontrol.c        |  4 ++-
 mm/oom_kill.c          | 89 ++++++++++++++++++++++++++++++++++++++------------
 mm/page_alloc.c        | 32 +++++++++---------
 7 files changed, 147 insertions(+), 98 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
