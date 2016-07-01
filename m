Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A02AE6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 05:26:44 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so78316739lfa.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:44 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id ll9si2586236wjb.43.2016.07.01.02.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 02:26:43 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id v199so18671500wmv.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/6] fortify oom killer even more 
Date: Fri,  1 Jul 2016 11:26:24 +0200
Message-Id: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>

Hi,
I am sending this pile as an RFC and I hope it will make a good
foundation to hopefully plug the remaining holes which could lead to oom
lockups for CONFIG_MMU.

There are two main parts patches 1-4 and the 5-6. The first pile focuses
on moving decisions about oom victims more to mm_struct. Especially the
part when there is an oom victim noticed and we decide whether to select
new victim. Patch 1 remembers the mm at the time oom victim is selected
and it is stable for the rest of the process group life time. This
allows some simplifications.

The later part is about kthread vs. oom_reaper interaction. It seems that
the only use_mm() user which needs fixing is vhost and that is fixable.
Then we can remove the kthread restriction and so basically the every
oom victim will be reapable now (well except the weird cases where the
mm is shared with init but I consider that uninteresting).

I haven't tested this properly yet. I will be mostly offline next week
but definitely plan to test it later on. Right now I would appreciated
feedback/review. If this looks OK then I would like to target it for 4.9.

The series is based on top of the current mmotm (2016-06-24-15-53) +
http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org

Thanks!

Michal Hocko (6):
      oom: keep mm of the killed task available
      oom, suspend: fix oom_killer_disable vs. pm suspend properly
      exit, oom: postpone exit_oom_victim to later
      oom, oom_reaper: consider mmget_not_zero as a failure
      vhost, mm: make sure that oom_reaper doesn't reap memory read by vhost
      oom, oom_reaper: allow to reap mm shared by the kthreads

 drivers/vhost/scsi.c    |   2 +-
 drivers/vhost/vhost.c   |  18 +++----
 include/linux/oom.h     |   2 +-
 include/linux/sched.h   |   3 ++
 include/linux/uaccess.h |  22 +++++++++
 include/linux/uio.h     |  10 ++++
 kernel/exit.c           |   5 +-
 kernel/fork.c           |   2 +
 kernel/power/process.c  |  17 ++-----
 mm/mmu_context.c        |   6 +++
 mm/oom_kill.c           | 127 ++++++++++++++++++++++++------------------------
 11 files changed, 124 insertions(+), 90 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
