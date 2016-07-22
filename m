Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3506B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 07:09:09 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so70466151lfi.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:09:09 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id s2si359559wjc.195.2016.07.22.04.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 04:09:08 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so5730750wmg.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:09:08 -0700 (PDT)
Date: Fri, 22 Jul 2016 13:09:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160722110906.GI794@dhcp22.suse.cz>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160707083932.GD5379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707083932.GD5379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Thu 07-07-16 10:39:32, Michal Hocko wrote:
> On Sun 03-07-16 17:09:04, Michael S. Tsirkin wrote:
> [...]
> > Having said all that, how about we just add some kind of per-mm
> > notifier list, and let vhost know that owner is going away so
> > it should stop looking at memory?
> 
> But this would have to be a synchronous operation from the oom killer,
> no? I would really like to reduce the number of external dependencies
> from the oom killer paths as much as possible. This is the whole point
> of these patches. If we have a notification mechanism, what would
> guarantee that the oom killer would make a forward progress if the
> notified end cannot continue (wait for a lock etc...)?
> 
> I do realize that a test per each memory access is not welcome that
> much. An alternative would be to hook the check into the page fault
> handler because then the overhead would be reduced only to the slowpath
> (from the copy_from_user POV). But then also non use_mm users would have
> to pay the price which is even less attractive.
> 
> Another alternative would be disabling pagefaults when copying from the
> userspace. This would require that the memory is prefault when used
> which might be a problem for the current implementation.

ping Michael... I would like to pursue this again and have something for
4.9 ideally.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
