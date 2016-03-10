Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8DA6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 19:45:12 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so8313731wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 16:45:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s204si1515491wmd.36.2016.03.09.16.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 16:45:11 -0800 (PST)
Date: Wed, 9 Mar 2016 19:45:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2]
 oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Message-ID: <20160310004500.GA7374@cmpxchg.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
 <1457442737-8915-3-git-send-email-mhocko@kernel.org>
 <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
 <201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
 <20160309224829.GA5716@cmpxchg.org>
 <20160309150853.2658e3bc75907e404cf3ca33@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160309150853.2658e3bc75907e404cf3ca33@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.com

On Wed, Mar 09, 2016 at 03:08:53PM -0800, Andrew Morton wrote:
> On Wed, 9 Mar 2016 17:48:29 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > However, I disagree with your changelog.
> 
> What text would you prefer?

I'd just keep the one you had initially. Or better, this modified
version:

When the OOM killer scans tasks and encounters a PF_EXITING one, it
force-selects that task regardless of the score. The problem is that
if that task got stuck waiting for some state the allocation site is
holding, the OOM reaper can not move on to the next best victim.

Frankly, I don't even know why we check for exiting tasks in the OOM
killer. We've tried direct reclaim at least 15 times by the time we
decide the system is OOM, there was plenty of time to exit and free
memory; and a task might exit voluntarily right after we issue a kill.
This is testing pure noise. Remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
