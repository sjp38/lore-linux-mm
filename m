Received: by wr-out-0506.google.com with SMTP id c37so2764472wra.26
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 15:34:50 -0700 (PDT)
Message-ID: <86802c440803241534p5c28193brf769280fe05d286d@mail.gmail.com>
Date: Mon, 24 Mar 2008 15:34:49 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 1/8] x86_64: Change GET_APIC_ID() from an inline function to an out-of-line function
In-Reply-To: <20080324182107.GA27979@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182107.GA27979@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 11:21 AM, Jack Steiner <steiner@sgi.com> wrote:
>
>  Change GET_APIC_ID() on x86_64 from an inline function to an
>  out-of-line function. The function is rarely called and the
>  additional overhead is negligible.
>
>  This change is in preparation for additional changes to
>  the APICID functions that will come in a later patch.
>
>         Signed-off-by: Jack Steiner <steiner@sgi.com>
>
>  ---
>   arch/x86/kernel/apic_64.c         |    2 +-
>   arch/x86/kernel/genapic_64.c      |    5 +++++
>   arch/x86/kernel/genapic_flat_64.c |    2 +-
>   arch/x86/kernel/io_apic_64.c      |    4 ++--
>   arch/x86/kernel/mpparse_64.c      |    2 +-
>   arch/x86/kernel/smpboot_64.c      |    6 +++---
>   include/asm-x86/apic.h            |    1 +
>   include/asm-x86/apicdef.h         |    1 -
>   include/asm-x86/smp_64.h          |    2 +-
>   9 files changed, 15 insertions(+), 10 deletions(-)
>
>  Index: linux/arch/x86/kernel/apic_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/apic_64.c        2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/apic_64.c     2008-03-20 15:30:23.000000000 -0500
>  @@ -885,7 +885,7 @@ void __init init_apic_mappings(void)
>          * Fetch the APIC ID of the BSP in case we have a
>          * default configuration (or the MP table is broken).
>          */
>  -       boot_cpu_id = GET_APIC_ID(apic_read(APIC_ID));
>  +       boot_cpu_id = get_apic_id();
>   }
>
>   /*
>  Index: linux/arch/x86/kernel/genapic_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/genapic_64.c     2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/genapic_64.c  2008-03-21 09:13:41.000000000 -0500
>  @@ -64,3 +64,8 @@ void send_IPI_self(int vector)
>   {
>         __send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL);
>   }
>  +
>  +unsigned int get_apic_id(void)
>  +{
>  +       return (apic_read(APIC_ID) >> 24) & 0xFFu;
>  +}
>  Index: linux/arch/x86/kernel/genapic_flat_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/genapic_flat_64.c        2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/genapic_flat_64.c     2008-03-20 15:30:23.000000000 -0500
>  @@ -97,7 +97,7 @@ static void flat_send_IPI_all(int vector
>
>   static int flat_apic_id_registered(void)
>   {
>  -       return physid_isset(GET_APIC_ID(apic_read(APIC_ID)), phys_cpu_present_map);
>  +       return physid_isset(get_apic_id(), phys_cpu_present_map);
>   }
>
>   static unsigned int flat_cpu_mask_to_apicid(cpumask_t cpumask)
>  Index: linux/arch/x86/kernel/io_apic_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/io_apic_64.c     2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/io_apic_64.c  2008-03-21 09:07:19.000000000 -0500
>  @@ -1067,7 +1067,7 @@ void __apicdebuginit print_local_APIC(vo
>         printk("\n" KERN_DEBUG "printing local APIC contents on CPU#%d/%d:\n",
>                 smp_processor_id(), hard_smp_processor_id());
>         v = apic_read(APIC_ID);
>  -       printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v, GET_APIC_ID(v));
>  +       printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v, get_apic_id());
>         v = apic_read(APIC_LVR);
>         printk(KERN_INFO "... APIC VERSION: %08x\n", v);
>         ver = GET_APIC_VERSION(v);
>  @@ -1261,7 +1261,7 @@ void disable_IO_APIC(void)
>                 entry.dest_mode       = 0; /* Physical */
>                 entry.delivery_mode   = dest_ExtINT; /* ExtInt */
>                 entry.vector          = 0;
>  -               entry.dest          = GET_APIC_ID(apic_read(APIC_ID));
>  +               entry.dest          = get_apic_id();
>
>                 /*
>                  * Add it to the IO-APIC irq-routing table:
>  Index: linux/arch/x86/kernel/mpparse_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/mpparse_64.c     2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/mpparse_64.c  2008-03-21 09:07:23.000000000 -0500
>  @@ -614,7 +614,7 @@ void __init mp_register_lapic_address(u6
>         mp_lapic_addr = (unsigned long) address;
>         set_fixmap_nocache(FIX_APIC_BASE, mp_lapic_addr);
>         if (boot_cpu_id == -1U)
>  -               boot_cpu_id = GET_APIC_ID(apic_read(APIC_ID));
>  +               boot_cpu_id = get_apic_id();
>   }
>
>   void __cpuinit mp_register_lapic (u8 id, u8 enabled)
>  Index: linux/arch/x86/kernel/smpboot_64.c
>  ===================================================================
>  --- linux.orig/arch/x86/kernel/smpboot_64.c     2008-03-18 14:54:19.000000000 -0500
>  +++ linux/arch/x86/kernel/smpboot_64.c  2008-03-21 09:07:19.000000000 -0500
>  @@ -158,7 +158,7 @@ void __cpuinit smp_callin(void)
>         /*
>          * (This works even if the APIC is not enabled.)
>          */
>  -       phys_id = GET_APIC_ID(apic_read(APIC_ID));
>  +       phys_id = get_apic_id();
>         cpuid = smp_processor_id();
>         if (cpu_isset(cpuid, cpu_callin_map)) {
>                 panic("smp_callin: phys CPU#%d, CPU#%d already present??\n",
>  @@ -878,9 +878,9 @@ void __init smp_prepare_cpus(unsigned in
>                 enable_IO_APIC();
>         end_local_APIC_setup();
>
>  -       if (GET_APIC_ID(apic_read(APIC_ID)) != boot_cpu_id) {
>  +       if (get_apic_id() != boot_cpu_id) {
>                 panic("Boot APIC ID in local APIC unexpected (%d vs %d)",
>  -                     GET_APIC_ID(apic_read(APIC_ID)), boot_cpu_id);
>  +                     get_apic_id(), boot_cpu_id);
>                 /* Or can we switch back to PIC here? */
>         }
>
>  Index: linux/include/asm-x86/apic.h
>  ===================================================================
>  --- linux.orig/include/asm-x86/apic.h   2008-03-18 14:54:19.000000000 -0500
>  +++ linux/include/asm-x86/apic.h        2008-03-21 09:07:59.000000000 -0500
>  @@ -129,6 +129,7 @@ extern void enable_NMI_through_LVT0(void
>   */
>   #ifdef CONFIG_X86_64
>   extern void setup_apic_routing(void);
>  +extern unsigned int get_apic_id(void);
>   #endif
>
>   extern u8 setup_APIC_eilvt_mce(u8 vector, u8 msg_type, u8 mask);
>  Index: linux/include/asm-x86/apicdef.h
>  ===================================================================
>  --- linux.orig/include/asm-x86/apicdef.h        2008-03-18 14:54:19.000000000 -0500
>  +++ linux/include/asm-x86/apicdef.h     2008-03-21 09:07:23.000000000 -0500
>  @@ -14,7 +14,6 @@
>
>   #ifdef CONFIG_X86_64
>   # define       APIC_ID_MASK            (0xFFu<<24)
>  -# define       GET_APIC_ID(x)          (((x)>>24)&0xFFu)
>   # define       SET_APIC_ID(x)          (((x)<<24))
>   #endif

it this patch after smpboot.c integration?

that patchsets have GET_APIC_ID in mach_apicdef.h instead of apicdef.h

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
