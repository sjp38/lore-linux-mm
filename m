Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2316B00D1
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:41:24 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so121741688wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:41:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si16178194wjr.212.2015.05.19.08.41.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 08:41:22 -0700 (PDT)
Date: Tue, 19 May 2015 16:41:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519154119.GI2462@suse.de>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519145340.GI6203@dhcp22.suse.cz>
 <20150519151302.GG2462@suse.de>
 <20150519152710.GK6203@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150519152710.GK6203@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue, May 19, 2015 at 05:27:10PM +0200, Michal Hocko wrote:
> On Tue 19-05-15 16:13:02, Mel Gorman wrote:
> [...]
> >                :ffffffff811c160f:       je     ffffffff811c1630 <mem_cgroup_try_charge+0x40>
> >                :ffffffff811c1611:       xor    %eax,%eax
> >                :ffffffff811c1613:       xor    %ebx,%ebx
> >      1 1.7e-05 :ffffffff811c1615:       mov    %rbx,(%r12)
> >      7 1.2e-04 :ffffffff811c1619:       add    $0x10,%rsp
> >   1211  0.0203 :ffffffff811c161d:       pop    %rbx
> >      5 8.4e-05 :ffffffff811c161e:       pop    %r12
> >      5 8.4e-05 :ffffffff811c1620:       pop    %r13
> >   1249  0.0210 :ffffffff811c1622:       pop    %r14
> >      7 1.2e-04 :ffffffff811c1624:       pop    %rbp
> >      5 8.4e-05 :ffffffff811c1625:       retq   
> >                :ffffffff811c1626:       nopw   %cs:0x0(%rax,%rax,1)
> >    295  0.0050 :ffffffff811c1630:       mov    (%rdi),%rax
> > 160703  2.6973 :ffffffff811c1633:       mov    %edx,%r13d
> 
> Huh, what? Even if this was off by one and the preceding instruction has
> consumed the time. This would be reading from page->flags but the page
> should be hot by the time we got here, no?
> 

I would have expected so but it's not the first time I've seen cases where
examining the flags was a costly instruction. I suspect it's due to an
ordering issue or more likely, a frequent branch mispredict that is being
accounted for against this instruction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
