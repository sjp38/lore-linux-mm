Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB586B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:04:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w130so9038844lfd.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:04:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 131si2768529wmj.63.2016.07.07.04.04.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:04:24 -0700 (PDT)
Date: Thu, 7 Jul 2016 13:04:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160707110419.GF5379@dhcp22.suse.cz>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Sun 03-07-16 11:35:56, Tetsuo Handa wrote:
> This is my alternative proposal compared to what Michal posted at
> http://lkml.kernel.org/r/1467365190-24640-1-git-send-email-mhocko@kernel.org .
> 
> The series is based on top of linux-next-20160701 +
> http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .
> 
> The key point of the series is [PATCH 3/8].

I have only checked the diff between the whole patchset applied with
what I have posted as an RFC last week, so I cannot comment on specific
patches.  Let me summarize the differences between the two approaches
though.

My proposal adds a stable reference of the killed mm struct into the
signal struct and most oom decisions can refer to this mm and its flags
because signal struct life time exceeds its visible task_struct. We still
need signal->oom_victims counter to catch different threads lifetime.

Yours enqueues the mm to a linked list and has a similar effect with
an advantage that signal->oom_victims is no longer needed because you
have pulled the OOM_SCAN_ABORT out of select_bad_process to earlier
{mem_cgroup_}out_of_memory and check existence of a compatible mm for
the oom domain. This means that mm struct has to remember all the
information that might be gone by the time we look at the enqueued mm
again. This means a slightly larger memory foot print (nothing earth
shattering though).

That being said, I believe both approaches are sound. So let's discuss
{ad,dis}vantages of those approaches.

You are introducing more code but to be fair I guess the mm rather than
task queuing is better long term. Copying the state for later use is
unfortunate but it might turn out better to have all the oom specific
stuff inside the mm rather than spread around in other structures.

As I've said I haven't looked very deeply into details but at least
memcg handling would need more work, I will respond to the specific
patch.

I guess the mm visibility is basically same with both approaches. Even
though you hide the mm from __mmput while mine has it alive until signal
struct goes away this is basically the equivalent because mine is hiding
the mm with MMF_OOM_REAPED from the oom reaper and oom_reaper is just a
weaker form of __mmput.

I am not tight to my approach but could you name main arguments why you
think yours is better?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
