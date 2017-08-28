Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2606B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 09:13:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v4so656293wrc.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 06:13:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si296929wre.193.2017.08.28.06.13.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 06:13:30 -0700 (PDT)
Date: Mon, 28 Aug 2017 15:13:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: only dispaly online cpus of the numa node
Message-ID: <20170828131328.GM17097@dhcp22.suse.cz>
References: <1497962608-12756-1-git-send-email-thunder.leizhen@huawei.com>
 <20170824083225.GA5943@dhcp22.suse.cz>
 <20170825173433.GB26878@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825173433.GB26878@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>

On Fri 25-08-17 18:34:33, Will Deacon wrote:
> On Thu, Aug 24, 2017 at 10:32:26AM +0200, Michal Hocko wrote:
> > It seems this has slipped through cracks. Let's CC arm64 guys
> > 
> > On Tue 20-06-17 20:43:28, Zhen Lei wrote:
> > > When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
> > > and display cpumask_of_node for each node), but I got different result on
> > > X86 and arm64. For each numa node, the former only displayed online CPUs,
> > > and the latter displayed all possible CPUs. Unfortunately, both Linux
> > > documentation and numactl manual have not described it clear.
> > > 
> > > I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
> > > that he preferred to print online cpus because it doesn't really make much
> > > sense to bind anything on offline nodes.
> > 
> > Yes printing offline CPUs is just confusing and more so when the
> > behavior is not consistent over architectures. I believe that x86
> > behavior is the more appropriate one because it is more logical to dump
> > the NUMA topology and use it for affinity setting than adding one
> > additional step to check the cpu state to achieve the same.
> > 
> > It is true that the online/offline state might change at any time so the
> > above might be tricky on its own but if we should at least make the
> > behavior consistent.
> > 
> > > Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> The concept looks find to me, but shouldn't we use cpumask_var_t and
> alloc/free_cpumask_var?

This will be safer but both callers of node_read_cpumap are shallow
stack so I am not sure a stack is a limiting factor here.

Zhen Lei, would you care to update that part please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
