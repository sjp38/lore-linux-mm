Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C80D6B6DD9
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:56:43 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so7895416edd.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:56:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor8504482edq.29.2018.12.04.00.56.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 00:56:41 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz> <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204084052.gpwwlnp6n2zehjy5@master>
In-Reply-To: <20181204084052.gpwwlnp6n2zehjy5@master>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Dec 2018 16:56:29 +0800
Message-ID: <CAFgQCTuS_u5=EamGFcQtD-AqVtdVLytAJAjk6jCAXanU=oKV8g@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard.weiyang@gmail.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 4, 2018 at 4:40 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>
> On Tue, Dec 04, 2018 at 04:20:32PM +0800, Pingfan Liu wrote:
> >On Tue, Dec 4, 2018 at 3:22 PM Michal Hocko <mhocko@kernel.org> wrote:
> >>
> >> On Tue 04-12-18 11:05:57, Pingfan Liu wrote:
> >> > During my test on some AMD machine, with kexec -l nr_cpus=x option, the
> >> > kernel failed to bootup, because some node's data struct can not be allocated,
> >> > e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
> >> > device->numa_node info is used as preferred_nid param for
> >> > __alloc_pages_nodemask(), which causes NULL reference
> >> >   ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
> >> > This patch tries to fix the issue by falling back to the first online node,
> >> > when encountering such corner case.
> >>
> >> We have seen similar issues already and the bug was usually that the
> >> zonelists were not initialized yet or the node is completely bogus.
> >> Zonelists should be initialized by build_all_zonelists quite early so I
> >> am wondering whether the later is the case. What is the actual node
> >> number the device is associated with?
> >>
> >The device's node num is 2. And in my case, I used nr_cpus param. Due
> >to init_cpu_to_node() initialize all the possible node.  It is hard
> >for me to figure out without this param, how zonelists is accessed
> >before page allocator works.
>
> If my understanding is correct, we can't do page alloc before zonelist
> is initialized.
>
> I guess Michal's point is to figure out this reason.
>
Yeah, I know. I just want to emphasize that I hit this bug using
nr_cpus, which may be rarely used by people. Hence it may be a
different bug as Michal had seen. Sorry for bad English if it cause
confusion.

Thanks

[...]
