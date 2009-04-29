Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AF43A6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 22:38:56 -0400 (EDT)
Date: Wed, 29 Apr 2009 10:38:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090429023842.GA10266@localhost>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428143244.4e424d36.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428143244.4e424d36.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "mpm@selenic.com" <mpm@selenic.com>, "adobriyan@gmail.com" <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Chandra Seetharaman <sekharan@us.ibm.com>, Nathan Lynch <ntl@pobox.com>, Olof Johansson <olof@lixom.net>, Helge Deller <deller@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 05:32:44AM +0800, Andrew Morton wrote:
> On Tue, 28 Apr 2009 09:09:12 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > +/*
> > + * Kernel flags are exported faithfully to Linus and his fellow hackers.
> > + * Otherwise some details are masked to avoid confusing the end user:
> > + * - some kernel flags are completely invisible
> > + * - some kernel flags are conditionally invisible on their odd usages
> > + */
> > +#ifdef CONFIG_DEBUG_KERNEL
> > +static inline int genuine_linus(void) { return 1; }
> 
> Although he's a fine chap, the use of the "_linus" tag isn't terribly
> clear (to me).  I think what you're saying here is that this enables
> kernel-developer-only features, yes?

Yes.

> If so, perhaps we could come up with an identifier which expresses that
> more clearly.
> 
> But I'd expect that everyone and all distros enable CONFIG_DEBUG_KERNEL
> for _some_ reason, so what's the point?

Good point! I can confirm my debian has CONFIG_DEBUG_KERNEL=Y!

> It is preferable that we always implement the same interface for all
> Kconfig settings.  If this exposes information which is confusing or
> not useful to end-users then so be it - we should be able to cover that
> in supporting documentation.

My original patch takes that straightforward manner - and I still like it.
I would be very glad to move the filtering code from kernel to user space.

The use of more obscure flags could be discouraged by _not_ documenting
them. A really curious user is encouraged to refer to the code for the
exact meaning (and perhaps become a kernel developer ;-)

> Also, as mentioned in the other email, it would be good if we were to
> publish a little userspace app which people can use to access this raw
> data.  We could give that application an `--i-am-a-kernel-developer'
> option!

OK. I'll include page-types.c in the next take.

> > +#else
> > +static inline int genuine_linus(void) { return 0; }
> > +#endif
> 
> This isn't an appropriate use of CONFIG_DEBUG_KERNEL.
> 
> DEBUG_KERNEL is a Kconfig-only construct which is use to enable _other_
> debugging features.  The way you've used it here, if the person who is
> configuring the kernel wants to enable any other completely-unrelated
> debug feature, they have to enable DEBUG_KERNEL first.  But when they
> do that, they unexpectedly alter the behaviour of pagemap!
> 
> There are two other places where CONFIG_DEBUG_KERNEL affects code
> generation in .c files: arch/parisc/mm/init.c and
> arch/powerpc/kernel/sysfs.c.  These are both wrong, and need slapping ;)

(add cc to related maintainers)

CONFIG_DEBUG_KERNEL being enabled in distro kernels effectively means 

        #ifdef CONFIG_DEBUG_KERNEL == #if 1

as the following patch demos. Now it becomes obviously silly.

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 4356ceb..59fb910 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -368,19 +368,19 @@ static void __init setup_bootmem(void)
 	request_resource(&sysram_resources[0], &pdcdata_resource);
 }
 
 void free_initmem(void)
 {
 	unsigned long addr, init_begin, init_end;
 
 	printk(KERN_INFO "Freeing unused kernel memory: ");
 
-#ifdef CONFIG_DEBUG_KERNEL
+#if 1
 	/* Attempt to catch anyone trying to execute code here
 	 * by filling the page with BRK insns.
 	 * 
 	 * If we disable interrupts for all CPUs, then IPI stops working.
 	 * Kinda breaks the global cache flushing.
 	 */
 	local_irq_disable();
 
 	memset(__init_begin, 0x00,
@@ -519,19 +519,19 @@ void __init mem_init(void)
 	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, %dk init)\n",
 		(unsigned long)nr_free_pages() << (PAGE_SHIFT-10),
 		num_physpages << (PAGE_SHIFT-10),
 		codesize >> 10,
 		reservedpages << (PAGE_SHIFT-10),
 		datasize >> 10,
 		initsize >> 10
 	);
 
-#ifdef CONFIG_DEBUG_KERNEL /* double-sanity-check paranoia */
+#if 1 /* double-sanity-check paranoia */
 	printk("virtual kernel memory layout:\n"
 	       "    vmalloc : 0x%p - 0x%p   (%4ld MB)\n"
 	       "    memory  : 0x%p - 0x%p   (%4ld MB)\n"
 	       "      .init : 0x%p - 0x%p   (%4ld kB)\n"
 	       "      .data : 0x%p - 0x%p   (%4ld kB)\n"
 	       "      .text : 0x%p - 0x%p   (%4ld kB)\n",
 
 	       (void*)VMALLOC_START, (void*)VMALLOC_END,
 	       (VMALLOC_END - VMALLOC_START) >> 20,
diff --git a/arch/powerpc/kernel/sysfs.c b/arch/powerpc/kernel/sysfs.c
index f41aec8..0d54c6b 100644
--- a/arch/powerpc/kernel/sysfs.c
+++ b/arch/powerpc/kernel/sysfs.c
@@ -212,19 +212,19 @@ static SYSDEV_ATTR(purr, 0600, show_purr, store_purr);
 #endif /* CONFIG_PPC64 */
 
 #ifdef HAS_PPC_PMC_PA6T
 SYSFS_PMCSETUP(pa6t_pmc0, SPRN_PA6T_PMC0);
 SYSFS_PMCSETUP(pa6t_pmc1, SPRN_PA6T_PMC1);
 SYSFS_PMCSETUP(pa6t_pmc2, SPRN_PA6T_PMC2);
 SYSFS_PMCSETUP(pa6t_pmc3, SPRN_PA6T_PMC3);
 SYSFS_PMCSETUP(pa6t_pmc4, SPRN_PA6T_PMC4);
 SYSFS_PMCSETUP(pa6t_pmc5, SPRN_PA6T_PMC5);
-#ifdef CONFIG_DEBUG_KERNEL
+#if 1
 SYSFS_PMCSETUP(hid0, SPRN_HID0);
 SYSFS_PMCSETUP(hid1, SPRN_HID1);
 SYSFS_PMCSETUP(hid4, SPRN_HID4);
 SYSFS_PMCSETUP(hid5, SPRN_HID5);
 SYSFS_PMCSETUP(ima0, SPRN_PA6T_IMA0);
 SYSFS_PMCSETUP(ima1, SPRN_PA6T_IMA1);
 SYSFS_PMCSETUP(ima2, SPRN_PA6T_IMA2);
 SYSFS_PMCSETUP(ima3, SPRN_PA6T_IMA3);
 SYSFS_PMCSETUP(ima4, SPRN_PA6T_IMA4);
@@ -282,19 +282,19 @@ static struct sysdev_attribute classic_pmc_attrs[] = {
 static struct sysdev_attribute pa6t_attrs[] = {
 	_SYSDEV_ATTR(mmcr0, 0600, show_mmcr0, store_mmcr0),
 	_SYSDEV_ATTR(mmcr1, 0600, show_mmcr1, store_mmcr1),
 	_SYSDEV_ATTR(pmc0, 0600, show_pa6t_pmc0, store_pa6t_pmc0),
 	_SYSDEV_ATTR(pmc1, 0600, show_pa6t_pmc1, store_pa6t_pmc1),
 	_SYSDEV_ATTR(pmc2, 0600, show_pa6t_pmc2, store_pa6t_pmc2),
 	_SYSDEV_ATTR(pmc3, 0600, show_pa6t_pmc3, store_pa6t_pmc3),
 	_SYSDEV_ATTR(pmc4, 0600, show_pa6t_pmc4, store_pa6t_pmc4),
 	_SYSDEV_ATTR(pmc5, 0600, show_pa6t_pmc5, store_pa6t_pmc5),
-#ifdef CONFIG_DEBUG_KERNEL
+#if 1
 	_SYSDEV_ATTR(hid0, 0600, show_hid0, store_hid0),
 	_SYSDEV_ATTR(hid1, 0600, show_hid1, store_hid1),
 	_SYSDEV_ATTR(hid4, 0600, show_hid4, store_hid4),
 	_SYSDEV_ATTR(hid5, 0600, show_hid5, store_hid5),
 	_SYSDEV_ATTR(ima0, 0600, show_ima0, store_ima0),
 	_SYSDEV_ATTR(ima1, 0600, show_ima1, store_ima1),
 	_SYSDEV_ATTR(ima2, 0600, show_ima2, store_ima2),
 	_SYSDEV_ATTR(ima3, 0600, show_ima3, store_ima3),
 	_SYSDEV_ATTR(ima4, 0600, show_ima4, store_ima4),

> > +#define kpf_copy_bit(uflags, kflags, visible, ubit, kbit)		\
> > +	do {								\
> > +		if (visible || genuine_linus())				\
> > +			uflags |= ((kflags >> kbit) & 1) << ubit;	\
> > +	} while (0);
> 
> Did this have to be implemented as a macro?
> 
> It's bad, because it might or might not reference its argument, so if
> someone passes it an expression-with-side-effects, the end result is
> unpredictable.  A C function is almost always preferable if possible.

Just tried inline function, the code size is increased slightly:

          text   data    bss     dec    hex   filename
macro     1804    128      0    1932    78c   fs/proc/page.o
inline    1828    128      0    1956    7a4   fs/proc/page.o

So I'll keep the macro, but add brackets to make it a bit safer.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
