Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1206B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:13:28 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id n3so65153017wmn.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:28 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ck9si3445663wjc.88.2016.04.06.07.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 07:13:27 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a140so13654956wma.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] oom reaper follow ups v1
Date: Wed,  6 Apr 2016 16:13:13 +0200
Message-Id: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Raushaniya Maksudova <rmaksudova@parallels.com>

Hi,
the following three patches should help to reduce the corner case space
for oom livelocks even further.

Patch1 is something that we should have probably done quite some time
ago. GFP_NOFS requests never got access to memory reserves even when a
task was killed. As this has some side effect to oom notifiers I have
CCed curret users of this interface to hear from them. The patch contains
more detailed information.

Patch2 builds on top and allows tasks which skip the regular OOM killer
(e.g. those with fatal_signal_pending) to queue them for oom reaper if
there is not a risk that somebody sharing the mm with them could see
this from the userspace. I have cced Oleg on this patch because I am not
entirely sure I am doing it properly.

Finally the last patch relaxes TIF_MEMDIE clearing and makes sure that
no task queued for the oom reaper will keep it once it is processed
(either successfully or not).

Any feedback is highly appreciated.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
