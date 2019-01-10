Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 475738E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:42:06 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so11682017qtr.7
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:42:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si11610485qtc.140.2019.01.10.09.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 09:42:05 -0800 (PST)
Date: Thu, 10 Jan 2019 12:42:00 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110174159.GD4394@redhat.com>
References: <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
 <20190102122110.00000206@huawei.com>
 <20190108145256.GX31793@dhcp22.suse.cz>
 <20190110155317.GB4394@redhat.com>
 <20190110164248.GO31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110164248.GO31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, kvm@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Yao Yuan <yuan.yao@intel.com>, Fan Du <fan.du@intel.com>, Dong Eddie <eddie.dong@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Peng Dong <dongx.peng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-accelerators@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

On Thu, Jan 10, 2019 at 05:42:48PM +0100, Michal Hocko wrote:
> On Thu 10-01-19 10:53:17, Jerome Glisse wrote:
> > On Tue, Jan 08, 2019 at 03:52:56PM +0100, Michal Hocko wrote:
> > > On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> > > [...]
> > > > So ideally I'd love this set to head in a direction that helps me tick off
> > > > at least some of the above usecases and hopefully have some visibility on
> > > > how to address the others moving forwards,
> > > 
> > > Is it sufficient to have such a memory marked as movable (aka only have
> > > ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> > > it fits the "balance by migration" concept.
> > 
> > This would not work for GPU, GPU driver really want to be in total
> > control of their memory yet sometimes they want to migrate some part
> > of the process to their memory.
> 
> But that also means that GPU doesn't really fit the model discussed
> here, right? I thought HMM is the way to manage such a memory.

HMM provides the plumbing and tools to manage but right now the patchset
for nouveau expose API through nouveau device file as nouveau ioctl. This
is not a good long term solution when you want to mix and match multiple
GPUs memory (possibly from different vendors). Then you get each device
driver implementing their own mem policy infrastructure and without any
coordination between devices/drivers. While it is _mostly_ ok for single
GPU case, it is seriously crippling for the multi-GPUs or multi-devices
cases (for instance when you chain network and GPU together or GPU and
storage).

People have been asking for a single common API to manage both regular
memory and device memory. As anyway the common case is you move things
around depending on which devices/CPUs is working on the dataset.

Cheers,
J�r�me
