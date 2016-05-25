Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 764BC6B0265
	for <linux-mm@kvack.org>; Wed, 25 May 2016 04:09:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so23333444wma.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 01:09:49 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id i19si10164885wmc.105.2016.05.25.01.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 01:09:48 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id z87so51989239wmh.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 01:09:48 -0700 (PDT)
Date: Wed, 25 May 2016 10:09:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: oom_kill_process: do not abort if the victim is
 exiting
Message-ID: <20160525080946.GC20132@dhcp22.suse.cz>
References: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
 <20160524135042.GK8259@dhcp22.suse.cz>
 <20160524170746.GC11150@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524170746.GC11150@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-05-16 20:07:46, Vladimir Davydov wrote:
> On Tue, May 24, 2016 at 03:50:42PM +0200, Michal Hocko wrote:
[...]
> > It is not really pointless. The original intention was to not spam the
> > log and alarm the administrator when in fact the memory hog is exiting
> > already and will free the memory.
> 
> IMO the fact that a process, even an exiting one enters oom, is
> abnormal, indicates that the system is misconfigured, and hence should
> be reported to the admin.
> 
> > Those races is quite unlikely but not impossible.
> 
> If this case is unlikely, how can it spam the log?

The oom report can be quite large, especially on large setups. The
oom_reaper message will be much shorter and will give a clue that
an exceptional action had to be done.

> > The original check was much more optimistic as you said
> > above we have even removed one part of this heuristic. We can still end
> > up selecting an exiting task which is stuck and we could invoke the oom
> > reaper for it without excessive oom report. I agree that the current
> > check is still little bit optimistic but processes sharing the mm
> > (CLONE_VM without CLONE_THREAD/CLONE_SIGHAND) are really rare so I
> > wouldn't bother with them with a high priority.
> > 
> > That being said I would prefer to keep the check for now. After the
> > merge windlow closes I will send other oom enhancements which I have
> > half baked locally and that should make task_will_free_mem much more
> > reliable and the check would serve as a last resort to reduce oom noise.
> 
> I don't agree that a message about oom killing an exiting process is
> noise, because that shouldn't happen on a properly configured system.
> To me this racy check looks more like noise in the kernel code. By the
> time we enter oom we should have scanned lru several times to find no
> reclaimable pages. The system must be really sluggish. What's the point
> in deceiving the admin by suppressing the warning?

Well, my understanding of the OOM report is that it should tell you two
things. The first one is to give you an overview of the overal memory
situation when the system went OOM and the second one is o give you
information that something has been _killed_ and what was the criteria
why it has been selected (points). While the first one might be
interesting for what you write above the second is not and it might be
even misleading because we are not killing anything and the selected
task is dying without the kernel intervention. So I dunno. I do not see
any strong reason to drop these few lines of code which should be a
maintenance burden. task_will_free_mem will need some changes to be more
robust anyway. If you really see a strong reason to drop it because it
would help to debug OOM situation then I won't insist...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
