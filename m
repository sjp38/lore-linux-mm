Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFDB900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 08:29:44 -0500 (EST)
Received: by paceu11 with SMTP id eu11so9456246pac.10
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 05:29:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m2si12115140pdo.181.2015.02.19.05.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 05:29:42 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150218082502.GA4478@dhcp22.suse.cz>
	<20150218104859.GM12722@dastard>
	<20150218121602.GC4478@dhcp22.suse.cz>
	<20150219110124.GC15569@phnom.home.cmpxchg.org>
	<20150219122914.GH28427@dhcp22.suse.cz>
In-Reply-To: <20150219122914.GH28427@dhcp22.suse.cz>
Message-Id: <201502192229.FCJ73987.MFQLOHSJFFtOOV@I-love.SAKURA.ne.jp>
Date: Thu, 19 Feb 2015 22:29:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

Michal Hocko wrote:
> On Thu 19-02-15 06:01:24, Johannes Weiner wrote:
> [...]
> > Preferrably, we'd get rid of all nofail allocations and replace them
> > with preallocated reserves.  But this is not going to happen anytime
> > soon, so what other option do we have than resolving this on the OOM
> > killer side?
> 
> As I've mentioned in other email, we might give GFP_NOFAIL allocator
> access to memory reserves (by giving it __GFP_HIGH). This is still not a
> 100% solution because reserves could get depleted but this risk is there
> even with multiple oom victims. I would still argue that this would be a
> better approach because selecting more victims might hit pathological
> case more easily (other victims might be blocked on the very same lock
> e.g.).
> 
Does "multiple OOM victims" mean "select next if first does not die"?
Then, I think my timeout patch http://marc.info/?l=linux-mm&m=142002495532320&w=2
does not deplete memory reserves. ;-)

If we change to permit invocation of the OOM killer for GFP_NOFS / GFP_NOIO,
those who do not want to fail (e.g. journal transaction) will start passing
__GFP_NOFAIL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
