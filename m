Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 04C546B00DD
	for <linux-mm@kvack.org>; Tue, 19 May 2015 15:32:42 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so29490374wgj.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 12:32:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl7si4567027wjb.210.2015.05.19.12.32.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 12:32:40 -0700 (PDT)
Date: Tue, 19 May 2015 20:32:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519193236.GM2462@suse.de>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519145340.GI6203@dhcp22.suse.cz>
 <20150519151302.GG2462@suse.de>
 <20150519152710.GK6203@dhcp22.suse.cz>
 <20150519154119.GI2462@suse.de>
 <20150519160404.GJ2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150519160404.GJ2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue, May 19, 2015 at 05:04:04PM +0100, Mel Gorman wrote:
> On Tue, May 19, 2015 at 04:41:19PM +0100, Mel Gorman wrote:
> > On Tue, May 19, 2015 at 05:27:10PM +0200, Michal Hocko wrote:
> > > On Tue 19-05-15 16:13:02, Mel Gorman wrote:
> > > [...]
> > > >                :ffffffff811c160f:       je     ffffffff811c1630 <mem_cgroup_try_charge+0x40>
> > > >                :ffffffff811c1611:       xor    %eax,%eax
> > > >                :ffffffff811c1613:       xor    %ebx,%ebx
> > > >      1 1.7e-05 :ffffffff811c1615:       mov    %rbx,(%r12)
> > > >      7 1.2e-04 :ffffffff811c1619:       add    $0x10,%rsp
> > > >   1211  0.0203 :ffffffff811c161d:       pop    %rbx
> > > >      5 8.4e-05 :ffffffff811c161e:       pop    %r12
> > > >      5 8.4e-05 :ffffffff811c1620:       pop    %r13
> > > >   1249  0.0210 :ffffffff811c1622:       pop    %r14
> > > >      7 1.2e-04 :ffffffff811c1624:       pop    %rbp
> > > >      5 8.4e-05 :ffffffff811c1625:       retq   
> > > >                :ffffffff811c1626:       nopw   %cs:0x0(%rax,%rax,1)
> > > >    295  0.0050 :ffffffff811c1630:       mov    (%rdi),%rax
> > > > 160703  2.6973 :ffffffff811c1633:       mov    %edx,%r13d
> > > 
> > > Huh, what? Even if this was off by one and the preceding instruction has
> > > consumed the time. This would be reading from page->flags but the page
> > > should be hot by the time we got here, no?
> > > 
> > 
> > I would have expected so but it's not the first time I've seen cases where
> > examining the flags was a costly instruction. I suspect it's due to an
> > ordering issue or more likely, a frequent branch mispredict that is being
> > accounted for against this instruction.
> > 
> 
> Which is plausible as forward branches are statically predicted false but
> in this particular load that could be a close to a 100% mispredict.
> 

Plausible but wrong. The responsible instruction was too far away so it
looks more like an ordering issue where the PageSwapCache check must be
ordered against the setting of page up to date. __SetPageUptodate is a
barrier that is necessary before the PTE is established and visible but it
does not have to be ordered against the memcg charging. In fact it makes
sense to do it afterwards in case the charge fails and the page is never
visible. Just adjusting that reduces the cost to

/usr/src/linux-4.0-chargefirst-v1r1/mm/memcontrol.c                  3.8547   228233
  __mem_cgroup_count_vm_event                                                  1.172%    69393
  mem_cgroup_page_lruvec                                                       0.464%    27456
  mem_cgroup_commit_charge                                                     0.390%    23072
  uncharge_list                                                                0.327%    19370
  mem_cgroup_update_lru_size                                                   0.284%    16831
  get_mem_cgroup_from_mm                                                       0.262%    15523
  mem_cgroup_try_charge                                                        0.256%    15147
  memcg_check_events                                                           0.222%    13120
  mem_cgroup_charge_statistics.isra.22                                         0.194%    11470
  commit_charge                                                                0.145%     8615
  try_charge                                                                   0.139%     8236

Big sinner there is updating per-cpu stats -- root cgroup stats I assume? To
refresh, a complete disable looks like

/usr/src/linux-4.0-nomemcg-v1r1/mm/memcontrol.c                      0.4834    27511
  mem_cgroup_page_lruvec                                                       0.161%     9172
  mem_cgroup_update_lru_size                                                   0.154%     8794
  mem_cgroup_try_charge                                                        0.126%     7194
  mem_cgroup_commit_charge                                                     0.041%     2351

Still, 6.64% down to 3.85% is better than a kick in the head. Unprofiled
performance looks like

pft faults
                                       4.0.0                  4.0.0                 4.0.0
                                     vanilla             nomemcg-v1        chargefirst-v1
Hmean    faults/cpu-1 1443258.1051 (  0.00%) 1530574.6033 (  6.05%) 1487623.0037 (  3.07%)
Hmean    faults/cpu-3 1340385.9270 (  0.00%) 1375156.5834 (  2.59%) 1351401.2578 (  0.82%)
Hmean    faults/cpu-5  875599.0222 (  0.00%)  876217.9211 (  0.07%)  876122.6489 (  0.06%)
Hmean    faults/cpu-7  601146.6726 (  0.00%)  599068.4360 ( -0.35%)  600944.9229 ( -0.03%)
Hmean    faults/cpu-8  510728.2754 (  0.00%)  509887.9960 ( -0.16%)  510906.3818 (  0.03%)
Hmean    faults/sec-1 1432084.7845 (  0.00%) 1518566.3541 (  6.04%) 1475994.2194 (  3.07%)
Hmean    faults/sec-3 3943818.1437 (  0.00%) 4036918.0217 (  2.36%) 3973070.2159 (  0.74%)
Hmean    faults/sec-5 3877573.5867 (  0.00%) 3922745.9207 (  1.16%) 3891705.1749 (  0.36%)
Hmean    faults/sec-7 3991832.0418 (  0.00%) 3990670.8481 ( -0.03%) 3989110.4674 ( -0.07%)
Hmean    faults/sec-8 3987189.8167 (  0.00%) 3978842.8107 ( -0.21%) 3981011.2936 ( -0.15%)

Very minor boost. The same reordering looks like it would also suit
do_wp_page. I'll do that, retest, put some lipstick on the patches and
post them tomorrow the day after. The reordering one probably makes sense
anyway, the default disabling of memcg still has merit but maybe if that
charging of the root group can be eliminated then it'd be pointless.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
