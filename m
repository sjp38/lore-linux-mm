Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E454F8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:06:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so6667864eda.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:06:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26-v6sor3478822ejz.40.2018.12.11.00.06.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 00:06:11 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
 <20181206121152.GH1286@dhcp22.suse.cz> <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz> <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz> <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz> <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz> <20181210123738.GN1286@dhcp22.suse.cz>
In-Reply-To: <20181210123738.GN1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 11 Dec 2018 16:05:58 +0800
Message-ID: <CAFgQCTsb-G6=o=kyh845RHDTB2WYXywfLiYRddPmoiQVGpqzLA@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Mon, Dec 10, 2018 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 07-12-18 16:56:27, Michal Hocko wrote:
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
> >       for_each_node_mask(nid, node_possible_map)
> >
> > here. If that is the case then we are probably calling
> > free_area_init_node too early. I do not see it yet though.
>
> OK, so it is not about calling it late or soon. It is just that
> node_possible_map is a misnomer and it has a different semantic than
> I've expected. numa_nodemask_from_meminfo simply considers only nodes
> with some memory. So my patch didn't really make any difference and the
> node stayed uninialized.
>
> In other words. Does the following work? I am sorry to wildguess this
> way but I am not able to recreate your setups to play with this myself.
>
No problem. Yeah, in order to debug the patch, you need a numa machine
with a memory-less node. And unlucky, the patch can not work either by
grub bootup or kexec -l boot. There is nothing, just silent.  I will
dig into numa_register_memblks() to figure out the problem.

Thanks,
Pingfan
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 1308f5408bf7..d51643e10d00 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
>
>         node_data[nid] = nd;
>         memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
> -
> -       node_set_online(nid);
>  }
>
>  /**
> @@ -527,6 +525,19 @@ static void __init numa_clear_kernel_node_hotplug(void)
>         }
>  }
>
> +static void __init init_memory_less_node(int nid)
> +{
> +       unsigned long zones_size[MAX_NR_ZONES] = {0};
> +       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> +
> +       free_area_init_node(nid, zones_size, 0, zholes_size);
> +
> +       /*
> +        * All zonelists will be built later in start_kernel() after per cpu
> +        * areas are initialized.
> +        */
> +}
> +
>  static int __init numa_register_memblks(struct numa_meminfo *mi)
>  {
>         unsigned long uninitialized_var(pfn_align);
> @@ -570,7 +581,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                 return -EINVAL;
>
>         /* Finally register nodes. */
> -       for_each_node_mask(nid, node_possible_map) {
> +       for_each_node(nid) {
>                 u64 start = PFN_PHYS(max_pfn);
>                 u64 end = 0;
>
> @@ -592,6 +603,10 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                         continue;
>
>                 alloc_node_data(nid);
> +               if (!end)
> +                       init_memory_less_node(nid);
> +               else
> +                       node_set_online(nid);
>         }
>
>         /* Dump memblock with node info and return. */
> @@ -721,21 +736,6 @@ void __init x86_numa_init(void)
>         numa_init(dummy_numa_init);
>  }
>
> -static void __init init_memory_less_node(int nid)
> -{
> -       unsigned long zones_size[MAX_NR_ZONES] = {0};
> -       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> -
> -       /* Allocate and initialize node data. Memory-less node is now online.*/
> -       alloc_node_data(nid);
> -       free_area_init_node(nid, zones_size, 0, zholes_size);
> -
> -       /*
> -        * All zonelists will be built later in start_kernel() after per cpu
> -        * areas are initialized.
> -        */
> -}
> -
>  /*
>   * Setup early cpu_to_node.
>   *
> @@ -763,9 +763,6 @@ void __init init_cpu_to_node(void)
>                 if (node == NUMA_NO_NODE)
>                         continue;
>
> -               if (!node_online(node))
> -                       init_memory_less_node(node);
> -
>                 numa_set_node(cpu, node);
>         }
>  }
> --
> Michal Hocko
> SUSE Labs
