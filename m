Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 412016B7C17
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 21:57:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i14so1279490edf.17
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 18:57:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor1515146edd.23.2018.12.06.18.57.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 18:57:03 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz> <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz> <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz> <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
 <20181206082806.GB1286@dhcp22.suse.cz> <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com> <20181206121152.GH1286@dhcp22.suse.cz>
In-Reply-To: <20181206121152.GH1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 7 Dec 2018 10:56:51 +0800
Message-ID: <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu, Dec 6, 2018 at 8:11 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 06-12-18 18:44:03, Pingfan Liu wrote:
> > On Thu, Dec 6, 2018 at 6:03 PM Pingfan Liu <kernelfans@gmail.com> wrote:
> [...]
> > > Which commit is this patch applied on? I can not apply it on latest linux tree.
> > >
> > I applied it by manual, will see the test result. I think it should
> > work since you instance all the node.
> > But there are two things worth to consider:
> > -1st. why x86 do not bring up all nodes by default, apparently it will
> > be more simple by that way
>
> What do you mean? Why it didn't bring up before? Or do you see some

Yes, this is what I mean. But maybe the author does not consider about
the nr_cpus, otherwise, using:
+       for_each_node(node)
+               if (!node_online(node))
+                       init_memory_less_node(node);
in init_cpu_to_node() is more simple.

> nodes not being brought up after this patch?
>
> > -2nd. there are other archs, do they obey the rules?
>
> I am afraid that each arch does its own initialization.

Then it is arguable whether to fix this issue in memory core or let
each archs to fix this issue. I check the powerpc code, it should also
need a fix, it maybe the same in arm and mips ..
 BTW, your patch can not work for normal bootup, and the kernel hang
without any kernel message.
I think it is due to the bug in the patch:
                alloc_node_data(nid);
+               if (!end)
+                       init_memory_less_node(nid); //which calls
alloc_node_data(nid) also.
How about the following:
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f54..4dc497d 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -754,18 +754,23 @@ void __init init_cpu_to_node(void)
 {
        int cpu;
        u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);
+       int node, nr;

        BUG_ON(cpu_to_apicid == NULL);
+       nr = cpumask_weight(cpu_possible_mask);
+
+       /* bring up all possible node, since dev->numa_node */
+       //should check acpi works for node possible,
+       for_each_node(node)
+               if (!node_online(node))
+                       init_memory_less_node(node);

        for_each_possible_cpu(cpu) {
-               int node = numa_cpu_node(cpu);
+               node = numa_cpu_node(cpu);

                if (node == NUMA_NO_NODE)
                        continue;

-               if (!node_online(node))
-                       init_memory_less_node(node);
-
                numa_set_node(cpu, node);
        }
 }

Although it works, I hesitate about the idea, due to the semantic of
online-node, does the online-node require either cpu or memory inside
the node to be online?
In a short word, the fix method should consider about the two factors:
semantic of online-node and the effect on all archs

Thanks,
Pingfan

> --
> Michal Hocko
> SUSE Labs
