Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B986440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:48:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b20so9062096wmd.6
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:48:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15si2202909wme.83.2017.07.14.05.48.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:48:36 -0700 (PDT)
Date: Fri, 14 Jul 2017 14:48:33 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170714124833.GO2618@dhcp22.suse.cz>
References: <20170711134900.GD11936@dhcp22.suse.cz>
 <201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
 <20170712085431.GD28912@dhcp22.suse.cz>
 <201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
 <20170712124145.GI28912@dhcp22.suse.cz>
 <201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

On Fri 14-07-17 21:30:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > As I've said earlier, if there is no other way to make printk work without all
> > these nasty side effected then I would be OK to add a printk context
> > specific calls into the oom killer.
> > 
> > Removing the rest because this is again getting largely tangent. The
> > primary problem you are seeing is that we stumble over printk here.
> > Unless I can see a sound argument this is not the case it doesn't make
> > any sense to discuss allocator changes.
> 
> You are still ignoring my point. I agree that we stumble over printk(), but
> printk() is nothing but one of locations we stumble.

I am not ignoring it. You just mix too many things together to have a
meaningful conversation...
 
> Look at schedule_timeout_killable(1) in out_of_memory() which is called with
> oom_lock still held. I'm reporting that even printk() is offloaded to printk
> kernel thread, scheduling priority can make schedule_timeout_killable(1) sleep
> for more than 12 minutes (which is intended to sleep for only one millisecond).
> (I gave up waiting and pressed SysRq-i. I can't imagine how long it would have
> continued sleeping inside schedule_timeout_killable(1) with oom_lock held.)
> 
> Without cooperation from other allocating threads which failed to hold oom_lock,
> it is dangerous to keep out_of_memory() preemptible/schedulable context.

I have already tried to explain that this is something that the whole
reclaim path suffers from the priority inversions problem because it has
never been designed to handle that. You are just poking to one
particular path of the reclaim stack and missing the whole forest for a
tree. How the hack is this any different from a reclaim path stumbling
over a lock down inside the filesystem and stalling basically everybody
from making a reasonable progress? Is this a problem? Of course it is,
theoretically. In practice not all that much to go and reimplement the
whole stack. At least I haven't seen any real life reports complaining
about this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
