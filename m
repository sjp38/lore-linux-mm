Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC2CA8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:14:24 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id y86so548159ita.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 22:14:24 -0800 (PST)
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id l79si2385292jab.122.2019.01.10.22.14.22
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 22:14:23 -0800 (PST)
Date: Fri, 11 Jan 2019 14:12:21 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator
 enabled
Message-ID: <20190111061221.GB13263@localhost.localdomain>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 11, 2019 at 01:12:51PM +0800, Pingfan Liu wrote:
>This patch identifies the point where memblock alloc start. It has no
>functional.
[...]
>+#ifdef CONFIG_MEMORY_HOTPLUG
>+	/*
>+	 * Memory used by the kernel cannot be hot-removed because Linux
>+	 * cannot migrate the kernel pages. When memory hotplug is
>+	 * enabled, we should prevent memblock from allocating memory
>+	 * for the kernel.
>+	 *
>+	 * ACPI SRAT records all hotpluggable memory ranges. But before
>+	 * SRAT is parsed, we don't know about it.
>+	 *
>+	 * The kernel image is loaded into memory at very early time. We
>+	 * cannot prevent this anyway. So on NUMA system, we set any
>+	 * node the kernel resides in as un-hotpluggable.
>+	 *
>+	 * Since on modern servers, one node could have double-digit
>+	 * gigabytes memory, we can assume the memory around the kernel
>+	 * image is also un-hotpluggable. So before SRAT is parsed, just
>+	 * allocate memory near the kernel image to try the best to keep
>+	 * the kernel away from hotpluggable memory.
>+	 */
>+	if (movable_node_is_enabled())
>+		memblock_set_bottom_up(true);

Hi Pingfan,

In my understanding, 'movable_node' is based on the that memory near
kernel is considered as in the same node as kernel in high possibility.

If SRAT has been parsed early, do we still need the kernel parameter
'movable_node'? Since you have got the memory information about hot-remove,
so I wonder if it's OK to drop 'movable_node', and if memory-hotremove is
enabled, change memblock allocation according to SRAT.

If there is something wrong in my understanding, please let me know.

Thanks,
Chao Fan

>+#endif
> 	init_mem_mapping();
>+	memblock_set_current_limit(get_max_mapped());
> 
> 	idt_setup_early_pf();
> 
>@@ -1145,8 +1145,6 @@ void __init setup_arch(char **cmdline_p)
> 	 */
> 	mmu_cr4_features = __read_cr4() & ~X86_CR4_PCIDE;
> 
>-	memblock_set_current_limit(get_max_mapped());
>-
> 	/*
> 	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
> 	 */
>-- 
>2.7.4
>
>
>
