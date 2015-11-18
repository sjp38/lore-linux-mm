Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDCD6B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:28:09 -0500 (EST)
Received: by wmec201 with SMTP id c201so292520124wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:28:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h4si5660118wjr.235.2015.11.18.10.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:28:08 -0800 (PST)
Date: Wed, 18 Nov 2015 13:27:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151118182746.GA5093@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
 <20151116185316.GC32544@cmpxchg.org>
 <20151117201849.GQ31308@esperanza>
 <20151117222217.GA20394@cmpxchg.org>
 <20151118160253.GR31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151118160253.GR31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Nov 18, 2015 at 07:02:54PM +0300, Vladimir Davydov wrote:
> On Tue, Nov 17, 2015 at 05:22:17PM -0500, Johannes Weiner wrote:
> > On Tue, Nov 17, 2015 at 11:18:50PM +0300, Vladimir Davydov wrote:
> > > And with this patch it will work this way, but only if sum limits <
> > > total ram, which is rather rare in practice. On tightly packed
> > > systems it does nothing.
> > 
> > That's not true, it's still useful when things go south inside a
> > cgroup, even with overcommitted limits. See above.
> 
> I meant solely this patch here, not the rest of the patch set. In the
> overcommitted case there is no difference if we have the last patch or
> not AFAIU.

Even this patch, and even in the overcommitted case. When things go
bad inside a cgroup it can steal free memory (it's rare that machines
are at 100% utilization in practice) or memory from other groups until
it hits its own limit. I expect most users except, for some largescale
deployments, to frequently hit memory.high (or max) in practice.

Obviously the utopian case of full utilization will be even smoother
when we make vmpressure more finegrained, but why would that be an
argument *against* this patch here, which is useful everywhere else?

> Why can't we apply all patches but the last one (they look OK at first
> glance, but I need more time to review them carefully) and disable
> socket accounting by default for now? Then you or someone else would
> prepare a separate patch set introducing vmpressure propagation to
> socket code, so that socket accounting could be enabled by default.

This is not going to happen, and we discussed this several times
before. I really wish Michal and you would put more thought into
interface implications. It's trivial to fix up implementation if
actual shortcomings are observed, but it's nigh impossible to fix
interfaces and user-visible behavior once published. It requires
enormous undertakings such as unified hierarchy to rectify things.

Please take your time to review this series, no problem.

But I'm no longer reacting to suggestions to make interface tradeoffs
because new code is not proven to work 99% of the time. That's simply
ridiculous. Any problems will have to be fixed either way, and we're
giving users the cmdline options to work around them in the meantime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
