Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E09BA8E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 02:57:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w15so4926915edl.21
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 23:57:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor5502697eda.20.2018.12.09.23.57.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 23:57:15 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
 <20181206121152.GH1286@dhcp22.suse.cz> <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz> <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz> <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz> <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz> <CAFgQCTvXDFL73YopcU6iwtQFvxxJno78n=dii9ESskV2PP8+fQ@mail.gmail.com>
In-Reply-To: <CAFgQCTvXDFL73YopcU6iwtQFvxxJno78n=dii9ESskV2PP8+fQ@mail.gmail.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 10 Dec 2018 15:57:02 +0800
Message-ID: <CAFgQCTu18oebiMWk2EtPdsxZ2db9iK=tZ4qM7zh38QdkpCnJsw@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Mon, Dec 10, 2018 at 12:00 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Fri, Dec 7, 2018 at 11:56 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 07-12-18 22:27:13, Pingfan Liu wrote:
> > [...]
> > > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > > index 1308f54..4dc497d 100644
> > > --- a/arch/x86/mm/numa.c
> > > +++ b/arch/x86/mm/numa.c
> > > @@ -754,18 +754,23 @@ void __init init_cpu_to_node(void)
> > >  {
> > >         int cpu;
> > >         u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);
> > > +       int node, nr;
> > >
> > >         BUG_ON(cpu_to_apicid == NULL);
> > > +       nr = cpumask_weight(cpu_possible_mask);
> > > +
> > > +       /* bring up all possible node, since dev->numa_node */
> > > +       //should check acpi works for node possible,
> > > +       for_each_node(node)
> > > +               if (!node_online(node))
> > > +                       init_memory_less_node(node);
> >
> > I suspect there is no change if you replace for_each_node by
> >         for_each_node_mask(nid, node_possible_map)
> >
> > here. If that is the case then we are probably calling
> > free_area_init_node too early. I do not see it yet though.
>
> Maybe I do not clearly get your meaning, just try to guess. But if you
> worry about node_possible_map, then it is dynamically set by
> alloc_node_data(). The map is changed after the first time to call

A mistake, it should be node_online_map. and in free_area_init_nodes()
for_each_online_node(nid) {
   free_area_init_node(nid, NULL,..

So at this time, we do not need to worry about the memory-less node.

> free_area_init_node() for the node with memory.  This logic is the
> same as the current x86 code.
>
> Thanks,
> Pingfan
