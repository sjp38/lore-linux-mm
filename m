Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9E72E6B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 14:21:47 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so31288713pac.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:21:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b15si5436785pbu.250.2015.09.04.11.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 11:21:46 -0700 (PDT)
Date: Fri, 4 Sep 2015 21:21:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150904182110.GE13699@esperanza>
References: <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
 <20150903163243.GD10394@mtj.duckdns.org>
 <20150904111550.GB13699@esperanza>
 <20150904154448.GA25329@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150904154448.GA25329@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tejun, Michal

On Fri, Sep 04, 2015 at 11:44:48AM -0400, Tejun Heo wrote:
...
> > I admit I may be mistaken, but if I'm right, we may end up with really
> > complex memcg reclaim logic trying to closely mimic behavior of buddy
> > alloc with all its historic peculiarities. That's why I don't want to
> > rush ahead "fixing" memcg reclaim before an agreement among all
> > interested people is reached...
> 
> I think that's a bit out of proportion.  I'm not suggesting bringing
> in all complexities of global reclaim.  There's no reason to and what
> memcg deals with is inherently way simpler than actual memory
> allocation.  The original patch was about fixing systematic failure
> around GFP_NOWAIT close to the high limit.  We might want to do
> background reclaim close to max but as long as high limit functions
> correctly, that's much less of a problem at least on the v2 interface.

Looking through this thread once again and weighting my arguments vs
yours, I start to understand that I'm totally wrong and these patches
are not proper fixes for the problem.

Having these patches in the kernel only helps when we are hitting the
hard limit, which shouldn't occur often if memory.high works properly.
Even if memory.high is not used, the only negative effect we would get
w/o them is allocating a slab from a wrong node or getting a low order
page where we could get a high order one. Both should be rare and both
aren't critical. I think I got carried away with all those obscure
"reclaimer peculiarities" at some point.

Now I think task_work reclaim initially proposed by Tejun would be a
much better fix.

I'm terribly sorry for being so annoying and stubborn and want to thank
you for all your feedback!

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
