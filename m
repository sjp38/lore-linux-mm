Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F57A8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 09:27:28 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so2059188edb.5
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 06:27:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26-v6sor1142145ejz.40.2018.12.07.06.27.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 06:27:26 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
 <20181206082806.GB1286@dhcp22.suse.cz> <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
 <20181206121152.GH1286@dhcp22.suse.cz> <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz> <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz> <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz>
In-Reply-To: <20181207142240.GC1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 7 Dec 2018 22:27:13 +0800
Message-ID: <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Fri, Dec 7, 2018 at 10:22 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 07-12-18 21:20:17, Pingfan Liu wrote:
> [...]
> > Hi Michal,
> >
> > As I mentioned in my previous email, I have manually apply the patch,
> > and the patch can not work for normal bootup.
>
> I am sorry, I have misread your previous response. Is there anything
> interesting on the serial console by any chance?

Nothing. It need more effort to debug. But as I mentioned, enable all
of the rest possible node, then it works. Maybe it can give some help
for you.
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

Thanks,
Pingfan
