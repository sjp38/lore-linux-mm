Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6C88E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 03:33:39 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so8299757edc.9
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 00:33:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24sor9862818edc.21.2018.12.12.00.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 00:33:38 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz> <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz> <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz> <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz> <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTsb-G6=o=kyh845RHDTB2WYXywfLiYRddPmoiQVGpqzLA@mail.gmail.com> <20181211094436.GC1286@dhcp22.suse.cz>
In-Reply-To: <20181211094436.GC1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 12 Dec 2018 16:33:25 +0800
Message-ID: <CAFgQCTsbuX8MROsFpQrjd0OAfp6oVRtq7VKYi2VGNyrQvxVF-w@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 11, 2018 at 5:44 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 11-12-18 16:05:58, Pingfan Liu wrote:
> > On Mon, Dec 10, 2018 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 07-12-18 16:56:27, Michal Hocko wrote:
> > > > On Fri 07-12-18 22:27:13, Pingfan Liu wrote:
> > > > [...]
> > > > > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > > > > index 1308f54..4dc497d 100644
> > > > > --- a/arch/x86/mm/numa.c
> > > > > +++ b/arch/x86/mm/numa.c
> > > > > @@ -754,18 +754,23 @@ void __init init_cpu_to_node(void)
> > > > >  {
> > > > >         int cpu;
> > > > >         u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);
> > > > > +       int node, nr;
> > > > >
> > > > >         BUG_ON(cpu_to_apicid == NULL);
> > > > > +       nr = cpumask_weight(cpu_possible_mask);
> > > > > +
> > > > > +       /* bring up all possible node, since dev->numa_node */
> > > > > +       //should check acpi works for node possible,
> > > > > +       for_each_node(node)
> > > > > +               if (!node_online(node))
> > > > > +                       init_memory_less_node(node);
> > > >
> > > > I suspect there is no change if you replace for_each_node by
> > > >       for_each_node_mask(nid, node_possible_map)
> > > >
> > > > here. If that is the case then we are probably calling
> > > > free_area_init_node too early. I do not see it yet though.
> > >
> > > OK, so it is not about calling it late or soon. It is just that
> > > node_possible_map is a misnomer and it has a different semantic than
> > > I've expected. numa_nodemask_from_meminfo simply considers only nodes
> > > with some memory. So my patch didn't really make any difference and the
> > > node stayed uninialized.
> > >
> > > In other words. Does the following work? I am sorry to wildguess this
> > > way but I am not able to recreate your setups to play with this myself.
> > >
> > No problem. Yeah, in order to debug the patch, you need a numa machine
> > with a memory-less node. And unlucky, the patch can not work either by
> > grub bootup or kexec -l boot. There is nothing, just silent.  I will
> > dig into numa_register_memblks() to figure out the problem.
>
> I do not have such a machine handy. Anyway, can you post the full serial
> console log. Maybe I can infer something. It is quite weird that this
> patch would make an existing situation any worse.

After passing extra param to earlyprintk, finally I got something. I
replied it in another mail, and some notes to your code.

Thanks,
Pingfan
