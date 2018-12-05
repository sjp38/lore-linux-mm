Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 258656B73A8
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:43:31 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id w6so9091186otb.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:43:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v63si8721710oig.121.2018.12.05.01.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 01:43:29 -0800 (PST)
Date: Wed, 5 Dec 2018 10:43:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181205094327.GD1286@dhcp22.suse.cz>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz>
 <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz>
 <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz>
 <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Wed 05-12-18 17:29:31, Pingfan Liu wrote:
> On Wed, Dec 5, 2018 at 5:21 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 05-12-18 13:38:17, Pingfan Liu wrote:
> > > On Tue, Dec 4, 2018 at 4:56 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Tue 04-12-18 16:20:32, Pingfan Liu wrote:
> > > > > On Tue, Dec 4, 2018 at 3:22 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Tue 04-12-18 11:05:57, Pingfan Liu wrote:
> > > > > > > During my test on some AMD machine, with kexec -l nr_cpus=x option, the
> > > > > > > kernel failed to bootup, because some node's data struct can not be allocated,
> > > > > > > e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
> > > > > > > device->numa_node info is used as preferred_nid param for
> > > > > > > __alloc_pages_nodemask(), which causes NULL reference
> > > > > > >   ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
> > > > > > > This patch tries to fix the issue by falling back to the first online node,
> > > > > > > when encountering such corner case.
> > > > > >
> > > > > > We have seen similar issues already and the bug was usually that the
> > > > > > zonelists were not initialized yet or the node is completely bogus.
> > > > > > Zonelists should be initialized by build_all_zonelists quite early so I
> > > > > > am wondering whether the later is the case. What is the actual node
> > > > > > number the device is associated with?
> > > > > >
> > > > > The device's node num is 2. And in my case, I used nr_cpus param. Due
> > > > > to init_cpu_to_node() initialize all the possible node.  It is hard
> > > > > for me to figure out without this param, how zonelists is accessed
> > > > > before page allocator works.
> > > >
> > > > I believe we should focus on this. Why does the node have no zonelist
> > > > even though all zonelists should be initialized already? Maybe this is
> > > > nr_cpus pecularity and we do not initialize all the existing numa nodes.
> > > > Or maybe the device is associated to a non-existing node with that
> > > > setup. A full dmesg might help us here.
> > > >
> > > Requiring the machine again, and I got the following without nr_cpus option
> > > [root@dell-per7425-03 ~]# cd /sys/devices/system/node/
> > > [root@dell-per7425-03 node]# ls
> > > has_cpu  has_memory  has_normal_memory  node0  node1  node2  node3
> > > node4  node5  node6  node7  online  possible  power  uevent
> > > [root@dell-per7425-03 node]# cat has_cpu
> > > 0-7
> > > [root@dell-per7425-03 node]# cat has_memory
> > > 1,5
> > > [root@dell-per7425-03 node]# cat online
> > > 0-7
> > > [root@dell-per7425-03 node]# cat possible
> > > 0-7
> > > And lscpu shows the following numa-cpu info:
> > > NUMA node0 CPU(s):     0,8,16,24
> > > NUMA node1 CPU(s):     2,10,18,26
> > > NUMA node2 CPU(s):     4,12,20,28
> > > NUMA node3 CPU(s):     6,14,22,30
> > > NUMA node4 CPU(s):     1,9,17,25
> > > NUMA node5 CPU(s):     3,11,19,27
> > > NUMA node6 CPU(s):     5,13,21,29
> > > NUMA node7 CPU(s):     7,15,23,31
> > >
> > > For the full panic message (I masked some hostname info with xx),
> > > please see the attachment.
> > > In a short word, it seems a problem with nr_cpus, if without this
> > > option, the kernel can bootup correctly.
> >
> > Yep.
> > [    0.007418] Early memory node ranges
> > [    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> > [    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> > [    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> > [    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> > [    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> > [    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> > [    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> >
> > There is clearly no node2. Where did the driver get the node2 from?
> Since using nr_cpus=4 , the node2 is not be instanced by x86 initalizing code.
> For the normal bootup, having the following:
> [    0.007704] Movable zone start for each node
> [    0.007707] Early memory node ranges
> [    0.007708]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> [    0.007709]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> [    0.007711]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> [    0.007712]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> [    0.007712]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> [    0.007713]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> [    0.007714]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> [    0.008434] Zeroed struct page in unavailable ranges: 46490 pages

Hmm, this is even more interesting. So even a normal boot doesn't have
node 2. So where exactly does the device get its affinity from?

I suspect we are looking at two issues here. The first one, and a more
important one is that there is a NUMA affinity configured for the device
to a non-existing node. The second one is that nr_cpus affects
initialization of possible nodes.
-- 
Michal Hocko
SUSE Labs
