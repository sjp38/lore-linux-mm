Message-ID: <4790C9D4.4040705@sgi.com>
Date: Fri, 18 Jan 2008 07:46:28 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] percpu: Change Kconfig ARCH_SETS_UP_PER_CPU_AREA
 to HAVE_SETUP_PER_CPU_AREA
References: <20080117223505.203884000@sgi.com> <20080117223505.513183000@sgi.com> <20080118051118.GA14882@uranus.ravnborg.org>
In-Reply-To: <20080118051118.GA14882@uranus.ravnborg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Sam Ravnborg wrote:
> Hi Mike.
> 
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -20,6 +20,7 @@ config X86
>>  	def_bool y
>>  	select HAVE_OPROFILE
>>  	select HAVE_KPROBES
>> +	select HAVE_SETUP_PER_CPU_AREA if ARCH = "x86_64"
> 
> It is simpler to just say:
>> +	select HAVE_SETUP_PER_CPU_AREA if X86_64
> 
> And this is the way we do it in the rest of the
> x86 Kconfig files.
> 
> 	Sam


I'm trying to trigger an increase in NR_CPUS if SMP_MAX
is set.  But it doesn't seem to "take".  Of the changes
below only NODES_SHIFT is changed.  Is there something else
I need to change?

Thanks,
Mike


--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -487,19 +487,29 @@ config ARCH_SUPPORTS_KVM


 config NR_CPUS
-       int "Maximum number of CPUs (2-255)"
-       range 2 255
+       int "Maximum number of CPUs (2-4096)"
+       range 2 4096
        depends on SMP
+       default "1024" if X86_SMP_MAX
        default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
        default "8"
        help
          This allows you to specify the maximum number of CPUs which this
-         kernel will support.  The maximum supported value is 255 and the
+         kernel will support.  The maximum supported value is 4096 and the
          minimum value which makes sense is 2.

          This is purely to save memory - each supported CPU adds
          approximately eight kilobytes to the kernel image.

+config THREAD_ORDER
+       int "Kernel stack size (in page order)"
+       range 1 3
+       depends on X86_64_SMP
+       default "3" if X86_SMP_MAX
+       default "1"
+       help
+         Increases kernel stack size.
+
 config SCHED_SMT
        bool "SMT (Hyperthreading) scheduler support"
        depends on (X86_64 && SMP) || (X86_32 && X86_HT)
@@ -882,6 +892,7 @@ config NUMA_EMU

 config NODES_SHIFT
        int
+       default "9" if X86_SMP_MAX
        default "6" if X86_64
        default "4" if X86_NUMAQ
        default "3"
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -73,6 +73,16 @@ config X86_FIND_SMP_CONFIG
        depends on X86_LOCAL_APIC || X86_VOYAGER
        depends on X86_32

+config X86_SMP_MAX
+       bool "Enable Maximum SMP configuration"
+       def_bool n
+       depends on X86_64_SMP
+       help
+         Say Y here to enable a "large" SMP configuration for testing
+         purposes.  It does this by increasing the number of possible
+         cpus to the NR_CPUS count.  It also triggers an increase in
+         NR_CPUS, NODES_SHIFT and THREAD_ORDER.
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
