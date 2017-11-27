Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 157EC6B025E
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:29:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b128so10666940wme.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:29:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13si1031381edl.354.2017.11.27.00.29.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 00:29:36 -0800 (PST)
Date: Mon, 27 Nov 2017 09:29:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171127082936.27yt7sn2ucatvben@dhcp22.suse.cz>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
 <201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
 <20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
 <201711251040.IHJ00547.FOFStVJOOMHFLQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711251040.IHJ00547.FOFStVJOOMHFLQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

On Sat 25-11-17 10:40:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 24-11-17 22:21:55, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > Since we can encourage register_shrinker() callers to check for failure
> > > > > by marking register_shrinker() as __must_check, unregister_shrinker()
> > > > > can stay silent.
> > > > 
> > > > I am not sure __must_check is the right way. We already do get
> > > > allocation warning if the registration fails so silent unregister is
> > > > acceptable. Unchecked register_shrinker is a bug like any other
> > > > unchecked error path.
> > > 
> > > I consider that __must_check is the simplest way to find all of
> > > unchecked register_shrinker bugs. Why not to encourage users to fix?
> > 
> > because git grep doesn't require to patch the kernel and still provide
> > the information you want.
> 
> I can't interpret this line. How git grep relevant?

you do not have to compile to see who is checking the return value.
Seriously there is no need to overcomplicate this. Newly added shrinkers
know the function returns might fail so we just have to handle existing
users and there are not all that many of those.

> If all register_shrinker() users were careful enough to check for git history
> everytime, we would not have come to current code. It is duty of patch author
> to take necessary precautions (for in-tree code) when some API starts to
> return an error which previously did not return an error. In this case, it is
> duty of author of commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work").

Yes I agree, the change was pushed without a due review and necessary
changes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
