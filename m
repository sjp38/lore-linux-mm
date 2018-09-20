Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E72A08E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:51:55 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id t79-v6so846133wmt.3
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:51:55 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f143-v6si754736wmf.153.2018.09.20.15.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 15:51:54 -0700 (PDT)
Date: Fri, 21 Sep 2018 00:51:52 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address
 (ptrval)/0xc00a0000
In-Reply-To: <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de> <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de> <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: linux-mm@kvack.org, x86@kernel.org

Paul,

On Thu, 20 Sep 2018, Paul Menzel wrote:

> As always, thank you for the quick response.

Thank you for providing the info!

> Am 19.09.2018 um 10:09 schrieb Thomas Gleixner:
> > On Wed, 19 Sep 2018, Paul Menzel wrote:
> > > 
> > > With Linux 4.19-rc4+ and `CONFIG_DEBUG_WX=y`, I see the message below on
> > > the ASRock E350M1.
> > > 
> > > > [    1.813378] Freeing unused kernel image memory: 1112K
> > > > [    1.818662] Write protecting the kernel text: 8708k
> > > > [    1.818987] Write protecting the kernel read-only data: 2864k
> > > > [    1.818989] NX-protecting the kernel data: 5628k
> > > > [    1.819265] ------------[ cut here ]------------
> > > > [    1.819272] x86/mm: Found insecure W+X mapping at address
> > > > (ptrval)/0xc00a0000
> > > 
> > > I do not notice any problems with the system, but maybe something can be
> > > done
> > > to get rid of these.
> > 
> > Can you please enable CONFIG_X86_PTDUMP and provide the output of the files
> > in /sys/kernel/debug/page_tables/ ?
> 
> By accident, I noticed that this issue does not happen with GRUB as coreboot
> payload, and only with SeaBIOS. (I only tested on the ASRock E350M1.) A
> coreboot developer said, that SeaBIOS does not do mapping though.

Interesting, but I can't spot what causes that. 

Can you please apply the patch below, and provide full dmesg of a seabios
and a grub boot along with the page table files for each?

Thanks,

	tglx

8<------------------
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index faca978ebf9d..2190d40d99a5 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -794,6 +794,7 @@ void free_kernel_image_pages(void *begin, void *end)
 	unsigned long len_pages = (end_ul - begin_ul) >> PAGE_SHIFT;
 
 
+	pr_info("Freeing init [mem %#010lx-%#010lx]\n", begin_ul, end_ul - 1);
 	free_init_pages("unused kernel image", begin_ul, end_ul);
 
 	/*
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 979e0a02cbe1..651447261798 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -915,6 +915,7 @@ static void mark_nxdata_nx(void)
 	 */
 	unsigned long size = (((unsigned long)__init_end + HPAGE_SIZE) & HPAGE_MASK) - start;
 
+	pr_info("NX data: 0x%08lx - 0x%08lx\n", start, start + size - 1);
 	if (__supported_pte_mask & _PAGE_NX)
 		printk(KERN_INFO "NX-protecting the kernel data: %luk\n", size >> 10);
 	set_pages_nx(virt_to_page(start), size >> PAGE_SHIFT);
@@ -925,6 +926,7 @@ void mark_rodata_ro(void)
 	unsigned long start = PFN_ALIGN(_text);
 	unsigned long size = PFN_ALIGN(_etext) - start;
 
+	pr_info("RO text: 0x%08lx - 0x%08lx\n", start, start + size - 1);
 	set_pages_ro(virt_to_page(start), size >> PAGE_SHIFT);
 	printk(KERN_INFO "Write protecting the kernel text: %luk\n",
 		size >> 10);
@@ -942,6 +944,7 @@ void mark_rodata_ro(void)
 
 	start += size;
 	size = (unsigned long)__end_rodata - start;
+	pr_info("RO data: 0x%08lx - 0x%08lx\n", start, start + size - 1);
 	set_pages_ro(virt_to_page(start), size >> PAGE_SHIFT);
 	printk(KERN_INFO "Write protecting the kernel read-only data: %luk\n",
 		size >> 10);
