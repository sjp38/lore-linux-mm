Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 60F3D82905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:54:57 -0400 (EDT)
Received: by pdno5 with SMTP id o5so20046294pdn.1
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 05:54:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o7si3053976pdp.136.2015.03.12.05.54.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Mar 2015 05:54:56 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
	<1426107294-21551-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426107294-21551-2-git-send-email-mhocko@suse.cz>
Message-Id: <201503122154.JFB35925.SJHOOVOFLFtMFQ@I-love.SAKURA.ne.jp>
Date: Thu, 12 Mar 2015 21:54:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, fernando_b1@lab.ntt.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(The Cc: line seems to be partially truncated. Please re-add if needed.)

Michal Hocko wrote:
> Finally, if a non-failing allocation is unavoidable then __GFP_NOFAIL
> flag is there to express this strong requirement. It is much better to
> have a simple way to check all those places and come up with a solution
> which will guarantee a forward progress for them.

Keeping gfp flags passed to ongoing allocation inside "struct task_struct"
will allow the OOM killer to skip OOM victims doing __GFP_NOFAIL.
http://marc.info/?l=linux-mm&m=141671829611143&w=2 would give a hint.

> As this behavior is established for many years we cannot change it
> immediately. This patch instead exports a new sysctl/proc knob which
> tells allocator how much to retry. The higher the number the longer will
> the allocator loop and try to trigger OOM killer when the memory is too
> low. This implementation counts only those retries which involved OOM
> killer because we do not want to be too eager to fail the request.

I prefer jiffies timeouts than retry counts, for jiffies will allow vmcore
to tell how long the process was stalled for memory allocation.
http://marc.info/?l=linux-mm&m=141671821111135&w=1 and
http://marc.info/?l=linux-mm&m=141709978209207&w=1 would give a hint.

> The default value is ULONG_MAX which basically preserves the current
> behavior (endless retries). The idea is that we start with testing
> systems first and lower the value to catch potential fallouts (crashes
> due to unchecked failures or other misbehavior like FS ro-remounts
> etc...). Allocation failures are already reported by warn_alloc_failed
> so we should be able to catch the allocation path before an issue is
> triggered.

Few developers are using fault-injection capability (CONFIG_FAILSLAB and
CONFIG_FAIL_PAGE_ALLOC). Even less developers would be performing OOM
stress tests. Printing allocation failure messages only upon OOM condition
is Whack-A-Mole where moles remain hidden until distribution kernel users
by chance (or by intent) triggered OOM condition.

I tried SystemTap-based mandatory fault-injection hooks at
http://marc.info/?l=linux-kernel&m=141951300713051&w=2 and I reported
random crashes at
http://lists.freedesktop.org/archives/dri-devel/2015-January/075922.html .
How can we find the exact culprit allocation when an issue is triggered
some time after the first failure messages?

I think that your knob helps avoiding infinite loop if lower value is
given, but I don't think that your knob helps catching potential fallouts.

> We will try to encourage distributions to change the default in the
> second step so that we get a much bigger exposure.

Can we expect that distribution kernel users are willing to perform OOM
stress tests which kernel developers did not perform?

> And finally we can change the default in the kernel while still keeping
> the knob for conservative configurations. This will be long run but
> let's start.

And finally what patches will you propose for already running systems
using distribution kernels? I can't wait for years (or decades) until
your knob and fixes for fallouts are backported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
