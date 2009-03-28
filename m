Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5CD706B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 23:55:24 -0400 (EDT)
Message-ID: <49CD9E25.2090407@redhat.com>
Date: Sat, 28 Mar 2009 06:48:53 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86/mm: maintain a percpu "in get_user_pages_fast"
 flag
References: <49CD37B8.4070109@goop.org>
In-Reply-To: <49CD37B8.4070109@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> get_user_pages_fast() relies on cross-cpu tlb flushes being a barrier
> between clearing and setting a pte, and before freeing a pagetable page.
> It usually does this by disabling interrupts to hold off IPIs, but
> some tlb flush implementations don't use IPIs for tlb flushes, and
> must use another mechanism.
>
> In this change, add in_gup_cpumask, which is a cpumask of cpus currently
> performing a get_user_pages_fast traversal of a pagetable.  A cross-cpu
> tlb flush function can use this to determine whether it should hold-off
> on the flush until the gup_fast has finished.
>
> @@ -255,6 +260,10 @@ int get_user_pages_fast(unsigned long start, int 
> nr_pages, int write,
>      * address down to the the page and take a ref on it.
>      */
>     local_irq_disable();
> +
> +    cpu = smp_processor_id();
> +    cpumask_set_cpu(cpu, in_gup_cpumask);
> +

This will bounce a cacheline, every time.  Please wrap in CONFIG_XEN and 
skip at runtime if Xen is not enabled.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
