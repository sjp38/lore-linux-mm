Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 713B76B00D6
	for <linux-mm@kvack.org>; Tue, 19 May 2015 12:14:33 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so123940754wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 09:14:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qn7si1133409wjc.202.2015.05.19.09.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 09:14:31 -0700 (PDT)
Date: Tue, 19 May 2015 12:14:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519161422.GA10561@cmpxchg.org>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519145340.GI6203@dhcp22.suse.cz>
 <20150519151302.GG2462@suse.de>
 <555B55F0.7030907@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555B55F0.7030907@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue, May 19, 2015 at 05:25:36PM +0200, Vlastimil Babka wrote:
> On 05/19/2015 05:13 PM, Mel Gorman wrote:
> >### MEL: Function entry, check for mem_cgroup_disabled()
> >
> >
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
> >160703  2.6973 :ffffffff811c1633:       mov    %edx,%r13d
> >
> >#### MEL: I was surprised to see this atrocity. It's a PageSwapCache check
> 
> Looks like sampling is off by instruction, because why would a reg->reg mov
> took so long. So it's probably a cache miss on struct page, pointer to which
> is in rdi. Which is weird, I would expect memcg to be called on struct pages
> that are already hot.

Yeah, anonymous faults do __SetPageUptodate() right before passing the
page into mem_cgroup_try_charge().  page->flags should be hot.

> It would also mean that if you don't fetch the struct
> page from the memcg code, then the following code in the caller will most
> likely work on the struct page and get the cache miss anyway?

Which is why the runtime reduction doesn't match the profile
reduction.  The cost seems to get shifted somewhere else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
