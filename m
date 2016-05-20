Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 796CB6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 02:17:02 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so41804649lbc.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:17:02 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ro5si23547985wjb.77.2016.05.19.23.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 23:17:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 67so3293635wmg.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:17:00 -0700 (PDT)
Date: Fri, 20 May 2016 08:16:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160520061658.GB19172@dhcp22.suse.cz>
References: <20160520013053.GB2224@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520013053.GB2224@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 20-05-16 10:30:53, Minchan Kim wrote:
> Forking new thread because my comment is not related to this patch's
> purpose but found a thing during reading this patch.
> 
> On Tue, Apr 26, 2016 at 04:04:30PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo has properly noted that mmput slow path might get blocked waiting
> > for another party (e.g. exit_aio waits for an IO). If that happens the
> > oom_reaper would be put out of the way and will not be able to process
> > next oom victim. We should strive for making this context as reliable
> > and independent on other subsystems as much as possible.
> > 
> > Introduce mmput_async which will perform the slow path from an async
> > (WQ) context. This will delay the operation but that shouldn't be a
> > problem because the oom_reaper has reclaimed the victim's address space
> > for most cases as much as possible and the remaining context shouldn't
> > bind too much memory anymore. The only exception is when mmap_sem
> > trylock has failed which shouldn't happen too often.
> > 
> > The issue is only theoretical but not impossible.
> 
> The mmput_async is used for only OOM reaper which is enabled on CONFIG_MMU.
> So until someone who want to use mmput_async in !CONFIG_MMU come out,
> we could save sizeof(struct work_struct) per mm in !CONFIG_MMU.

You are right. What about the following?
---
