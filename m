Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0B178D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 21:53:24 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B3CC03EE0C0
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 11:53:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D4EC45DE56
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 11:53:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74B9E45DE60
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 11:53:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6770BE08004
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 11:53:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15358E18006
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 11:53:09 +0900 (JST)
Date: Fri, 04 Mar 2011 11:52:50 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: Strange minor page fault repeats when SPECjbb2005 is executed
In-Reply-To: <4D6FC6C7.8060001@redhat.com>
References: <20110303200139.B187.E1E9C6FF@jp.fujitsu.com> <4D6FC6C7.8060001@redhat.com>
Message-Id: <20110304115250.E751.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki <kosaki.motohiro@jp.fujitsu.com>

Thank you for your response.

> On 03/03/2011 06:01 AM, Yasunori Goto wrote:
> 
> > In this log, cpu4 and 6 repeat page faults.
> > ----
> > handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067
> > handle_mm_fault jiffies64=4295160616 cpu=6 address=40003a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=551ef067
> > handle_mm_fault jiffies64=4295160616 cpu=6 address=40003a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=551ef067
> > handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067
> > handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067
> 
> > I confirmed this phenomenon is reproduced on 2.6.31 and 2.6.38-rc5
> > of x86 kernel, and I heard this phenomenon doesn't occur on
> > x86-64 kernel from another engineer who found this problem first.
> >
> > In addition, this phenomenon occurred on 4 boxes, so I think the cause
> > is not hardware malfunction.
> 
> On what CPU model(s) does this happen?

I'll attach cpuinfo in my current box which can reproduce this problem.
(1 socket, 4 cores, 8 logical cpus.)

And summary of other 3 boxes are here. (Unfortunately, I can't use them now.)

1) Intel(R) Xeon(R) CPU           X5680  @ 3.33GHz 
    2 socket,
    # of core -> 12
    # of logical cpus -> 24

2) Intel(R) Xeon(R) CPU           X7560  @ 2.27GHz
    2 socket
    # of coer -> 8
    # of logical cpus -> 16

3) Intel(R) Xeon(TM) CPU 3.80GHz
    1 socket
    # of core 1
    # of logical cpus -> 2

(The stop time was very short on 3rd box. It was about 5 seconds.
 But it was sometimes 1 hours on 1st box.)


> 
> Obviously the PTE is present and allows read, write and
> execute accesses, so the PTE should not cause any faults.
> 
> That leaves the TLB. It looks almost like the CPU keeps
> re-faulting on a (old?) TLB entry, possibly with wrong
> permissions, and does not re-load it from the PTE.
> 
> I know this "should not happen" on x86, but I cannot think
> of an alternative explanation right now.  Can you try flushing
> the TLB entry in question from handle_pte_fault?

I inserted __flush_tlb_one(address) between my debug print and calling 
handle_pte_fault(). But, this phenomenon is reproduced.

> 
> It looks like the code already does this for write faults, but
> maybe the garbage collection code uses PROT_NONE a lot and is
> running into this issue with a read or exec fault?
> 
> It would be good to print the fault flags as well in your debug
> print, so we know what kind of fault is being repeated...

I did it. The flags was 9 (FALUT_FLAG_ALLOW_RETRY and FAULT_FLAG_WRITE).

-----
handle_mm_fault jiffies64=4295117679 cpu=7 address=40001788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54cb1067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=2 address=40007788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54d3b067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=6 address=40000000 pmdval=0000000070845067 ptehigh=00000000 ptelow=54cb0067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=4 address=40002788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54d22067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=7 address=40001788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54cb1067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=2 address=40007788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54d3b067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=6 address=40000000 pmdval=0000000070845067 ptehigh=00000000 ptelow=54cb0067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=4 address=40002788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54d22067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=7 address=40001788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54cb1067 flags=9
handle_mm_fault jiffies64=4295117679 cpu=2 address=40007788 pmdval=0000000070845067 ptehigh=00000000 ptelow=54d3b067 flags=9
-----
These outputs repeated many times....


Thanks.

-----------
/proc/cpuinfo

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.20
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 2
initial apicid	: 2
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 9
cpu cores	: 4
apicid		: 18
initial apicid	: 18
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 10
cpu cores	: 4
apicid		: 20
initial apicid	: 20
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 4
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 1
initial apicid	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.16
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 5
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 3
initial apicid	: 3
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 6
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 9
cpu cores	: 4
apicid		: 19
initial apicid	: 19
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 7
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           E5640  @ 2.67GHz
stepping	: 1
cpu MHz		: 1596.000
cache size	: 12288 KB
physical id	: 0
siblings	: 8
core id		: 10
cpu cores	: 4
apicid		: 21
initial apicid	: 21
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt aes lahf_lm ida arat dts tpr_shadow vnmi flexpriority ept vpid
bogomips	: 5333.15
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
