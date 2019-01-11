Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88FF48E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:07:07 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i12so994018ita.3
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:07:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m22sor28684487ioj.130.2019.01.11.02.07.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 02:07:06 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com> <20190111061221.GB13263@localhost.localdomain>
In-Reply-To: <20190111061221.GB13263@localhost.localdomain>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 18:06:55 +0800
Message-ID: <CAFgQCTvhcNK_-b-eVFZY8Ua2C+GbOVM+h4kB1us2vNvvyNPCYg@mail.gmail.com>
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator enabled
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 11, 2019 at 2:13 PM Chao Fan <fanc.fnst@cn.fujitsu.com> wrote:
>
> On Fri, Jan 11, 2019 at 01:12:51PM +0800, Pingfan Liu wrote:
> >This patch identifies the point where memblock alloc start. It has no
> >functional.
> [...]
> >+#ifdef CONFIG_MEMORY_HOTPLUG
> >+      /*
> >+       * Memory used by the kernel cannot be hot-removed because Linux
> >+       * cannot migrate the kernel pages. When memory hotplug is
> >+       * enabled, we should prevent memblock from allocating memory
> >+       * for the kernel.
> >+       *
> >+       * ACPI SRAT records all hotpluggable memory ranges. But before
> >+       * SRAT is parsed, we don't know about it.
> >+       *
> >+       * The kernel image is loaded into memory at very early time. We
> >+       * cannot prevent this anyway. So on NUMA system, we set any
> >+       * node the kernel resides in as un-hotpluggable.
> >+       *
> >+       * Since on modern servers, one node could have double-digit
> >+       * gigabytes memory, we can assume the memory around the kernel
> >+       * image is also un-hotpluggable. So before SRAT is parsed, just
> >+       * allocate memory near the kernel image to try the best to keep
> >+       * the kernel away from hotpluggable memory.
> >+       */
> >+      if (movable_node_is_enabled())
> >+              memblock_set_bottom_up(true);
>
> Hi Pingfan,
>
> In my understanding, 'movable_node' is based on the that memory near
> kernel is considered as in the same node as kernel in high possibility.
>
> If SRAT has been parsed early, do we still need the kernel parameter
> 'movable_node'? Since you have got the memory information about hot-remove,
> so I wonder if it's OK to drop 'movable_node', and if memory-hotremove is
> enabled, change memblock allocation according to SRAT.
>
x86_32 still need this logic. Maybe it can be doable later.

Thanks,
Pingfan
> If there is something wrong in my understanding, please let me know.
>
> Thanks,
> Chao Fan
>
> >+#endif
> >       init_mem_mapping();
> >+      memblock_set_current_limit(get_max_mapped());
> >
> >       idt_setup_early_pf();
> >
> >@@ -1145,8 +1145,6 @@ void __init setup_arch(char **cmdline_p)
> >        */
> >       mmu_cr4_features = __read_cr4() & ~X86_CR4_PCIDE;
> >
> >-      memblock_set_current_limit(get_max_mapped());
> >-
> >       /*
> >        * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
> >        */
> >--
> >2.7.4
> >
> >
> >
>
>
