Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 283066B02F2
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 06:42:02 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p187so201295566wmp.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:42:02 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id yv10si31212194wjc.217.2015.12.25.03.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 03:42:01 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id p187so199070730wmp.0
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:42:01 -0800 (PST)
Date: Fri, 25 Dec 2015 12:41:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151225114159.GB6754@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
 <20151224094758.GA22760@dhcp22.suse.cz>
 <201512242006.CGJ81784.SVMHOOQtLFFFOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512242006.CGJ81784.SVMHOOQtLFFFOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: zwisler@gmail.com, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ross.zwisler@linux.intel.com

On Thu 24-12-15 20:06:50, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > This is VM_BUG_ON_PAGE(page_mapped(page), page), right? Could you attach
> > the full kernel log? It all smells like a race when OOM reaper tears
> > down the mapping and there is a truncate still in progress. But hitting
> > the BUG_ON just because of that doesn't make much sense to me. OOM
> > reaper is essentially MADV_DONTNEED. I have to think about this some
> > more, though, but I am in a holiday mode until early next year so please
> > bear with me.
> 
> I don't know whether the OOM killer was invoked just before this
> VM_BUG_ON_PAGE().
> 
> > Is this somehow DAX related?
> 
> 4.4.0-rc6-next-20151223_new_fsync_v6+ suggests that this kernel
> has "[PATCH v6 0/7] DAX fsync/msync support" applied. But I think
> http://marc.info/?l=linux-mm&m=145068666428057 should be applied
> when retesting. (20151223 does not have this fix.)

Hmm, I think you are right! Very well spotted! If ignore_dirty ends up
being true then we would simply skip over dirty page and wouldn't end up
doing page_remove_rmap. I can see that the truncation code can later trip
over this page.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
