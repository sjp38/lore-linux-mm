Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6790B6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:00:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t124so152355513pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 15:00:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d207si6797510pfd.66.2016.04.14.15.00.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 15:00:02 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Clarify reason to kill other threads sharing the vitctim's memory.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160414113108.GE2850@dhcp22.suse.cz>
	<201604150003.GAI13041.MLHFOtOFOQSJVF@I-love.SAKURA.ne.jp>
	<20160414151838.GK2850@dhcp22.suse.cz>
In-Reply-To: <20160414151838.GK2850@dhcp22.suse.cz>
Message-Id: <201604150659.BFI12469.tHLSOFMOJFQVFO@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 06:59:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 15-04-16 00:03:31, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > I would rather be explicit that we _do not care_
> > > about these configurations. It is just PITA maintain and it doesn't make
> > > any sense. So rather than trying to document all the weird thing that
> > > might happen I would welcome a warning "mm shared with OOM_SCORE_ADJ_MIN
> > > task. Something is broken in your configuration!"
> > 
> > Would you please stop rejecting configurations which do not match your values?
> 
> Can you point out a single real life example where the above
> configuration would make a sense? This is not about _my_ values. This is
> about general _sanity_. If two/more entities share the mm and they disagree
> about their OOM priorities then something is clearly broken. Don't you think?
> How can the OOM killer do anything sensible here? The API we have
> created is broken because it allows broken configurations too easily. It
> is too late to fix it though so we can only rely on admins to use it
> sensibly.

I explained it at http://lkml.kernel.org/r/201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp .
I don't do such usage does not mean nobody does such usage.

> 
> So please try to step back and think about whether it actually make
> sense to make the oom even more complex/confusing for something that
> gives little (if any) sense.

Syscalls respond with "your usage is invalid" (by returning -EINVAL)
than "ignore such usage and crash" (by triggering kernel panic).
Why the OOM killer cannot respond with "I need to kill a different victim"
than "ignore and silently hang up" ? Doing so with bounded wait is trivial
and also helps "Whenever we select a victim and call mark_oom_victim
we hope it will eventually get out of its kernel code path" problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
