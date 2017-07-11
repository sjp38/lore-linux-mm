Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4706B0510
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:58:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z1so499255wrz.10
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:58:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a62si110160wrc.296.2017.07.11.07.58.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 07:58:30 -0700 (PDT)
Date: Tue, 11 Jul 2017 16:58:28 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170711145828.GB3393@pathway.suse.cz>
References: <20170602071818.GA29840@dhcp22.suse.cz>
 <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
 <20170710132139.GJ19185@dhcp22.suse.cz>
 <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
 <20170710141428.GL19185@dhcp22.suse.cz>
 <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
 <20170711134900.GD11936@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711134900.GD11936@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com

On Tue 2017-07-11 15:49:00, Michal Hocko wrote:
> On Tue 11-07-17 22:10:36, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 10-07-17 22:54:37, Tetsuo Handa wrote:
> > > > What makes this situation worse is, since warn_alloc() periodically appends to
> > > > printk() buffer, the thread inside the OOM killer with oom_lock held can stall
> > > > forever due to cond_resched() from console_unlock() from printk().
> > > 
> > > warn_alloc is just yet-another-user of printk. We might have many
> > > others...

> because you are trying to address a problem at a wrong layer. If there
> is absolutely no way around it and printk is unfixable then we really
> need a printk variant which will make sure that no excessive waiting
> will be involved. Then we can replace all printk in the oom path with
> this special printk.

The last theory about printk offloading suggests that printk() should
always try to push some messages to the console when the console lock is
available. Otherwise, the messages might not appear at all because
the offloading is never 100% reliable, especially when the system is
in troubles.

In each case, this live-lock is another reason to risk the printk
offload at some stage.

Of course, we could make the throttling more aggressive. But it
is another complex problem. Only printk() knows how much it is
stressed and how much throttling is needed. On the other hand,
it might be hard to know what information is repeating and
who need to be throttled. It is a question if it should be
solved by providing more printk_throttle() variants or
by some magic inside normal printk().

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
