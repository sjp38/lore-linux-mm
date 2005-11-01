Received: by zproxy.gmail.com with SMTP id k1so629860nzf
        for <linux-mm@kvack.org>; Tue, 01 Nov 2005 12:07:54 -0800 (PST)
Message-ID: <4367CB17.6050200@gmail.com>
Date: Tue, 01 Nov 2005 13:07:51 -0700
From: Jim Cromie <jim.cromie@gmail.com>
MIME-Version: 1.0
Subject: X86_CONFIG overrides X86_L1_CACHE_SHIFT default for each CPU model.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

folks,

in arch/i386/Kconfig, it seems (to me) that X86_GENERIC has undue influence
on X86_L1_CACHE_SHIFT;

config X86_L1_CACHE_SHIFT
      int
      default "7" if MPENTIUM4 || X86_GENERIC
      default "4" if X86_ELAN || M486 || M386
      default "5" if MWINCHIP3D || MWINCHIP2 || MWINCHIPC6 || MCRUSOE || 
MEFFICEON || MCYRIXIII || MK6 || MPENTIUMIII || MPENTIUMII || M686 || 
M586MMX || M586TSC || M586 || MVIAC3_2 || MGEODEGX1
      default "6" if MK7 || MK8 || MPENTIUMM

that is, when X86_GENERIC == true --> default = 7,
ignoring the platform choice *made* by the user-builder.
On my geode box, it would be 5 wo GENERIC.

so I built 2 kernels, and ran lmbench on both.
Results were somewhat inconclusive to me, but the non-generic is 
distinctly faster
in some of the lmbench results:


< [lmbench3.0 results for Linux soekris 2.6.13-ski2-cache-v1 #3 Fri Sep 
23 13:14:30 MDT 2005 i586 GNU/Linux]
---
 > [lmbench3.0 results for Linux soekris 2.6.13-ski2-v1 #1 Fri Sep 23 
13:24:45 MDT 2005 i586 GNU/Linux]

RX bytes:2844 (2.7 KiB)  TX bytes:2844 (2.7 KiB)]
86,107c86,107
< Simple syscall: 1.6462 microseconds
< Simple read: 5.3041 microseconds
< Simple write: 4.6366 microseconds
< Simple stat: 223.7200 microseconds
< Simple fstat: 8.6939 microseconds
< Simple open/close: 2535.0000 microseconds
< Select on 10 fd's: 13.8254 microseconds
< Select on 100 fd's: 110.5490 microseconds
< Select on 250 fd's: 231.7619 microseconds
< Select on 500 fd's: 550.9000 microseconds
< Select on 10 tcp fd's: 15.3956 microseconds
< Select on 100 tcp fd's: 145.9211 microseconds
< Select on 250 tcp fd's: 371.5714 microseconds
< Select on 500 tcp fd's: 746.0000 microseconds
< Signal handler installation: 9.3942 microseconds
< Signal handler overhead: 35.6667 microseconds
< Protection fault: 1.9708 microseconds
< Pipe latency: 129.5962 microseconds
< AF_UNIX sock stream latency: 267.0952 microseconds
< Process fork+exit: 3620.0000 microseconds
< Process fork+execve: 16960.0000 microseconds
< Process fork+/bin/sh -c: 61487.0000 microseconds
---
 > Simple syscall: 1.8362 microseconds
 > Simple read: 8.4718 microseconds
 > Simple write: 7.2812 microseconds
 > Simple stat: 210.5769 microseconds
 > Simple fstat: 10.1660 microseconds
 > Simple open/close: 2549.3333 microseconds
 > Select on 10 fd's: 13.8471 microseconds
 > Select on 100 fd's: 111.6400 microseconds
 > Select on 250 fd's: 232.0000 microseconds
 > Select on 500 fd's: 551.7000 microseconds
 > Select on 10 tcp fd's: 14.3761 microseconds
 > Select on 100 tcp fd's: 149.2162 microseconds
 > Select on 250 tcp fd's: 370.3571 microseconds
 > Select on 500 tcp fd's: 722.3750 microseconds
 > Signal handler installation: 9.8043 microseconds
 > Signal handler overhead: 34.1729 microseconds
 > Protection fault: 6.8015 microseconds
 > Pipe latency: 132.9220 microseconds
 > AF_UNIX sock stream latency: 272.5789 microseconds
 > Process fork+exit: 3501.0000 microseconds
 > Process fork+execve: 16546.0000 microseconds
 > Process fork+/bin/sh -c: 54099.0000 microseconds


Ill spare you my half-baked theories about the cause of these results,
in the hopes that the following patch 'correct-by-inspection', or that 
somebody
is willing to clarify the purposes of X86_GENERIC.

An 'incorrect' guess at cache-line-size doesnt break the kernel;
is the number used to optimize the cache operation in a way
thats consistent with the above results ?

Interestingly, the biggest relative diff is in Protection fault.
This is more closely MM related than the other measures,
suggesting that cache-line-size is the reason.


tia
jimc.

The patch will apparently wrap, but this is my 1st send here,
and Im avoiding the MIME attach that thunderbird does.
I can resend with a script, but it cant do the proper SSL auth to
send via gmail, so it must send direct to kvack.org, and will probly 
look like spam. 

Signed-by:  Jim Cromie <jim.cromie@gmail.com>


[jimc@harpo generic]$ more cache-shift-default-under-x86_generic.patch
--- linux-2.6.13-ipipe-sk/arch/i386/Kconfig     2005-09-13 
15:46:55.000000000 -0600
+++ linux-2.6.13-ipipe4-sk/arch/i386/Kconfig    2005-09-23 
11:04:16.000000000 -0600
@@ -363,10 +363,10 @@

 config X86_L1_CACHE_SHIFT
        int
-       default "7" if MPENTIUM4 || X86_GENERIC
        default "4" if X86_ELAN || M486 || M386
        default "5" if MWINCHIP3D || MWINCHIP2 || MWINCHIPC6 || MCRUSOE 
|| MEFFICEON || MCYRIXIII || MK6 || MPENTIUMIII || MPENTIUMII || M686 || 
M586MMX || M586TSC || M586 || MVIAC3_2 || MGEODEGX1
        default "6" if MK7 || MK8 || MPENTIUMM
+       default "7" if MPENTIUM4 || X86_GENERIC

 config RWSEM_GENERIC_SPINLOCK
        bool


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
