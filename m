Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFA538E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 13:28:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y83so27248070qka.7
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 10:28:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor30221909qvh.26.2018.12.28.10.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 10:28:42 -0800 (PST)
MIME-Version: 1.0
References: <20181226131446.330864849@intel.com> <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com> <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com> <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
In-Reply-To: <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 28 Dec 2018 10:28:31 -0800
Message-ID: <CAHbLzkq91SY2s-N8sKReaQeC4z16DHsygFad4sqSzuXsZFzwQg@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness accounting/migration
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, KVM list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Dec 28, 2018 at 5:31 AM Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> >> > I haven't looked at the implementation yet but if you are proposing a
> >> > special cased zone lists then this is something CDM (Coherent Device
> >> > Memory) was trying to do two years ago and there was quite some
> >> > skepticism in the approach.
> >>
> >> It looks we are pretty different than CDM. :)
> >> We creating new NUMA nodes rather than CDM's new ZONE.
> >> The zonelists modification is just to make PMEM nodes more separated.
> >
> >Yes, this is exactly what CDM was after. Have a zone which is not
> >reachable without explicit request AFAIR. So no, I do not think you are
> >too different, you just use a different terminology ;)
>
> Got it. OK.. The fall back zonelists patch does need more thoughts.
>
> In long term POV, Linux should be prepared for multi-level memory.
> Then there will arise the need to "allocate from this level memory".
> So it looks good to have separated zonelists for each level of memory.

I tend to agree with Fengguang. We do have needs for finer grained
control to the usage of DRAM and PMEM, for example, controlling the
percentage of DRAM and PMEM for a specific VMA.

NUMA policy sounds not good enough for some usecases since it just can
control what mempolicy is used by what memory range. Our usecase's
memory access pattern is random in a VMA. So, we can't control the
percentage by mempolicy. We have to put PMEM into a separate zonelist
to make sure memory allocation happens on PMEM when certain criteria
is met as what Fengguang does in this patch series.

Thanks,
Yang

>
> On the other hand, there will also be page allocations that don't care
> about the exact memory level. So it looks reasonable to expect
> different kind of fallback zonelists that can be selected by NUMA policy.
>
> Thanks,
> Fengguang
>
