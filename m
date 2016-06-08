Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7356B0266
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:05:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so8550075wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:05:13 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id jo1si2209789wjc.193.2016.06.08.09.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 09:05:12 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r5so4152752wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:05:11 -0700 (PDT)
Date: Wed, 8 Jun 2016 18:05:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160608160509.GA21838@dhcp22.suse.cz>
References: <20160606083651.GE11895@dhcp22.suse.cz>
 <201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
 <20160607150534.GO12305@dhcp22.suse.cz>
 <201606080649.DGF51523.FLMOSHVtFFOJOQ@I-love.SAKURA.ne.jp>
 <20160608072741.GE22570@dhcp22.suse.cz>
 <201606082355.EIJ05259.OHQLFtFOJFOMSV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606082355.EIJ05259.OHQLFtFOJFOMSV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 08-06-16 23:55:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 08-06-16 06:49:24, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > OK, so you are arming the timer for each mark_oom_victim regardless
> > > > of the oom context. This means that you have replaced one potential
> > > > lockup by other potential livelocks. Tasks from different oom domains
> > > > might interfere here...
> > > > 
> > > > Also this code doesn't even seem easier. It is surely less lines of
> > > > code but it is really hard to realize how would the timer behave for
> > > > different oom contexts.
> > > 
> > > If you worry about interference, we can use per signal_struct timestamp.
> > > I used per task_struct timestamp in my earlier versions (where per
> > > task_struct TIF_MEMDIE check was used instead of per signal_struct
> > > oom_victims).
> > 
> > This would allow pre-mature new victim selection for very large victims
> > (note that exit_mmap can take a while depending on the mm size). It also
> > pushed the timeout heuristic for everybody which will sooner or later
> > open a question why is this $NUMBER rathen than $NUMBER+$FOO.
> 
> You are again worrying about wrong problem. You are ignoring distinction
> between genuine lock up (real problem for you) and effectively locked up
> (real problem for administrators).

No, I just do care more about a sane and consistent behavior rather than
a random one which is inherent to timeout based solutions.

[...]
> > To be honest I would rather explore ways to handle kthread case (which
> > is the only real one IMHO from the two) gracefully and made them a
> > nonissue - e.g. enforce EFAULT on a dead mm during the kthread page fault
> > or something similar.
> 
> You are always living in a world with plenty resource. You tend to ignore
> CONFIG_MMU=n kernels.

You keep repeating !CONFIG_MMU case but never shown a single evidence
this is an actual problem for those platforms. If this turns out to
be a real problem I am willing to spend time on it and try to find a
solution.

I am sorry, I have left most of your email without any reaction. I
just don't believe repeating the same arguments is anyhow useful or
productive. Quite some time ago I've told that I strongly believe that
doing any timeout based heuristic should be only the last resort when we
fail all other ways to mitigate the issue. I think I've shown that there
is a path, which btw. doesn't add too much code into the oom path. All
the patches are self rather small incrementally improve the situation. I
have already told you that you, as a reviewer, are free to nack those
patches if you believe they are incorrect, unmaintainable or actively
harmful to the common case. Unless you do so with a proper justification
I will not react to any timeout based solutions.

I will post the full series with all the remaining fixups tomorrow and
let all the reviewers to judge. I strongly believe that it puts some
order to the code and makes it easier to reason about. If this view
is not shared by others I can back off and not pursue this path any
longer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
