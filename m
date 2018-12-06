Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C32BB6B795C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:04:07 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so140624edi.0
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:04:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k22-v6sor90163ejv.9.2018.12.06.02.04.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 02:04:06 -0800 (PST)
MIME-Version: 1.0
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz> <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz> <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz> <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz> <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
 <20181206082806.GB1286@dhcp22.suse.cz>
In-Reply-To: <20181206082806.GB1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 6 Dec 2018 18:03:53 +0800
Message-ID: <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

[...]
> THanks for pointing this out. It made my life easier. So It think the
> bug is that we call init_memory_less_node from this path. I suspect
> numa_register_memblks is the right place to do this. So I admit I
> am not 100% sure but could you give this a try please?
>
Sure.

> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 1308f5408bf7..4575ae4d5449 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -527,6 +527,19 @@ static void __init numa_clear_kernel_node_hotplug(void)
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
> @@ -592,6 +605,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>                         continue;
>
>                 alloc_node_data(nid);
> +               if (!end)
> +                       init_memory_less_node(nid);
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
Which commit is this patch applied on? I can not apply it on latest linux tree.

Thanks,
Pingfan
