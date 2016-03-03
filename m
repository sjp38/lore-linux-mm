Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5A94A6B007E
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 19:25:51 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id z13so2759035ykd.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 16:25:51 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c206si5542427ybb.63.2016.03.02.16.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 16:25:50 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <CAGRGNgXCcEmKU9f2XRpRv6By4QPZU7rxxTQPzSp+kahjmRTO5Q@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56D78471.1020707@oracle.com>
Date: Wed, 2 Mar 2016 17:25:21 -0700
MIME-Version: 1.0
In-Reply-To: <CAGRGNgXCcEmKU9f2XRpRv6By4QPZU7rxxTQPzSp+kahjmRTO5Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Calaby <julian.calaby@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, corbet@lwn.net, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, sparclinux <sparclinux@vger.kernel.org>, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andy Lutomirski <luto@kernel.org>, ebiederm@xmission.com, bsegall@google.com, Geert Uytterhoeven <geert@linux-m68k.org>, dave@stgolabs.net, Alexey Dobriyan <adobriyan@gmail.com>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

Thanks, Julian! I really appreciate your feedback.

My comments below.

On 03/02/2016 04:08 PM, Julian Calaby wrote:
> Hi Khalid,
>
> On Thu, Mar 3, 2016 at 7:39 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>
>> Enable Application Data Integrity (ADI) support in the sparc
>> kernel for applications to use ADI in userspace. ADI is a new
>> feature supported on sparc M7 and newer processors. ADI is supported
>> for data fetches only and not instruction fetches. This patch adds
>> prctl commands to enable and disable ADI (TSTATE.mcde), return ADI
>> parameters to userspace, enable/disable MCD (Memory Corruption
>> Detection) on selected memory ranges and enable TTE.mcd in PTEs. It
>> also adds handlers for all traps related to MCD. ADI is not enabled
>> by default for any task and a task must explicitly enable ADI
>> (TSTATE.mcde), turn MCD on on a memory range and set version tag
>> for ADI to be effective for the task. This patch adds support for
>> ADI for hugepages only. Addresses passed into system calls must be
>> non-ADI tagged addresses.
>
> I can't comment on the actual functionality here, but I do see a few
> minor style issues in your patch.
>
> My big concern is that you're defining a lot of new code that is ADI
> specific but isn't inside a CONFIG_SPARC_ADI ifdef. (That said,
> handling ADI specific traps if ADI isn't enabled looks like a good
> idea to me, however most of the other stuff is just dead code if
> CONFIG_SPARC_ADI isn't enabled.)

Some of the code will be executed when CONFIG_SPARC_ADI is not enabled, 
for instance init_adi() which will parse machine description to 
determine if platform supports ADI. On the other hand, it might still 
make sense to enclose this code in #ifdef. More on that below.

>
>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>> ---
>> NOTES: ADI is a new feature added to M7 processor to allow hardware
>>          to catch rogue accesses to memory. An app can enable ADI on
>>          its data pages, set version tags on them and use versioned
>>          addresses (bits 63-60 of the address contain a version tag)
>>          to access the data pages. If a rogue app attempts to access
>>          ADI enabled data pages, its access is blocked and processor
>>          generates an exception. Enabling this functionality for all
>>          data pages of an app requires adding infrastructure to save
>>          version tags for any data pages that get swapped out and
>>          restoring those tags when pages are swapped back in. In this
>>          first implementation I am enabling ADI for hugepages only
>>          since these pages are locked in memory and hence avoid the
>>          issue of saving and restoring tags. Once this core functionality
>>          is stable, ADI for other memory pages can be enabled more
>>          easily.
>>
>> v2:
>>          - Fixed a build error
>>
>>   Documentation/prctl/sparc_adi.txt     |  62 ++++++++++
>>   Documentation/sparc/adi.txt           | 206 +++++++++++++++++++++++++++++++
>>   arch/sparc/Kconfig                    |  12 ++
>>   arch/sparc/include/asm/hugetlb.h      |  14 +++
>>   arch/sparc/include/asm/hypervisor.h   |   2 +
>>   arch/sparc/include/asm/mmu_64.h       |   1 +
>>   arch/sparc/include/asm/pgtable_64.h   |  15 +++
>>   arch/sparc/include/asm/processor_64.h |  19 +++
>>   arch/sparc/include/asm/ttable.h       |  10 ++
>>   arch/sparc/include/uapi/asm/asi.h     |   3 +
>>   arch/sparc/include/uapi/asm/pstate.h  |  10 ++
>>   arch/sparc/kernel/entry.h             |   3 +
>>   arch/sparc/kernel/head_64.S           |   1 +
>>   arch/sparc/kernel/mdesc.c             |  81 +++++++++++++
>>   arch/sparc/kernel/process_64.c        | 222 ++++++++++++++++++++++++++++++++++
>>   arch/sparc/kernel/sun4v_mcd.S         |  16 +++
>>   arch/sparc/kernel/traps_64.c          |  96 ++++++++++++++-
>>   arch/sparc/kernel/ttable_64.S         |   6 +-
>>   include/linux/mm.h                    |   2 +
>>   include/uapi/asm-generic/siginfo.h    |   5 +-
>>   include/uapi/linux/prctl.h            |  16 +++
>>   kernel/sys.c                          |  30 +++++
>>   22 files changed, 826 insertions(+), 6 deletions(-)
>>   create mode 100644 Documentation/prctl/sparc_adi.txt
>>   create mode 100644 Documentation/sparc/adi.txt
>>   create mode 100644 arch/sparc/kernel/sun4v_mcd.S
>
> I must admit that I'm slightly impressed that the documentation is
> over a quarter of the lines added. =)
>
>> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
>> index 56442d2..0aac0ae 100644
>> --- a/arch/sparc/Kconfig
>> +++ b/arch/sparc/Kconfig
>> @@ -80,6 +80,7 @@ config SPARC64
>>          select NO_BOOTMEM
>>          select HAVE_ARCH_AUDITSYSCALL
>>          select ARCH_SUPPORTS_ATOMIC_RMW
>> +       select SPARC_ADI
>
> This doesn't look right.
>
>>   config ARCH_DEFCONFIG
>>          string
>> @@ -314,6 +315,17 @@ if SPARC64
>>   source "kernel/power/Kconfig"
>>   endif
>>
>> +config SPARC_ADI
>> +       bool "Application Data Integrity support"
>> +       def_bool y if SPARC64
>
> def_bool is for config options without names (i.e. "this is a boolean
> value and it's default is...")
>
> So if you want people to be able to disable this option, then you
> should remove the select above and just have:
>
> bool "Application Data Integrity support"
> default y if SPARC64
>
> If you don't want people disabling it, then there's no point in having
> a separate Kconfig symbol.
>

Ah, I see. I do not want people disabling it. I will make changes.

>> +       help
>> +         Support for Application Data Integrity (ADI). ADI feature allows
>> +         a process to tag memory blocks with version tags. Once ADI is
>> +         enabled and version tag is set on a memory block, any access to
>> +         it is allowed only if the correct version tag is presented by
>> +         a process. This feature is meant to help catch rogue accesses
>> +         to memory.
>> +
>
> You should probably mention that it's only available on newer
> processors and recommend that it's enabled on them.

Good point.

>
> This code won't break anything on older processors, right? I haven't
> looked very closely, but I don't see anything that specifically
> disables the code if it's run on, say, a UltraSparc I.

Right, this code does not break anything on older processors and has 
been tested on older machines. init_adi() will detect the platform does 
not support ADI when it parses machine description and will leave ADI 
disabled in that case (adi_state.enabled=false).

>
>>   config SCHED_SMT
>>          bool "SMT (Hyperthreading) scheduler support"
>>          depends on SPARC64 && SMP
>> diff --git a/arch/sparc/include/asm/processor_64.h b/arch/sparc/include/asm/processor_64.h
>> index 6924bde..9a71701 100644
>> --- a/arch/sparc/include/asm/processor_64.h
>> +++ b/arch/sparc/include/asm/processor_64.h
>> @@ -97,6 +97,25 @@ struct thread_struct {
>>   struct task_struct;
>>   unsigned long thread_saved_pc(struct task_struct *);
>>
>> +#ifdef CONFIG_SPARC_ADI
>> +extern struct adi_caps *get_adi_caps(void);
>> +extern long get_sparc_adicaps(unsigned long);
>> +extern long set_sparc_pstate_mcde(unsigned long);
>> +extern long enable_sparc_adi(unsigned long, unsigned long);
>> +extern long disable_sparc_adi(unsigned long, unsigned long);
>> +extern long get_sparc_adi_status(unsigned long);
>> +extern bool adi_capable(void);
>> +
>> +#define GET_SPARC_ADICAPS(a)   get_sparc_adicaps(a)
>> +#define SET_SPARC_MCDE(a)      set_sparc_pstate_mcde(a)
>> +#define ENABLE_SPARC_ADI(a, b) enable_sparc_adi(a, b)
>> +#define DISABLE_SPARC_ADI(a, b)        disable_sparc_adi(a, b)
>> +#define GET_SPARC_ADI_STATUS(a)        get_sparc_adi_status(a)
>> +#define ADI_CAPABLE()          adi_capable()
>
> Get rid of the ADI_CAPABLE macro, the usual pattern here is to define
> a static inline function for the entire API when the symbol is
> disabled, i.e.
>
> #ifdef CONFIG_SPARC_ADI
> ...
> extern bool adi_capable(void);
> #else
> ...
> static inline bool adi_capable(void) {
>      return false;
> }
> #endif
>
> That way you get type checking on the arguments even if the option is
> disabled and modern compilers are smart enough to optimise all the
> no-op code away. (Not that the type checking is needed here.)
>
> Also, in all but one place you use the ADI_CAPABLE() macro when the
> adi_capable() function is defined and available.

I defined ADI_CAPABLE() 0 for the case when CONFIG_SPARC_ADI is not set 
to help compiler optimize sun4v_mem_corrupt_detect_precise(). Since 
sun4v_mem_corrupt_detect_precise() is exception handler, optimizing it 
can be good for performance but perhaps compiler is smart enough to do 
that any way if adi_capable() is defined inline as you show above? I do 
like that doing it this way retains type checking.

>
>> +#else
>> +#define ADI_CAPABLE()          0
>> +#endif
>> +
>>   /* On Uniprocessor, even in RMO processes see TSO semantics */
>>   #ifdef CONFIG_SMP
>>   #define TSTATE_INITIAL_MM      TSTATE_TSO
>> diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
>> index 6f80936..79f981c 100644
>> --- a/arch/sparc/kernel/mdesc.c
>> +++ b/arch/sparc/kernel/mdesc.c
>> @@ -1007,6 +1013,80 @@ static int mdesc_open(struct inode *inode, struct file *file)
>>          return 0;
>>   }
>>
>> +bool adi_capable(void)
>> +{
>> +       return adi_state.enabled;
>> +}
>> +
>> +struct adi_caps *get_adi_caps(void)
>> +{
>> +       return &adi_state.caps;
>> +}
>> +
>> +void __init
>> +init_adi(void)
>> +{
>> +       struct mdesc_handle *hp = mdesc_grab();
>> +       const char *prop;
>> +       u64 pn, *val;
>> +       int len;
>> +
>> +       adi_state.enabled = false;
>> +
>> +       if (!hp)
>> +               return;
>> +
>> +       pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "cpu");
>> +       if (pn == MDESC_NODE_NULL)
>> +               goto out;
>> +
>> +       prop = mdesc_get_property(hp, pn, "hwcap-list", &len);
>> +       if (!prop)
>> +               goto out;
>> +
>> +       /*
>> +        * Look for "adp" keyword in hwcap-list which would indicate
>> +        * ADI support
>> +        */
>> +       while (len) {
>> +               int plen;
>> +
>> +               if (!strcmp(prop, "adp")) {
>> +                       adi_state.enabled = true;
>> +                       break;
>> +               }
>> +
>> +               plen = strlen(prop) + 1;
>> +               prop += plen;
>> +               len -= plen;
>> +       }
>> +
>> +       if (!adi_state.enabled)
>> +               goto out;
>> +
>> +       pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "platform");
>> +       if (pn == MDESC_NODE_NULL)
>> +               goto out;
>> +
>> +       val = (u64 *) mdesc_get_property(hp, pn, "adp-blksz", &len);
>> +       if (!val)
>> +               goto out;
>> +       adi_state.caps.blksz = *val;
>> +
>> +       val = (u64 *) mdesc_get_property(hp, pn, "adp-nbits", &len);
>> +       if (!val)
>> +               goto out;
>> +       adi_state.caps.nbits = *val;
>> +
>> +       val = (u64 *) mdesc_get_property(hp, pn, "ue-on-adp", &len);
>> +       if (!val)
>> +               goto out;
>> +       adi_state.caps.ue_on_adi = *val;
>> +
>> +out:
>> +       mdesc_release(hp);
>> +}
>> +
>
> Should all the ADI related functions above be within a #ifdef CONFIG_SPARC_ADI?
>

CONFIG_SPARC_ADI is selected for 64-bit kernels only since M7 is 64-bit 
only. init_adi() will do the right thing whether CONFIG_SPARC_ADI is 
enabled or not. It will parse machine description on 32-bit kernels, 
detect ADI is not supported by the platform and leave 
adi_state.enabled=false. I was considering adding something like 
/proc/sys/vm/sparc_adi_available at later point which would get its data 
from what init_adi() detects. On the other hand, since 32-bit processors 
do not support ADI, why have even this much code run on them. I can 
enclose this code as well inside #ifdef.

>>   static ssize_t mdesc_read(struct file *file, char __user *buf,
>>                            size_t len, loff_t *offp)
>>   {
>> diff --git a/arch/sparc/kernel/traps_64.c b/arch/sparc/kernel/traps_64.c
>> index d21cd62..29db583 100644
>> --- a/arch/sparc/kernel/traps_64.c
>> +++ b/arch/sparc/kernel/traps_64.c
>> @@ -2531,6 +2589,38 @@ void sun4v_do_mna(struct pt_regs *regs, unsigned long addr, unsigned long type_c
>>          force_sig_info(SIGBUS, &info, current);
>>   }
>>
>> +void sun4v_mem_corrupt_detect_precise(struct pt_regs *regs, unsigned long addr,
>> +                                     unsigned long context)
>> +{
>> +       siginfo_t info;
>> +
>> +       if (!ADI_CAPABLE()) {
>> +               bad_trap(regs, 0x1a);
>> +               return;
>> +       }
>> +
>> +       if (notify_die(DIE_TRAP, "memory corruption precise exception", regs,
>> +                      0, 0x8, SIGSEGV) == NOTIFY_STOP)
>> +               return;
>> +
>> +       if (regs->tstate & TSTATE_PRIV) {
>> +               pr_emerg("sun4v_mem_corrupt_detect_precise: ADDR[%016lx] "
>> +                       "CTX[%lx], going.\n", addr, context);
>> +               die_if_kernel("MCD precise", regs);
>> +       }
>> +
>> +       if (test_thread_flag(TIF_32BIT)) {
>> +               regs->tpc &= 0xffffffff;
>> +               regs->tnpc &= 0xffffffff;
>> +       }
>> +       info.si_signo = SIGSEGV;
>> +       info.si_code = SEGV_ADIPERR;
>> +       info.si_errno = 0;
>> +       info.si_addr = (void __user *) addr;
>> +       info.si_trapno = 0;
>> +       force_sig_info(SIGSEGV, &info, current);
>> +}
>> +
>
> Should this be ifdef'd too?

I would prefer to leave exception handlers in place any way unless there 
are strong objections.

>
>>   void do_privop(struct pt_regs *regs)
>>   {
>>          enum ctx_state prev_state = exception_enter();
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index 6af9212..fa7b5d9 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -103,6 +103,21 @@
>>   #ifndef SET_FP_MODE
>>   # define SET_FP_MODE(a,b)      (-EINVAL)
>>   #endif
>> +#ifndef GET_SPARC_ADICAPS
>> +# define GET_SPARC_ADICAPS(a)          (-EINVAL)
>> +#endif
>> +#ifndef SET_SPARC_MCDE
>> +# define SET_SPARC_MCDE(a)             (-EINVAL)
>> +#endif
>> +#ifndef ENABLE_SPARC_ADI
>> +# define ENABLE_SPARC_ADI(a, b)                (-EINVAL)
>> +#endif
>> +#ifndef DISABLE_SPARC_ADI
>> +# define DISABLE_SPARC_ADI(a, b)       (-EINVAL)
>> +#endif
>> +#ifndef GET_SPARC_ADI_STATUS
>> +# define GET_SPARC_ADI_STATUS(a)       (-EINVAL)
>> +#endif
>
> Ah, I was wondering why you were defining macros in processor_64.h.
>
>>   /*
>>    * this is where the system-wide overflow UID and GID are defined, for
>
> I've got a couple more comments, I'll send another email with them shortly.
>
> Thanks,
>

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
