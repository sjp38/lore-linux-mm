Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2B136B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 04:33:25 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o2so2756737wmf.2
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:33:25 -0800 (PST)
Received: from proxmox-new.maurer-it.com (proxmox.maurer-it.com. [212.186.127.180])
        by mx.google.com with ESMTPS id y204si2833719wme.125.2017.11.30.01.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Nov 2017 01:33:23 -0800 (PST)
Date: Thu, 30 Nov 2017 10:33:20 +0100
From: Fabian =?iso-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>
Subject: BSOD with [PATCH 00/13] mmu_notifier kill invalidate_page callback
Message-ID: <20171130093320.66cxaoj45g2ttzoh@nora.maurer-it.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, kvm@vger.kernel.org

On Tue, Aug 29, 2017 at 07:54:34PM -0400, Jerome Glisse wrote:
> (Sorry for so many list cross-posting and big cc)

Ditto (trimmed it a bit already, feel free to limit replies as you see
fit).

> 
> Please help testing !
> 

Kernels 4.13 and 4.14 (which both contain these patch series in its
final form) are affected by a bug triggering BSOD
(CRITICAL_STRUCTURE_CORRUPTION) in Windows 10/2016 VMs in Qemu under
certain conditions on certain hardware/microcode versions (see below for
details).

Testing this proved to be quite cumbersome, as only some systems are
affected and it took a while to find a semi-reliable test setup. Some
users reported that microcode updates made the problem disappear on some
affected systems[1].

Bisecting the 4.13 release cycle first pointed to

aac2fea94f7a3df8ad1eeb477eb2643f81fd5393 rmap: do not call mmu_notifier_invalidate_page() under ptl

as likely culprit (although it was not possible to bisect exactly down
to this commit).

It was reverted in 785373b4c38719f4af6775845df6be1dfaea120f after which
the symptoms disappeared until this series was merged, which contains

369ea8242c0fb5239b4ddf0dc568f694bd244de4 mm/rmap: update to new mmu_notifier semantic v2

We haven't bisected the individual commits of the series yet, but the
commit immediately preceding its merge exhibits no problems, while
everything after does. It is not known whether the bug is actually in
the series itself, or whether increasing the likelihood of triggering it
is just a side-effect. There is a similar report[2] concerning an
upgrade from 4.12.12 to 4.12.13, which does not contain this series in
any form AFAICT but might be worth another look as well.

Our test setup consists of the following:
CPU: Intel(R) Xeon(R) CPU D-1528 @ 1.90GHz (single socket)
Flags: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat
pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx
est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic
movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm
3dnowprefetch cpuid_fault epb cat_l3 cdp_l3 intel_ppin intel_pt
tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2
smep bmi2 erms invpcid rtm cqm rdt_a rdseed adx smap xsaveopt cqm_llc
cqm_occup_llc cqm_mbm_total cqm_mbm_local dtherm arat pln pts
microcode: 0x700000e
Mainboard: Supermicro X10SDV-6C+-TLN4F
RAM: 64G DDR4 [3]
Swap: 8G on an LV
Qemu: 2.9.1 with some patches on top ([4])
OS: Debian Stretch based (PVE 5.1)
KSM is enabled, but turning it off just increases the number of test
iterations needed to trigger the bug.
Kernel config: [5]

VMs:
A: Windows 2016 with virtio-blk disks, 6G RAM
B: Windows 10 with (virtual) IDE disks, 6G RAM
C: Debian Stretch, ~55G RAM

fio config:
[global]
thread=2
runtime=1800

[write1]
ioengine=windowsaio
sync=0
direct=0
bs=4k
size=30G
rw=randwrite
iodepth=16

[read1]
ioengine=windowsaio
sync=0
direct=0
bs=4k
size=30G
rw=randread
iodepth=16

Test run:

- Start all three VMs
- run 'stress-ng --vm-bytes 1G --vm 52 -t 6000' in VM C
- wait until swap is (almost) full and KSM starts to merge pages
- start fio in VM A and B
- stop stress-ng in VM C, power off VM C
- run 'swapoff -av' on host
- wait until swap content has been swapped in again (this takes a while)
- observe BSOD in at least one of A / B around 30% of the time

While this test case is pretty artifical, the BSOD issue does affect
users in the wild running regular work loads (where it can take from
multiple hours up to several days to trigger).

We have reverted this patch series in our 4.13 based kernel for now,
with positive feedback from users and our own testing. If more detailed
traces or data from a test run on an affected system is needed, we will
of course provide it.

Any further input / pointers are highly appreciated!

1: https://forum.proxmox.com/threads/blue-screen-with-5-1.37664/
2: http://www.spinics.net/lists/kvm/msg159179.html
https://bugs.launchpad.net/qemu/+bug/1728256
https://bugzilla.kernel.org/show_bug.cgi?id=197951
3: http://www.samsung.com/semiconductor/products/dram/server-dram/ddr4-registered-dimm/M393A2K40BB1?ia=2503
5: https://git.proxmox.com/?p=pve-qemu.git;a=tree;f=debian/patches;h=2c516be8e69a033d14809b17e8a661b3808257f7;hb=8d4a2d3f5569817221c19a91f763964c40e00292
6: https://gist.github.com/Fabian-Gruenbichler/5c3af22ac7e6faae46840bdcebd7df14

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
