Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB7D36B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:43:41 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id fg3so88230651obb.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:43:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r38si2736089otb.33.2016.04.27.03.43.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 03:43:41 -0700 (PDT)
Subject: Re: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
	<201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
	<20160425114733.GF23933@dhcp22.suse.cz>
	<201604262300.IFD43745.FMOLFJFQOVStHO@I-love.SAKURA.ne.jp>
	<20160426143129.GD20813@dhcp22.suse.cz>
In-Reply-To: <20160426143129.GD20813@dhcp22.suse.cz>
Message-Id: <201604271943.IHC87554.MQJtOOFFLSFOVH@I-love.SAKURA.ne.jp>
Date: Wed, 27 Apr 2016 19:43:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Tue 26-04-16 23:00:15, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Hmm, I guess we have already discussed that in the past but I might
> > > misremember. The above relies on oom killer to be triggered after the
> > > previous victim was selected. There is no guarantee this will happen.
> > 
> > Why there is no guarantee this will happen?
> 
> What happens if you even do not hit the out_of_memory path? E.g
> GFP_FS allocation being stuck somewhere in shrinkers waiting for
> somebody to make a forward progress which never happens. Because this is
> essentially what would block the mmap_sem write holder as well and what
> you are trying to workaround by the timeout based approach.
> 

Are you talking about situations where the system hangs up before
mark_oom_victim() is called? If yes, starting a timer from mark_oom_victim()
is too late. We will need to start that timer from __alloc_pages_slowpath()
because __alloc_pages_slowpath() can sleep. Then, we don't need to consider
"OOM livelock before mark_oom_victim() is called" and "OOM livelock after
mark_oom_victim() is called" separately.

> > These OOM livelocks are caused by lack of mechanism for hearing administrator's
> > policy. We are missing rescue mechanisms which are needed for recovering from
> > situations your model did not expect.
> 
> I am not opposed against a rescue policy defined by the admin. All I
> am saying is that the only save and reasonably maintainable one with
> _predictable_ behavior I can see is to reboot/panic/killall-tasks after
> a certain timeout. You consider this to be too harsh but do you at
> least agree that the semantic of this is clear and an admin knows what
> the behavior would be? As we are not able to find a consensus on
> go-to-other-victim approach can we at least agree on the absolute last
> resort first?
> 

Which one ("OOM livelock before mark_oom_victim() is called" or "OOM livelock
after mark_oom_victim() is called") does this "the absolute last resort" apply to?

If this "the absolute last resort" applies to "OOM livelock after mark_oom_victim()
is called", what is your "the absolute last resort" for "OOM livelock before
mark_oom_victim() is called"? My suggestion is to workaround by per task_struct
timeout based approach until such workaround becomes no longer needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
