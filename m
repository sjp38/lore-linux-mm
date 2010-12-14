Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEC16B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:01:59 -0500 (EST)
Message-ID: <4D0786D3.7070007@akana.de>
Date: Tue, 14 Dec 2010 16:01:39 +0100
From: Ingo Korb <ingo@akana.de>
MIME-Version: 1.0
Subject: PROBLEM: __offline_isolated_pages may offline too many pages
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, cl@linux-foundation.org, yinghai@kernel.org, andi.kleen@intel.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!

[1.] One line summary of the problem:
__offline_isolated_pages may isolate too many pages

[2.] Full description of the problem/report:
While experimenting with remove_memory/online_pages, removing as few 
pages as possible (pageblock_nr_pages, 512 on my box) I noticed that the 
number of pages marked "reserved" increased even though both functions 
did not indicate an error. Following the code it was clear that 
__offline_isolated_pages marked twice as many pages as it should:

=== start paste (from dmesg) ===
Offlined Pages 512
remove from free list c00 1024 e00
=== end paste ===

The issue seems to be that __offline_isolated_pages blindly uses 
page_order() to determine how many pages it should mark as reserved in 
the current loop iteration, without checking if this would exceed the 
limit set by end_pfn.

I'm not sure what the correct way to fix this would be - is memory 
isolation supposed to touch the order of a page if it crosses the end 
(or beginning!) of the range of pages to be isolated?

[3.] Keywords (i.e., modules, networking, kernel):
kernel mm memory-hotplug

[4.] Kernel information
[4.1.] Kernel version (from /proc/version):
Linux version 2.6.35-00002-g76c52bb (ingo@memtester) (gcc version 4.4.5 
(Debian 4.4.5-6) ) #7 SMP Tue Dec 14 14:28:17 CET 2010

The diff between vanilla 2.6.35 and this version is available at 
http://akana.de/memtest35.diff - the only changes are a reduced timeout 
in remove_memory and a bunch of additional exported symbols.

[4.2.] Kernel .config file:
http://akana.de/config-memtest35

[5.] Most recent kernel version which did not have the bug:
Probably none

[8.] Environment
[8.1.] Software (add the output of the ver_linux script here)
Linux memtester 2.6.35-00002-g76c52bb #7 SMP Tue Dec 14 14:28:17 CET 
2010 x86_64 GNU/Linux

Gnu C                  4.4.5
Gnu make               3.81
binutils               2.20.1
util-linux             (no fdformat on the system)
mount                  support
module-init-tools      found
Linux C Library        2.11.2
Dynamic linker (ldd)   2.11.2
Procps                 3.2.8
Kbd                    1.15.2
Sh-utils               8.5
Modules Loaded         phys_mem ipv6 pcspkr i2c_piix4 i2c_core shpchp e1000

Distribution is Debian testing if it matters

[8.2.] Processor information (from /proc/cpuinfo):
AMD Phenom 9650, but the system is running inside a VMWare Player 
instance with just a single virtual CPU

[8.3.] Module information (from /proc/modules):
phys_mem 15068 0 - Live 0xffffffffa00d1000
ipv6 340746 24 - Live 0xffffffffa0068000
pcspkr 2022 0 - Live 0xffffffffa0062000
i2c_piix4 13334 0 - Live 0xffffffffa0059000
i2c_core 28244 1 i2c_piix4, Live 0xffffffffa004b000
shpchp 35612 0 - Live 0xffffffffa003b000
e1000 164575 0 - Live 0xffffffffa0000000

[8.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
[8.5.] PCI information ('lspci -vvv' as root)
[8.6.] SCSI information (from /proc/scsi/scsi)
As far as I can tell irrelevant to this problem?
(forgot to copy those, will add later if neccessary)

-ik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
