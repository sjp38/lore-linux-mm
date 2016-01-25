Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 506146B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:34:00 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id r129so64232106wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:34:00 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m189si24432064wmb.98.2016.01.25.05.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 05:33:59 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id l65so64136931wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:33:59 -0800 (PST)
Date: Mon, 25 Jan 2016 14:33:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160125133357.GC23939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hi,
I would like to propose the following topics (mainly for the MM track
but some of them might be of interest for FS people as well)
- gfp flags for allocations requests seems to be quite complicated
  and used arbitrarily by many subsystems. GFP_REPEAT is one such
  example. Half of the current usage is for low order allocations
  requests where it is basically ignored. Moreover the documentation
  claims that such a request is _not_ retrying endlessly which is
  true only for costly high order allocations. I think we should get
  rid of most of the users of this flag (basically all low order ones)
  and then come up with something like GFP_BEST_EFFORT which would work
  for all orders consistently [1]
- GFP_NOFS is another one which would be good to discuss. Its primary
  use is to prevent from reclaim recursion back into FS. This makes
  such an allocation context weaker and historically we haven't
  triggered OOM killer and rather hopelessly retry the request and
  rely on somebody else to make a progress for us. There are two issues
  here.
  First we shouldn't retry endlessly and rather fail the allocation and
  allow the FS to handle the error. As per my experiments most FS cope
  with that quite reasonably. Btrfs unfortunately handles many of those
  failures by BUG_ON which is really unfortunate.
  Another issue is that GFP_NOFS is quite often used without any obvious
  reason. It is not clear which lock is held and could be taken from
  the reclaim path. Wouldn't it be much better if the no-recursion
  behavior was bound to the lock scope rather than particular allocation
  request? We already have something like this for PM
  pm_res{trict,tore}_gfp_mask resp. memalloc_noio_{save,restore}. It
  would be great if we could unify this and use the context based NOFS
  in the FS.
- OOM killer has been discussed a lot throughout this year. We have
  discussed this topic the last year at LSF and there has been quite some
  progress since then. We have async memory tear down for the OOM victim
  [2] which should help in many corner cases. We are still waiting
  to make mmap_sem for write killable which would help in some other
  classes of corner cases. Whatever we do, however, will not work in
  100% cases. So the primary question is how far are we willing to go to
  support different corner cases. Do we want to have a
  panic_after_timeout global knob, allow multiple OOM victims after
  a timeout?
- sysrq+f to trigger the oom killer follows some heuristics used by the
  OOM killer invoked by the system which means that it is unreliable
  and it might skip to kill any task without any explanation why. The
  semantic of the knob doesn't seem to clear and it has been even
  suggested [3] to remove it altogether as an unuseful debugging aid. Is
  this really a general consensus?
- One of the long lasting issue related to the OOM handling is when to
  actually declare OOM. There are workloads which might be trashing on
  few last remaining pagecache pages or on the swap which makes the
  system completely unusable for considerable amount of time yet the
  OOM killer is not invoked. Can we finally do something about that?

[1] http://lkml.kernel.org/r/1446740160-29094-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1452094975-551-1-git-send-email-mhocko@kernel.org
[3] http://lkml.kernel.org/r/alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
