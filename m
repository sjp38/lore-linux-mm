Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C749A6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 09:07:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b5-v6so1577521pfi.5
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 06:07:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 84-v6si2267234pfa.60.2018.06.20.06.07.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 06:07:49 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:07:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180620130746.GN13685@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
 <f6e65320-d8d3-f1ff-0346-13d1446c2675@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6e65320-d8d3-f1ff-0346-13d1446c2675@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 20-06-18 21:21:21, Tetsuo Handa wrote:
> On 2018/06/20 20:55, Michal Hocko wrote:
> > On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
> >> Sleeping with oom_lock held can cause AB-BA lockup bug because
> >> __alloc_pages_may_oom() does not wait for oom_lock. Since
> >> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
> >> with oom_lock held is currently an unavoidable problem.
> > 
> > Could you be more specific about the potential deadlock? Sleeping while
> > holding oom lock is certainly not nice but I do not see how that would
> > result in a deadlock assuming that the sleeping context doesn't sleep on
> > the memory allocation obviously.
> 
> "A" is "owns oom_lock" and "B" is "owns CPU resources". It was demonstrated
> at "mm,oom: Don't call schedule_timeout_killable() with oom_lock held." proposal.

This is not a deadlock but merely a resource starvation AFAIU.

> But since you don't accept preserving the short sleep which is a heuristic for
> reducing the possibility of AB-BA lockup, the only way we would accept will be
> wait for the owner of oom_lock (e.g. by s/mutex_trylock/mutex_lock/ or whatever)
> which is free of heuristic and free of AB-BA lockup.
> 
> > 
> >> As a preparation for not to sleep with oom_lock held, this patch brings
> >> OOM notifier callbacks to outside of OOM killer, with two small behavior
> >> changes explained below.
> > 
> > Can we just eliminate this ugliness and remove it altogether? We do not
> > have that many notifiers. Is there anything fundamental that would
> > prevent us from moving them to shrinkers instead?
> > 
> 
> For long term, it would be possible. But not within this patch. For example,
> I think that virtio_balloon wants to release memory only when we have no
> choice but OOM kill. If virtio_balloon trivially releases memory, it will
> increase the risk of killing the entire guest by OOM-killer from the host
> side.

I would _prefer_ to think long term here. The sleep inside the oom lock is
not something real workload are seeing out there AFAICS. Adding quite
some code to address such a case doesn't justify the inclusion IMHO.

-- 
Michal Hocko
SUSE Labs
