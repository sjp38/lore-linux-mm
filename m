Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A006B6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 21:30:57 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id dh6so166532943obb.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 18:30:57 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id fp9si2027569igb.56.2016.05.19.18.30.55
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 18:30:56 -0700 (PDT)
Date: Fri, 20 May 2016 10:30:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160520013053.GB2224@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Forking new thread because my comment is not related to this patch's
purpose but found a thing during reading this patch.

On Tue, Apr 26, 2016 at 04:04:30PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo has properly noted that mmput slow path might get blocked waiting
> for another party (e.g. exit_aio waits for an IO). If that happens the
> oom_reaper would be put out of the way and will not be able to process
> next oom victim. We should strive for making this context as reliable
> and independent on other subsystems as much as possible.
> 
> Introduce mmput_async which will perform the slow path from an async
> (WQ) context. This will delay the operation but that shouldn't be a
> problem because the oom_reaper has reclaimed the victim's address space
> for most cases as much as possible and the remaining context shouldn't
> bind too much memory anymore. The only exception is when mmap_sem
> trylock has failed which shouldn't happen too often.
> 
> The issue is only theoretical but not impossible.

The mmput_async is used for only OOM reaper which is enabled on CONFIG_MMU.
So until someone who want to use mmput_async in !CONFIG_MMU come out,
we could save sizeof(struct work_struct) per mm in !CONFIG_MMU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
