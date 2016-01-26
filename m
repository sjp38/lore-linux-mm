Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 969926B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:44:02 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n5so120527224wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:44:02 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id jn10si744490wjb.31.2016.01.26.01.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 01:44:01 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id n5so120526318wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:44:01 -0800 (PST)
Date: Tue, 26 Jan 2016 10:43:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160126094359.GB27563@dhcp22.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <56A63A6C.9070301@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A63A6C.9070301@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue 26-01-16 00:08:28, Tetsuo Handa wrote:
[...]
> If it turned out that we are using GFP_NOFS from LSM hooks correctly,
> I'd expect such GFP_NOFS allocations retry unless SIGKILL is pending.
> Filesystems might be able to handle GFP_NOFS allocation failures. But
> userspace might not be able to handle system call failures caused by
> GFP_NOFS allocation failures; OOM-unkillable processes might unexpectedly
> terminate as if they are OOM-killed. Would you please add GFP_KILLABLE
> to list of the topics?

Are there so many places to justify a flag? Isn't it easier to check for
fatal_signal_pending in the failed path and do the retry otherwise? This
allows for a more flexible fallback strategy - e.g. drop the locks and
retry again, sleep for reasonable time, wait for some event etc... This
sounds much more extensible than a single flag burried down in the
allocator path. Besides that all allocations besides __GFP_NOFAIL and
GFP_NOFS are already killable. The first one by definition and the later
one because of the current implementation restrictions which we can
hopefully fix longterm.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
