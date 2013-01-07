Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C63E06B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 08:17:37 -0500 (EST)
Message-ID: <50EACAEF.8010004@fold.natur.cuni.cz>
Date: Mon, 07 Jan 2013 14:17:35 +0100
From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
MIME-Version: 1.0
Subject: Re: linux-3.7.1: OOPS in page_lock_anon_vma
References: <50EA01BC.2080001@fold.natur.cuni.cz> <CAJd=RBCqZj01PPzZnxfYtxJtst6nbpuFG8x2wDhmYk=4XrqCXw@mail.gmail.com>
In-Reply-To: <CAJd=RBCqZj01PPzZnxfYtxJtst6nbpuFG8x2wDhmYk=4XrqCXw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>

Hi Hilf,
   thank you for your answer on this albeit I am not sure I understood your point well.

Hillf Danton wrote:
> Hello Martin
> 
> On Mon, Jan 7, 2013 at 6:59 AM, Martin Mokrejs
> <mmokrejs@fold.natur.cuni.cz> wrote:
>> time to time. With ondemand governor I had cores in C7 for 50-70% of the time, that was
>> a bit better with performance governor but having the two hyperthreaded cores disabled
>> reduced the context switches by half, rescheduling interrupts went down by several orders
>> of magnitute. So it is crunching at max turbo speed on both cores, temp about 80 oC.
>>
> Your boxen could be used to cook pizza, and check the
> recommended working temperature in the manual please.

I meant CPU temperature, not environment temperature. ;-) This is a laptop dual core i7.


# dmesg | grep -i temp      
[    2.233856] coretemp coretemp.0: TjMax is 100 degrees C
[    2.233882] coretemp coretemp.0: TjMax is 100 degrees C
#


I am a bit worried whether I disabled the 2 hyperthreaded cores (cpu2 and cpu3).
Per the stats below it like inadverently disabled the second core and its hyperthreaded
sibling? Or why are the counters not updated for CPU1 below?

# cat /proc/interrupts 
           CPU0       CPU1       
  0:         30          0   IO-APIC-edge      timer
  1:         15          0   IO-APIC-edge      i8042
  8:         33          0   IO-APIC-edge      rtc0
  9:          2          0   IO-APIC-fasteoi   acpi
 12:        241          0   IO-APIC-edge      i8042
 16:         50          0   IO-APIC-fasteoi   ehci_hcd:usb1
 19:     464445          0   IO-APIC-fasteoi   sata_sil24
 23:      17324          0   IO-APIC-fasteoi   ehci_hcd:usb2
 40:          0          0   PCI-MSI-edge      pciehp
 41:         14          0   PCI-MSI-edge      mei
 42:     137666          0   PCI-MSI-edge      ahci
 43:      13901          0   PCI-MSI-edge      eth0
 44:      36022          0   PCI-MSI-edge      xhci_hcd
 45:          0          0   PCI-MSI-edge      xhci_hcd
 46:          0          0   PCI-MSI-edge      xhci_hcd
 47:          0          0   PCI-MSI-edge      xhci_hcd
 48:          0          0   PCI-MSI-edge      xhci_hcd
 49:        810          0   PCI-MSI-edge      snd_hda_intel
 50:          1          0   PCI-MSI-edge      iwlwifi
 51:        461          0   PCI-MSI-edge      i915
NMI:       6496       6111   Non-maskable interrupts
LOC:     526765     521983   Local timer interrupts
SPU:          0          0   Spurious interrupts
PMI:       6496       6111   Performance monitoring interrupts
IWI:          0          0   IRQ work interrupts
RTR:          2          0   APIC ICR read retries
RES:     197262     220079   Rescheduling interrupts
CAL:         33     299572   Function call interrupts
TLB:       3302      19119   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
MCE:          0          0   Machine check exceptions
MCP:         20         20   Machine check polls
ERR:          0
MIS:          0
#



i7z reports at the moment:


Cpu speed from cpuinfo 2793.00Mhz
cpuinfo might be wrong if cpufreq is enabled. To guess correctly try estimating via tsc
Linux's inbuilt cpu_khz code emulated now
True Frequency (without accounting Turbo) 2793 MHz
  CPU Multiplier 28x || Bus clock frequency (BCLK) 99.75 MHz

Socket [0] - [physical cores=2, logical cores=2, max online cores ever=2]
  TURBO ENABLED on 2 Cores, Hyper Threading OFF
  Max Frequency without considering Turbo 2892.75 MHz (99.75 x [29])
  Max TURBO Multiplier (if Enabled) with 1/2/3/4 Cores is  35x/33x/33x/33x
  Real Current Frequency 3291.75 MHz [99.75 x 33.00] (Max of below)
        Core [core-id]  :Actual Freq (Mult.)      C0%   Halt(C1)%  C3 %   C6 %   C7 %  Temp
        Core 1 [0]:       3291.75 (33.00x)       100       0       0       0       0    87
        Core 2 [1]:       3291.75 (33.00x)       100       0       0       0       0    81


# cat /proc/schedstat 
version 15
timestamp 4295525245
cpu0 0 0 4348066 350860 2727228 2499580 4026361745866 2434254688153 3965236
domain0 3 25687 19018 2642 7492049 4293 7 0 19018 22219 21471 43 1338108 709 0 0 21471 342087 288140 40648 58479699 14067 33 5 288135 0 0 0 0 0 0 0 0 0 223256 24270 0
cpu1 0 0 4297136 324961 2565709 2361951 3810969849763 2437183692947 3941014
domain0 3 24296 17512 2837 7768706 4218 15 1 17511 22994 22053 48 1636623 896 0 0 22053 313125 260913 38828 58232101 14403 37 2 260911 0 0 0 0 0 0 0 0 0 198332 23230 0
# cat /proc/sched_debug 
Sched Debug Version: v0.10, 3.7.1-default #24
ktime                                   : 5888049.840626
sched_clk                               : 5878999.320221
cpu_clk                                 : 5878999.320272
jiffies                                 : 4295526100
sched_clock_stable                      : 1

sysctl_sched
  .sysctl_sched_latency                    : 12.000000
  .sysctl_sched_min_granularity            : 1.500000
  .sysctl_sched_wakeup_granularity         : 2.000000
  .sysctl_sched_child_runs_first           : 1
  .sysctl_sched_features                   : 12091
  .sysctl_sched_tunable_scaling            : 1 (logaritmic)

cpu#0, 2793.732 MHz
  .nr_running                    : 3
  .load                          : 3072
  .nr_switches                   : 4323568
  .nr_load_updates               : 562036
  .nr_uninterruptible            : -84
  .next_balance                  : 4295.526102
  .curr->pid                     : 28277
  .clock                         : 5878998.371153
  .cpu_load[0]                   : 3072
  .cpu_load[1]                   : 2307
  .cpu_load[2]                   : 2310
  .cpu_load[3]                   : 2504
  .cpu_load[4]                   : 2655
  .yld_count                     : 0
  .sched_count                   : 4356498
  .sched_goidle                  : 350860
  .avg_idle                      : 510885
  .ttwu_count                    : 2733994
  .ttwu_local                    : 2506071

cfs_rq[0]:
  .exec_clock                    : 4034453.882147
  .MIN_vruntime                  : 2945931.837439
  .min_vruntime                  : 2945931.837439
  .max_vruntime                  : 2945931.846807
  .spread                        : 0.009368
  .spread0                       : 0.000000
  .nr_spread_over                : 11
  .nr_running                    : 3
  .load                          : 3072

rt_rq[0]:
  .rt_nr_running                 : 0
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
            bash 26153   2945931.846807       503   120   2945931.846807        67.290946   3357952.534597
         cc1plus 28242   2945931.837439       174   120   2945931.837439      1007.286114         0.007842
R            cat 28277   2945925.837439         1   120   2945925.837439         0.060401         0.041591

cpu#1, 2793.732 MHz
  .nr_running                    : 3
  .load                          : 3072
  .nr_switches                   : 4269177
  .nr_load_updates               : 552548
  .nr_uninterruptible            : 74
  .next_balance                  : 4295.526116
  .curr->pid                     : 28269
  .clock                         : 5878989.505170
  .cpu_load[0]                   : 3072
  .cpu_load[1]                   : 3008
  .cpu_load[2]                   : 2748
  .cpu_load[3]                   : 2472
  .cpu_load[4]                   : 2288
  .yld_count                     : 0
  .sched_count                   : 4301337
  .sched_goidle                  : 324961
  .avg_idle                      : 1000000
  .ttwu_count                    : 2567597
  .ttwu_local                    : 2363707

cfs_rq[1]:
  .exec_clock                    : 3819068.016461
  .MIN_vruntime                  : 2745747.270205
  .min_vruntime                  : 2745740.067182
  .max_vruntime                  : 2745750.033571
  .spread                        : 2.763366
  .spread0                       : -200191.770257
  .nr_spread_over                : 12
  .nr_running                    : 3
  .load                          : 3072

rt_rq[1]:
  .rt_nr_running                 : 0
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
         cc1plus 28263   2745747.270205        59   120   2745747.270205       385.172420         0.006728
R        cc1plus 28269   2745740.067182        35   120   2745740.067182       262.588883         0.000000
           water 28276   2745750.033571         5   120   2745750.033571        30.718348         0.008321

#


Do you think the crash OOPs is related to me baking the processor? That a business for the BIOS
and these kernel drivers, right?
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_LTC4215=m

CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y

CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y


CPU0: Intel(R) Core(TM) i7-2640M CPU @ 2.80GHz (fam: 06, model: 2a, stepping: 07)


IN enabled some debug options in "Kernel hacking" related to mutexes, locks etc. and so far am running fine.
And the SLUB debug, of course. ;-)
Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
