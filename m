Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 937638E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 04:04:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so845501edi.0
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 01:04:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y13-v6sor451079ejb.25.2018.12.13.01.04.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 01:04:15 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz> <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz> <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz> <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz> <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz> <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
In-Reply-To: <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 13 Dec 2018 17:04:01 +0800
Message-ID: <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu, Dec 13, 2018 at 4:37 PM Pingfan Liu <kernelfans@gmail.com> wrote:
>
> On Wed, Dec 12, 2018 at 7:53 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 12-12-18 16:31:35, Pingfan Liu wrote:
> > > On Mon, Dec 10, 2018 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > [...]
> > > >
> > > > In other words. Does the following work? I am sorry to wildguess this
> > > > way but I am not able to recreate your setups to play with this myself.
> > > >
> > > > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > > > index 1308f5408bf7..d51643e10d00 100644
> > > > --- a/arch/x86/mm/numa.c
> > > > +++ b/arch/x86/mm/numa.c
> > > > @@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
> > > >
> > > >         node_data[nid] = nd;
> > > >         memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
> > > > -
> > > > -       node_set_online(nid);
> > > >  }
> > > >
> > > >  /**
> > > > @@ -527,6 +525,19 @@ static void __init numa_clear_kernel_node_hotplug(void)
> > > >         }
> > > >  }
> > > >
> > > > +static void __init init_memory_less_node(int nid)
> > > > +{
> > > > +       unsigned long zones_size[MAX_NR_ZONES] = {0};
> > > > +       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> > > > +
> > > > +       free_area_init_node(nid, zones_size, 0, zholes_size);
> > > > +
> > > > +       /*
> > > > +        * All zonelists will be built later in start_kernel() after per cpu
> > > > +        * areas are initialized.
> > > > +        */
> > > > +}
> > > > +
> > > >  static int __init numa_register_memblks(struct numa_meminfo *mi)
> > > >  {
> > > >         unsigned long uninitialized_var(pfn_align);
> > > > @@ -570,7 +581,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> > > >                 return -EINVAL;
> > > >
> > > >         /* Finally register nodes. */
> > > > -       for_each_node_mask(nid, node_possible_map) {
> > > > +       for_each_node(nid) {
> > > >                 u64 start = PFN_PHYS(max_pfn);
> > > >                 u64 end = 0;
> > > >
> > > > @@ -592,6 +603,10 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> > > >                         continue;
> > > >
> > > >                 alloc_node_data(nid);
> > > > +               if (!end)
> > >
> > > Here comes the bug, since !end can not reach here.
> >
> > You are right. I am dumb. I've just completely missed that. Sigh.
> > Anyway, I think the code is more complicated than necessary and we can
> > simply drop the check. I do not think we really have to worry about
> > the start overflowing end. So the end patch should look as follows.
> > Btw. I believe it is better to pull alloc_node_data out of init_memory_less_node
> > because a) there is no need to duplicate the call and moreover we want
> > to pull node_set_online as well. The code also seems cleaner this way.
> >
> I have no strong opinion here.
> > Thanks for your testing and your patience with me here.
> Np.
> >
> > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > index 1308f5408bf7..a5548fe668fb 100644
> > --- a/arch/x86/mm/numa.c
> > +++ b/arch/x86/mm/numa.c
> > @@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
> >
> >         node_data[nid] = nd;
> >         memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
> > -
> > -       node_set_online(nid);
> >  }
> >
> >  /**
> > @@ -527,6 +525,19 @@ static void __init numa_clear_kernel_node_hotplug(void)
> >         }
> >  }
> >
> > +static void __init init_memory_less_node(int nid)
> > +{
> > +       unsigned long zones_size[MAX_NR_ZONES] = {0};
> > +       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> > +
> > +       free_area_init_node(nid, zones_size, 0, zholes_size);
> > +
> > +       /*
> > +        * All zonelists will be built later in start_kernel() after per cpu
> > +        * areas are initialized.
> > +        */
> > +}
> > +
> >  static int __init numa_register_memblks(struct numa_meminfo *mi)
> >  {
> >         unsigned long uninitialized_var(pfn_align);
> > @@ -570,7 +581,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> >                 return -EINVAL;
> >
> >         /* Finally register nodes. */
> > -       for_each_node_mask(nid, node_possible_map) {
> > +       for_each_node(nid) {
> >                 u64 start = PFN_PHYS(max_pfn);
> >                 u64 end = 0;
> >
> > @@ -581,9 +592,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> >                         end = max(mi->blk[i].end, end);
> >                 }
> >
> > -               if (start >= end)
> > -                       continue;
> > -
> >                 /*
> >                  * Don't confuse VM with a node that doesn't have the
> >                  * minimum amount of memory:
> > @@ -592,6 +600,10 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
> >                         continue;
> >
> >                 alloc_node_data(nid);
> > +               if (!end)
> > +                       init_memory_less_node(nid);

Just have some opinion on this. Here is two issue. First, is this node
online? I do not see node_set_online() is called in this patch.
Second, if node is online here, then  init_memory_less_node->
free_area_init_node is called duplicated when free_area_init_nodes().
This should be a critical design issue.

Thanks,
Pingfan
> > +               else
> > +                       node_set_online(nid);
> >         }
> >
> >         /* Dump memblock with node info and return. */
> > @@ -721,21 +733,6 @@ void __init x86_numa_init(void)
> >         numa_init(dummy_numa_init);
> >  }
> >
> > -static void __init init_memory_less_node(int nid)
> > -{
> > -       unsigned long zones_size[MAX_NR_ZONES] = {0};
> > -       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> > -
> > -       /* Allocate and initialize node data. Memory-less node is now online.*/
> > -       alloc_node_data(nid);
> > -       free_area_init_node(nid, zones_size, 0, zholes_size);
> > -
> > -       /*
> > -        * All zonelists will be built later in start_kernel() after per cpu
> > -        * areas are initialized.
> > -        */
> > -}
> > -
> >  /*
> >   * Setup early cpu_to_node.
> >   *
> > @@ -763,9 +760,6 @@ void __init init_cpu_to_node(void)
> >                 if (node == NUMA_NO_NODE)
> >                         continue;
> >
> > -               if (!node_online(node))
> > -                       init_memory_less_node(node);
> > -
> >                 numa_set_node(cpu, node);
> >         }
> >  }
> > --
> Regret, it still has bug, and I got panic. Attached log.
>
> Thanks,
> Pingfan
