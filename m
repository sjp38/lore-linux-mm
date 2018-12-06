Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC4C96B78FC
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:28:11 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id u20so19071453pfa.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:28:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si20372650pgk.127.2018.12.06.00.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:28:10 -0800 (PST)
Date: Thu, 6 Dec 2018 09:28:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181206082806.GB1286@dhcp22.suse.cz>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz>
 <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz>
 <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz>
 <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz>
 <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu 06-12-18 11:07:33, Pingfan Liu wrote:
> On Wed, Dec 5, 2018 at 5:40 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > On 12/5/18 10:29 AM, Pingfan Liu wrote:
> > >> [    0.007418] Early memory node ranges
> > >> [    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> > >> [    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> > >> [    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> > >> [    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> > >> [    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> > >> [    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> > >> [    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> > >>
> > >> There is clearly no node2. Where did the driver get the node2 from?
> >
> > I don't understand these tables too much, but it seems the other nodes
> > exist without them:
> >
> > [    0.007393] SRAT: PXM 2 -> APIC 0x20 -> Node 2
> >
> > Maybe the nodes are hotplugable or something?
> >
> I also not sure about it, and just have a hurry look at acpi spec. I
> will reply it on another email, and Cced some acpi guys about it
> 
> > > Since using nr_cpus=4 , the node2 is not be instanced by x86 initalizing code.
> >
> > Indeed, nr_cpus seems to restrict what nodes we allocate and populate
> > zonelists for.
> 
> Yes, in init_cpu_to_node(),  since nr_cpus limits the possible cpu,
> which affects the loop for_each_possible_cpu(cpu) and skip the node2
> in this case.

THanks for pointing this out. It made my life easier. So It think the
bug is that we call init_memory_less_node from this path. I suspect
numa_register_memblks is the right place to do this. So I admit I
am not 100% sure but could you give this a try please?

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f5408bf7..4575ae4d5449 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -527,6 +527,19 @@ static void __init numa_clear_kernel_node_hotplug(void)
 	}
 }
 
+static void __init init_memory_less_node(int nid)
+{
+	unsigned long zones_size[MAX_NR_ZONES] = {0};
+	unsigned long zholes_size[MAX_NR_ZONES] = {0};
+
+	free_area_init_node(nid, zones_size, 0, zholes_size);
+
+	/*
+	 * All zonelists will be built later in start_kernel() after per cpu
+	 * areas are initialized.
+	 */
+}
+
 static int __init numa_register_memblks(struct numa_meminfo *mi)
 {
 	unsigned long uninitialized_var(pfn_align);
@@ -592,6 +605,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			continue;
 
 		alloc_node_data(nid);
+		if (!end)
+			init_memory_less_node(nid);
 	}
 
 	/* Dump memblock with node info and return. */
@@ -721,21 +736,6 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static void __init init_memory_less_node(int nid)
-{
-	unsigned long zones_size[MAX_NR_ZONES] = {0};
-	unsigned long zholes_size[MAX_NR_ZONES] = {0};
-
-	/* Allocate and initialize node data. Memory-less node is now online.*/
-	alloc_node_data(nid);
-	free_area_init_node(nid, zones_size, 0, zholes_size);
-
-	/*
-	 * All zonelists will be built later in start_kernel() after per cpu
-	 * areas are initialized.
-	 */
-}
-
 /*
  * Setup early cpu_to_node.
  *
@@ -763,9 +763,6 @@ void __init init_cpu_to_node(void)
 		if (node == NUMA_NO_NODE)
 			continue;
 
-		if (!node_online(node))
-			init_memory_less_node(node);
-
 		numa_set_node(cpu, node);
 	}
 }
-- 
Michal Hocko
SUSE Labs
