Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 8B64F6B0062
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 15:36:55 -0500 (EST)
Date: Tue, 15 Jan 2013 07:36:34 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301142036.r0EKaYGN005907@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <50F41D9D.1000403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Dave,

>> Seems that any i386 PAE machine will go OOM just by running a few
>> processes. To reproduce:
>>   sh -c 'n=0; while [ $n -lt 19999 ]; do sleep 600 & ((n=n+1)); done'
>> ...
> I think what you're seeing here is that, as the amount of total memory
> increases, the amount of lowmem available _decreases_ due to inflation
> of mem_map[] (and a few other more minor things).  The number of sleeps
> you can do is bound by the number of processes, as you noticed from
> ulimit.  Creating processes that don't use much memory eats a relatively
> large amount of low memory.
> This is a sad (and counterintuitive) fact: more RAM actually *CREATES*
> RAM bottlenecks on 32-bit systems.

I understand that more RAM leaves less lowmem. What is unacceptable is
that PAE crashes or freezes with OOM: it should gracefully handle the
issue. Noting that (for a machine with 4GB or under) PAE fails where the
HIGHMEM4G kernel succeeds and survives.

>> On my large machine, 'free' fails to show about 2GB memory ...
> You probably have a memory hole. ...
> The e820 map (during early boot in dmesg) or /proc/iomem will let you
> locate your memory holes.

Thanks, that might explain it. Output of /proc/iomem below: sorry I do
not know how to interpret it.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia


---
root@zeno:~# cat /proc/iomem
00000000-0000ffff : reserved
00010000-00099bff : System RAM
00099c00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
  000a0000-000bffff : Video RAM area
000c0000-000dffff : PCI Bus 0000:00
  000c0000-000c7fff : Video ROM
  000c8000-000cf5ff : Adapter ROM
  000cf800-000d07ff : Adapter ROM
  000d0800-000d0bff : Adapter ROM
000e0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-7e445fff : System RAM
  01000000-01610e15 : Kernel code
  01610e16-01802dff : Kernel data
  01880000-018b2fff : Kernel bss
7e446000-7e565fff : ACPI Non-volatile Storage
7e566000-7f1e2fff : reserved
7f1e3000-7f25efff : ACPI Tables
7f25f000-7f31cfff : reserved
7f31d000-7f323fff : ACPI Non-volatile Storage
7f324000-7f333fff : reserved
7f334000-7f33bfff : ACPI Non-volatile Storage
7f33c000-7f365fff : reserved
7f366000-7f7fffff : ACPI Non-volatile Storage
7f800000-7fffffff : RAM buffer
80000000-dfffffff : PCI Bus 0000:00
  80000000-8fffffff : PCI MMCONFIG 0000 [bus 00-ff]
    80000000-8fffffff : reserved
  90000000-9000000f : 0000:00:16.0
  90000010-9000001f : 0000:00:16.1
  dd000000-ddffffff : PCI Bus 0000:08
    dd000000-ddffffff : 0000:08:03.0
  de000000-de4fffff : PCI Bus 0000:07
    de000000-de3fffff : 0000:07:00.0
    de47c000-de47ffff : 0000:07:00.0
  de600000-de6fffff : PCI Bus 0000:02
  df000000-df8fffff : PCI Bus 0000:08
    df000000-df7fffff : 0000:08:03.0
    df800000-df803fff : 0000:08:03.0
  df900000-df9fffff : PCI Bus 0000:07
  dfa00000-dfafffff : PCI Bus 0000:02
    dfa00000-dfa1ffff : 0000:02:00.1
      dfa00000-dfa1ffff : igb
    dfa20000-dfa3ffff : 0000:02:00.0
      dfa20000-dfa3ffff : igb
    dfa40000-dfa43fff : 0000:02:00.1
      dfa40000-dfa43fff : igb
    dfa44000-dfa47fff : 0000:02:00.0
      dfa44000-dfa47fff : igb
  dfb00000-dfb03fff : 0000:00:04.7
  dfb04000-dfb07fff : 0000:00:04.6
  dfb08000-dfb0bfff : 0000:00:04.5
  dfb0c000-dfb0ffff : 0000:00:04.4
  dfb10000-dfb13fff : 0000:00:04.3
  dfb14000-dfb17fff : 0000:00:04.2
  dfb18000-dfb1bfff : 0000:00:04.1
  dfb1c000-dfb1ffff : 0000:00:04.0
  dfb20000-dfb200ff : 0000:00:1f.3
  dfb21000-dfb217ff : 0000:00:1f.2
    dfb21000-dfb217ff : ahci
  dfb22000-dfb223ff : 0000:00:1d.0
    dfb22000-dfb223ff : ehci_hcd
  dfb23000-dfb233ff : 0000:00:1a.0
    dfb23000-dfb233ff : ehci_hcd
  dfb25000-dfb25fff : 0000:00:05.4
  dfffc000-dfffdfff : pnp 00:02
e0000000-fbffffff : PCI Bus 0000:80
  fbe00000-fbefffff : PCI Bus 0000:84
    fbe00000-fbe3ffff : 0000:84:00.0
    fbe40000-fbe5ffff : 0000:84:00.0
    fbe60000-fbe63fff : 0000:84:00.0
  fbf00000-fbf03fff : 0000:80:04.7
  fbf04000-fbf07fff : 0000:80:04.6
  fbf08000-fbf0bfff : 0000:80:04.5
  fbf0c000-fbf0ffff : 0000:80:04.4
  fbf10000-fbf13fff : 0000:80:04.3
  fbf14000-fbf17fff : 0000:80:04.2
  fbf18000-fbf1bfff : 0000:80:04.1
  fbf1c000-fbf1ffff : 0000:80:04.0
  fbf20000-fbf20fff : 0000:80:05.4
  fbffe000-fbffffff : pnp 00:12
fc000000-fcffffff : pnp 00:01
fd000000-fdffffff : pnp 00:01
fe000000-feafffff : pnp 00:01
feb00000-febfffff : pnp 00:01
fec00000-fec003ff : IOAPIC 0
fec01000-fec013ff : IOAPIC 1
fec40000-fec403ff : IOAPIC 2
fed00000-fed003ff : HPET 0
fed08000-fed08fff : pnp 00:0c
fed1c000-fed3ffff : reserved
  fed1c000-fed1ffff : pnp 00:0c
fed45000-fedfffff : pnp 00:01
fee00000-fee00fff : Local APIC
ff000000-ffffffff : reserved
  ff000000-ffffffff : pnp 00:0c
100000000-107fffffff : System RAM
root@zeno:~# 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
