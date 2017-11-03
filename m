Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3E66B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:31:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 15so3706310pgc.16
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:31:44 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0050.outbound.protection.outlook.com. [104.47.32.50])
        by mx.google.com with ESMTPS id s186si6601246pgc.383.2017.11.03.08.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 08:31:42 -0700 (PDT)
Subject: Re: [PATCH v10 20/38] x86, mpparse: Use memremap to map the mpf and
 mpc data
References: <cover.1500319216.git.thomas.lendacky@amd.com>
 <d9464b0d7c861021ed8f494e4a40d6cd10f1eddd.1500319216.git.thomas.lendacky@amd.com>
 <CAAObsKDNwxevQVjob9zNwBWR+PjL8VVvCuxRwdGmgNgZ0uhEYw@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <ea487555-0f56-d3f5-863d-7007e9631235@amd.com>
Date: Fri, 3 Nov 2017 10:31:20 -0500
MIME-Version: 1.0
In-Reply-To: <CAAObsKDNwxevQVjob9zNwBWR+PjL8VVvCuxRwdGmgNgZ0uhEYw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomeu Vizoso <tomeu@tomeuvizoso.net>
Cc: x86@kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Guenter Roeck <groeck@google.com>, Zach Reizner <zachr@google.com>, Dylan Reid <dgreid@chromium.org>

On 11/3/2017 10:12 AM, Tomeu Vizoso wrote:
> On 17 July 2017 at 23:10, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>> The SMP MP-table is built by UEFI and placed in memory in a decrypted
>> state. These tables are accessed using a mix of early_memremap(),
>> early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
>> to use early_memremap()/early_memunmap(). This allows for proper setting
>> of the encryption mask so that the data can be successfully accessed when
>> SME is active.
>>
>> Reviewed-by: Borislav Petkov <bp@suse.de>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/kernel/mpparse.c | 98 +++++++++++++++++++++++++++++++++--------------
>>   1 file changed, 70 insertions(+), 28 deletions(-)
> 
> Hi there,
> 
> today I played a bit with crosvm [0] and noticed that 4.14-rc7 doesn't
> boot. git-bisect pointed to this patch, and reverting it indeed gets
> things working again.
> 
> Anybody has an idea of why this could be?

If you send me your kernel config I'll see if I can reproduce the issue
and debug it.

Thanks,
Tom

> 
> Thanks,
> 
> Tomeu
> 
> [0] https://chromium.googlesource.com/chromiumos/platform/crosvm
> 
>>
>> diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
>> index fd37f39..5cbb317 100644
>> --- a/arch/x86/kernel/mpparse.c
>> +++ b/arch/x86/kernel/mpparse.c
>> @@ -429,7 +429,7 @@ static inline void __init construct_default_ISA_mptable(int mpc_default_type)
>>          }
>>   }
>>
>> -static struct mpf_intel *mpf_found;
>> +static unsigned long mpf_base;
>>
>>   static unsigned long __init get_mpc_size(unsigned long physptr)
>>   {
>> @@ -451,6 +451,7 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
>>
>>          size = get_mpc_size(mpf->physptr);
>>          mpc = early_memremap(mpf->physptr, size);
>> +
>>          /*
>>           * Read the physical hardware table.  Anything here will
>>           * override the defaults.
>> @@ -497,12 +498,12 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
>>    */
>>   void __init default_get_smp_config(unsigned int early)
>>   {
>> -       struct mpf_intel *mpf = mpf_found;
>> +       struct mpf_intel *mpf;
>>
>>          if (!smp_found_config)
>>                  return;
>>
>> -       if (!mpf)
>> +       if (!mpf_base)
>>                  return;
>>
>>          if (acpi_lapic && early)
>> @@ -515,6 +516,12 @@ void __init default_get_smp_config(unsigned int early)
>>          if (acpi_lapic && acpi_ioapic)
>>                  return;
>>
>> +       mpf = early_memremap(mpf_base, sizeof(*mpf));
>> +       if (!mpf) {
>> +               pr_err("MPTABLE: error mapping MP table\n");
>> +               return;
>> +       }
>> +
>>          pr_info("Intel MultiProcessor Specification v1.%d\n",
>>                  mpf->specification);
>>   #if defined(CONFIG_X86_LOCAL_APIC) && defined(CONFIG_X86_32)
>> @@ -529,7 +536,7 @@ void __init default_get_smp_config(unsigned int early)
>>          /*
>>           * Now see if we need to read further.
>>           */
>> -       if (mpf->feature1 != 0) {
>> +       if (mpf->feature1) {
>>                  if (early) {
>>                          /*
>>                           * local APIC has default address
>> @@ -542,8 +549,10 @@ void __init default_get_smp_config(unsigned int early)
>>                  construct_default_ISA_mptable(mpf->feature1);
>>
>>          } else if (mpf->physptr) {
>> -               if (check_physptr(mpf, early))
>> +               if (check_physptr(mpf, early)) {
>> +                       early_memunmap(mpf, sizeof(*mpf));
>>                          return;
>> +               }
>>          } else
>>                  BUG();
>>
>> @@ -552,6 +561,8 @@ void __init default_get_smp_config(unsigned int early)
>>          /*
>>           * Only use the first configuration found.
>>           */
>> +
>> +       early_memunmap(mpf, sizeof(*mpf));
>>   }
>>
>>   static void __init smp_reserve_memory(struct mpf_intel *mpf)
>> @@ -561,15 +572,16 @@ static void __init smp_reserve_memory(struct mpf_intel *mpf)
>>
>>   static int __init smp_scan_config(unsigned long base, unsigned long length)
>>   {
>> -       unsigned int *bp = phys_to_virt(base);
>> +       unsigned int *bp;
>>          struct mpf_intel *mpf;
>> -       unsigned long mem;
>> +       int ret = 0;
>>
>>          apic_printk(APIC_VERBOSE, "Scan for SMP in [mem %#010lx-%#010lx]\n",
>>                      base, base + length - 1);
>>          BUILD_BUG_ON(sizeof(*mpf) != 16);
>>
>>          while (length > 0) {
>> +               bp = early_memremap(base, length);
>>                  mpf = (struct mpf_intel *)bp;
>>                  if ((*bp == SMP_MAGIC_IDENT) &&
>>                      (mpf->length == 1) &&
>> @@ -579,24 +591,26 @@ static int __init smp_scan_config(unsigned long base, unsigned long length)
>>   #ifdef CONFIG_X86_LOCAL_APIC
>>                          smp_found_config = 1;
>>   #endif
>> -                       mpf_found = mpf;
>> +                       mpf_base = base;
>>
>> -                       pr_info("found SMP MP-table at [mem %#010llx-%#010llx] mapped at [%p]\n",
>> -                               (unsigned long long) virt_to_phys(mpf),
>> -                               (unsigned long long) virt_to_phys(mpf) +
>> -                               sizeof(*mpf) - 1, mpf);
>> +                       pr_info("found SMP MP-table at [mem %#010lx-%#010lx] mapped at [%p]\n",
>> +                               base, base + sizeof(*mpf) - 1, mpf);
>>
>> -                       mem = virt_to_phys(mpf);
>> -                       memblock_reserve(mem, sizeof(*mpf));
>> +                       memblock_reserve(base, sizeof(*mpf));
>>                          if (mpf->physptr)
>>                                  smp_reserve_memory(mpf);
>>
>> -                       return 1;
>> +                       ret = 1;
>>                  }
>> -               bp += 4;
>> +               early_memunmap(bp, length);
>> +
>> +               if (ret)
>> +                       break;
>> +
>> +               base += 16;
>>                  length -= 16;
>>          }
>> -       return 0;
>> +       return ret;
>>   }
>>
>>   void __init default_find_smp_config(void)
>> @@ -838,29 +852,40 @@ static int __init update_mp_table(void)
>>          char oem[10];
>>          struct mpf_intel *mpf;
>>          struct mpc_table *mpc, *mpc_new;
>> +       unsigned long size;
>>
>>          if (!enable_update_mptable)
>>                  return 0;
>>
>> -       mpf = mpf_found;
>> -       if (!mpf)
>> +       if (!mpf_base)
>> +               return 0;
>> +
>> +       mpf = early_memremap(mpf_base, sizeof(*mpf));
>> +       if (!mpf) {
>> +               pr_err("MPTABLE: mpf early_memremap() failed\n");
>>                  return 0;
>> +       }
>>
>>          /*
>>           * Now see if we need to go further.
>>           */
>> -       if (mpf->feature1 != 0)
>> -               return 0;
>> +       if (mpf->feature1)
>> +               goto do_unmap_mpf;
>>
>>          if (!mpf->physptr)
>> -               return 0;
>> +               goto do_unmap_mpf;
>>
>> -       mpc = phys_to_virt(mpf->physptr);
>> +       size = get_mpc_size(mpf->physptr);
>> +       mpc = early_memremap(mpf->physptr, size);
>> +       if (!mpc) {
>> +               pr_err("MPTABLE: mpc early_memremap() failed\n");
>> +               goto do_unmap_mpf;
>> +       }
>>
>>          if (!smp_check_mpc(mpc, oem, str))
>> -               return 0;
>> +               goto do_unmap_mpc;
>>
>> -       pr_info("mpf: %llx\n", (u64)virt_to_phys(mpf));
>> +       pr_info("mpf: %llx\n", (u64)mpf_base);
>>          pr_info("physptr: %x\n", mpf->physptr);
>>
>>          if (mpc_new_phys && mpc->length > mpc_new_length) {
>> @@ -878,21 +903,32 @@ static int __init update_mp_table(void)
>>                  new = mpf_checksum((unsigned char *)mpc, mpc->length);
>>                  if (old == new) {
>>                          pr_info("mpc is readonly, please try alloc_mptable instead\n");
>> -                       return 0;
>> +                       goto do_unmap_mpc;
>>                  }
>>                  pr_info("use in-position replacing\n");
>>          } else {
>> +               mpc_new = early_memremap(mpc_new_phys, mpc_new_length);
>> +               if (!mpc_new) {
>> +                       pr_err("MPTABLE: new mpc early_memremap() failed\n");
>> +                       goto do_unmap_mpc;
>> +               }
>>                  mpf->physptr = mpc_new_phys;
>> -               mpc_new = phys_to_virt(mpc_new_phys);
>>                  memcpy(mpc_new, mpc, mpc->length);
>> +               early_memunmap(mpc, size);
>>                  mpc = mpc_new;
>> +               size = mpc_new_length;
>>                  /* check if we can modify that */
>>                  if (mpc_new_phys - mpf->physptr) {
>>                          struct mpf_intel *mpf_new;
>>                          /* steal 16 bytes from [0, 1k) */
>> +                       mpf_new = early_memremap(0x400 - 16, sizeof(*mpf_new));
>> +                       if (!mpf_new) {
>> +                               pr_err("MPTABLE: new mpf early_memremap() failed\n");
>> +                               goto do_unmap_mpc;
>> +                       }
>>                          pr_info("mpf new: %x\n", 0x400 - 16);
>> -                       mpf_new = phys_to_virt(0x400 - 16);
>>                          memcpy(mpf_new, mpf, 16);
>> +                       early_memunmap(mpf, sizeof(*mpf));
>>                          mpf = mpf_new;
>>                          mpf->physptr = mpc_new_phys;
>>                  }
>> @@ -909,6 +945,12 @@ static int __init update_mp_table(void)
>>           */
>>          replace_intsrc_all(mpc, mpc_new_phys, mpc_new_length);
>>
>> +do_unmap_mpc:
>> +       early_memunmap(mpc, size);
>> +
>> +do_unmap_mpf:
>> +       early_memunmap(mpf, sizeof(*mpf));
>> +
>>          return 0;
>>   }
>>
>> --
>> 1.9.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
