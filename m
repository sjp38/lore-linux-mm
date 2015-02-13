Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3DD6B0080
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 12:49:49 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so22637751obb.3
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 09:49:48 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id v2si1493474obz.104.2015.02.13.09.49.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 09:49:48 -0800 (PST)
Received: by mail-ob0-f171.google.com with SMTP id gq1so22648255obb.2
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 09:49:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
	<CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
	<alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
Date: Fri, 13 Feb 2015 09:49:47 -0800
Message-ID: <CAGXu5jKSfGzkpNt1-_vRykDCJTCxJg+vRi1D_9a=8auKu-YtgQ@mail.gmail.com>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Feb 13, 2015 at 7:04 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes
> the base address for module to be unconditionally randomized in case when
> CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the
> commandline.
>
> This is not consistent with how choose_kernel_location() decides whether
> it will randomize kernel load base.
>
> Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is
> explicitly specified on kernel commandline), which makes the state space
> larger than what module loader is looking at. IOW CONFIG_HIBERNATION &&
> CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied
> by default in that case, but module loader is not aware of that.
>
> Instead of fixing the logic in module.c, this patch takes more generic
> aproach. It introduces a new bootparam setup data_type SETUP_KASLR and
> uses that to pass the information whether kaslr has been applied during
> kernel decompression, and sets a global 'kaslr_enabled' variable
> accordingly, so that any kernel code (module loading, livepatching, ...)
> can make decisions based on its value.
>
> x86 module loader is converted to make use of this flag.
>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Thanks for working on this! If others are happy with the setup_data
approach, I think this is fine. My only concern is confusion over
seeing SETUP_KASLR that was added by a boot loader.

Another way to handle it might be to do some kind of relocs-like
poking of a value into the decompressed kernel?

> ---
>
> v1 -> v2:
>
> Originally I just calculated the fact on the fly from difference between
> __START_KERNEL and &text, but Kees correctly pointed out that this doesn't
> properly catch the case when the offset is randomized to zero. I don't see
> a better option how to propagate the information from
> choose_kernel_location() to the decompressed kernel than introducing new
> bootparam setup type. Comments welcome.
>
>  arch/x86/boot/compressed/aslr.c       | 34 +++++++++++++++++++++++++++++++++-
>  arch/x86/boot/compressed/misc.c       |  3 ++-
>  arch/x86/boot/compressed/misc.h       |  6 ++++--
>  arch/x86/include/asm/page_types.h     |  3 +++
>  arch/x86/include/uapi/asm/bootparam.h |  1 +
>  arch/x86/kernel/module.c              | 11 ++---------
>  arch/x86/kernel/setup.c               | 10 ++++++++++
>  7 files changed, 55 insertions(+), 13 deletions(-)
>
> diff --git a/arch/x86/boot/compressed/aslr.c b/arch/x86/boot/compressed/aslr.c
> index bb13763..d9d1da9 100644
> --- a/arch/x86/boot/compressed/aslr.c
> +++ b/arch/x86/boot/compressed/aslr.c
> @@ -14,6 +14,13 @@
>  static const char build_str[] = UTS_RELEASE " (" LINUX_COMPILE_BY "@"
>                 LINUX_COMPILE_HOST ") (" LINUX_COMPILER ") " UTS_VERSION;
>
> +struct kaslr_setup_data {

Should this be "static"?

> +        __u64 next;
> +        __u32 type;
> +        __u32 len;
> +        __u8 data[1];
> +} kaslr_setup_data;
> +
>  #define I8254_PORT_CONTROL     0x43
>  #define I8254_PORT_COUNTER0    0x40
>  #define I8254_CMD_READBACK     0xC0
> @@ -295,7 +302,29 @@ static unsigned long find_random_addr(unsigned long minimum,
>         return slots_fetch_random();
>  }
>
> -unsigned char *choose_kernel_location(unsigned char *input,
> +static void add_kaslr_setup_data(struct boot_params *params, __u8 enabled)
> +{
> +       struct setup_data *data;
> +
> +       kaslr_setup_data.type = SETUP_KASLR;
> +       kaslr_setup_data.len = 1;
> +       kaslr_setup_data.next = 0;
> +       kaslr_setup_data.data[0] = enabled;
> +
> +       data = (struct setup_data *)(unsigned long)params->hdr.setup_data;
> +
> +       while (data && data->next)
> +               data = (struct setup_data *)(unsigned long)data->next;
> +
> +       if (data)
> +               data->next = (unsigned long)&kaslr_setup_data;
> +       else
> +               params->hdr.setup_data = (unsigned long)&kaslr_setup_data;
> +
> +}
> +
> +unsigned char *choose_kernel_location(struct boot_params *params,
> +                                     unsigned char *input,
>                                       unsigned long input_size,
>                                       unsigned char *output,
>                                       unsigned long output_size)
> @@ -306,14 +335,17 @@ unsigned char *choose_kernel_location(unsigned char *input,
>  #ifdef CONFIG_HIBERNATION
>         if (!cmdline_find_option_bool("kaslr")) {
>                 debug_putstr("KASLR disabled by default...\n");
> +               add_kaslr_setup_data(params, 0);
>                 goto out;
>         }
>  #else
>         if (cmdline_find_option_bool("nokaslr")) {
>                 debug_putstr("KASLR disabled by cmdline...\n");
> +               add_kaslr_setup_data(params, 0);
>                 goto out;
>         }
>  #endif
> +       add_kaslr_setup_data(params, 1);
>
>         /* Record the various known unsafe memory ranges. */
>         mem_avoid_init((unsigned long)input, input_size,
> diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
> index dcc1c53..5aecf56 100644
> --- a/arch/x86/boot/compressed/misc.c
> +++ b/arch/x86/boot/compressed/misc.c
> @@ -399,7 +399,8 @@ asmlinkage __visible void *decompress_kernel(void *rmode, memptr heap,
>          * the entire decompressed kernel plus relocation table, or the
>          * entire decompressed kernel plus .bss and .brk sections.
>          */
> -       output = choose_kernel_location(input_data, input_len, output,
> +       output = choose_kernel_location(real_mode, input_data, input_len,
> +                                       output,
>                                         output_len > run_size ? output_len
>                                                               : run_size);
>
> diff --git a/arch/x86/boot/compressed/misc.h b/arch/x86/boot/compressed/misc.h
> index 24e3e56..6d67307 100644
> --- a/arch/x86/boot/compressed/misc.h
> +++ b/arch/x86/boot/compressed/misc.h
> @@ -56,7 +56,8 @@ int cmdline_find_option_bool(const char *option);
>
>  #if CONFIG_RANDOMIZE_BASE
>  /* aslr.c */
> -unsigned char *choose_kernel_location(unsigned char *input,
> +unsigned char *choose_kernel_location(struct boot_params *params,
> +                                     unsigned char *input,
>                                       unsigned long input_size,
>                                       unsigned char *output,
>                                       unsigned long output_size);
> @@ -64,7 +65,8 @@ unsigned char *choose_kernel_location(unsigned char *input,
>  bool has_cpuflag(int flag);
>  #else
>  static inline
> -unsigned char *choose_kernel_location(unsigned char *input,
> +unsigned char *choose_kernel_location(struct boot_params *params,
> +                                     unsigned char *input,
>                                       unsigned long input_size,
>                                       unsigned char *output,
>                                       unsigned long output_size)
> diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> index f97fbe3..3d43ce3 100644
> --- a/arch/x86/include/asm/page_types.h
> +++ b/arch/x86/include/asm/page_types.h
> @@ -3,6 +3,7 @@
>
>  #include <linux/const.h>
>  #include <linux/types.h>
> +#include <asm/bootparam.h>
>
>  /* PAGE_SHIFT determines the page size */
>  #define PAGE_SHIFT     12
> @@ -51,6 +52,8 @@ extern int devmem_is_allowed(unsigned long pagenr);
>  extern unsigned long max_low_pfn_mapped;
>  extern unsigned long max_pfn_mapped;
>
> +extern bool kaslr_enabled;
> +
>  static inline phys_addr_t get_max_mapped(void)
>  {
>         return (phys_addr_t)max_pfn_mapped << PAGE_SHIFT;
> diff --git a/arch/x86/include/uapi/asm/bootparam.h b/arch/x86/include/uapi/asm/bootparam.h
> index 225b098..44e6dd7 100644
> --- a/arch/x86/include/uapi/asm/bootparam.h
> +++ b/arch/x86/include/uapi/asm/bootparam.h
> @@ -7,6 +7,7 @@
>  #define SETUP_DTB                      2
>  #define SETUP_PCI                      3
>  #define SETUP_EFI                      4
> +#define SETUP_KASLR                    5
>
>  /* ram_size flags */
>  #define RAMDISK_IMAGE_START_MASK       0x07FF
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index e69f988..c3c59a3 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -32,6 +32,7 @@
>
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> +#include <asm/page_types.h>
>
>  #if 0
>  #define DEBUGP(fmt, ...)                               \
> @@ -46,21 +47,13 @@ do {                                                        \
>
>  #ifdef CONFIG_RANDOMIZE_BASE
>  static unsigned long module_load_offset;
> -static int randomize_modules = 1;
>
>  /* Mutex protects the module_load_offset. */
>  static DEFINE_MUTEX(module_kaslr_mutex);
>
> -static int __init parse_nokaslr(char *p)
> -{
> -       randomize_modules = 0;
> -       return 0;
> -}
> -early_param("nokaslr", parse_nokaslr);
> -
>  static unsigned long int get_module_load_offset(void)
>  {
> -       if (randomize_modules) {
> +       if (kaslr_enabled) {
>                 mutex_lock(&module_kaslr_mutex);
>                 /*
>                  * Calculate the module_load_offset the first time this
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index ab4734e..78c91bb 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -121,6 +121,8 @@
>  unsigned long max_low_pfn_mapped;
>  unsigned long max_pfn_mapped;
>
> +bool __read_mostly kaslr_enabled = false;
> +
>  #ifdef CONFIG_DMI
>  RESERVE_BRK(dmi_alloc, 65536);
>  #endif
> @@ -424,6 +426,11 @@ static void __init reserve_initrd(void)
>  }
>  #endif /* CONFIG_BLK_DEV_INITRD */
>
> +static void __init parse_kaslr_setup(u64 pa_data, u32 data_len)
> +{
> +       kaslr_enabled = (bool)(pa_data + sizeof(struct setup_data));
> +}
> +
>  static void __init parse_setup_data(void)
>  {
>         struct setup_data *data;
> @@ -451,6 +458,9 @@ static void __init parse_setup_data(void)
>                 case SETUP_EFI:
>                         parse_efi_setup(pa_data, data_len);
>                         break;
> +               case SETUP_KASLR:
> +                       parse_kaslr_setup(pa_data, data_len);
> +                       break;
>                 default:
>                         break;
>                 }
> --
> Jiri Kosina
> SUSE Labs

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
