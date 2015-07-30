Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E43AB6B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 05:07:17 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so12529682wic.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 02:07:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj1si2189611wib.19.2015.07.30.02.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 02:07:15 -0700 (PDT)
Date: Thu, 30 Jul 2015 11:07:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150730090708.GE9387@dhcp22.suse.cz>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <20150729142618.GJ15801@dhcp22.suse.cz>
 <20150729152817.GV8100@esperanza>
 <20150729154718.GN15801@dhcp22.suse.cz>
 <20150729162908.GY8100@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729162908.GY8100@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 29-07-15 19:29:08, Vladimir Davydov wrote:
> On Wed, Jul 29, 2015 at 05:47:18PM +0200, Michal Hocko wrote:
[...]
> > If you use the low limit for isolating an important load then you do not
> > have to care about the others that much. All you care about is to set
> > the reasonable protection level and let others to compete for the rest.
> 
> That's a use case, you're right. Well, it's a natural limitation of this
> API - you just have to perform a full PFN scan then. You can avoid
> costly rmap walks for the cgroups you are not interested in by filtering
> them out using /proc/kpagecgroup though.

You still have to read through the whole memory and that is inherent to
the API and there no way for a better implementation later on other than
a new exported file.

[...]

> > > Because there is too much to be taken care of in the kernel with such an
> > > approach and chances are high that it won't satisfy everyone. What
> > > should the scan period be equal too?
> > 
> > No, just gather the data on the read request and let the userspace
> > to decide when/how often etc. If we are clever enough we can cache
> > the numbers and prevent from the walk. Write to the file and do the
> > mark_idle stuff.
> 
> Still, scan rate limiting would be an issue IMO.

Not sure what you mean here. Scan rate would be defined by the userspace
by reading/writing to the knob. No background kernel thread is really
necessary.

> > > Knob. How many kthreads do we want?
> > > Knob. I want to keep history for last N intervals (this was a part of
> > > Michel's implementation), what should N be equal to? Knob.
> > 
> > This all relates to the kernel thread implementation which I wasn't
> > suggesting. I was referring to Michel's work which might induce that.
> > I was merely referring to a single number output. Sorry about the
> > confusion.
> 
> Still, what about idle stats history? I mean having info about how many
> pages were idle for N scans. It might be useful for more robust/accurate
> wss estimation.

Why cannot userspace remember those numbers?

> > > I want to be
> > > able to choose between an instant scan and a scan distributed in time.
> > > Knob. I want to see stats for anon/locked/file/dirty memory separately,
> > 
> > Why is this useful for the memcg limits setting or the wss estimation? I
> > can imagine that a further drop down numbers might be interesting
> > from the debugging POV but I fail to see what kind of decisions from
> > userspace you would do based on them.
> 
> A couple examples that pop up in my mind:
> 
> It's difficult to make wss estimation perfect. By mlocking pages, a
> workload might give a hint to the system that it will be really unhappy
> if they are evicted.
> 
> One might want to consider anon pages and/or dirty pages as not idle in
> order to protect them and hence avoid expensive pageout/swapout.

I still seem to miss the point. How do you do that via the proposed
interface which doesn't influence the reclaim AFAIU and you do not have
means to achieve the above (except for swappiness). What am I missing?

> > [...]
> > > > Yes this is really tricky with the current LRU implementation. I
> > > > was playing with some ideas (do some checkpoints on the way) but
> > > > none of them was really working out on a busy systems. But the LRU
> > > > implementation might change in the future.
> > > 
> > > It might. Then we could come up with a new /proc or /sys file which
> > > would do the same as /proc/kpageidle, but on per LRU^w whatever-it-is
> > > basis, and give people a choice which one to use.
> > 
> > This just leads to proc files count explosion we are seeing
> > already... Proc ended up in dump ground for different things which
> > didn't fit elsewhere and I am not very much happy about it to be honest.
> 
> Moving the API to memcg is not a good idea either IMO, because the
> feature can actually be useful with memcg disabled, e.g. it might help
> estimate if the system is over- or underloaded.

I agree and that's why I was referring to memcg/global knobs.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
