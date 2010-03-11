Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A005C6B0088
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 19:56:25 -0500 (EST)
Date: Thu, 11 Mar 2010 01:55:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 00/35] Transparent Hugepage support #13
Message-ID: <20100311005536.GA5677@random.random>
References: <20100309193901.207868642@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309193901.207868642@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Hello,

I run a very basic benchmark to confirm this is a significant
improvement for KVM.

qemu-kvm requires this patch to ensure the (gfn & pfn) &
(hpage_size-1) is zero (or hugepages cannot be allocated).

---------
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

diff --git a/exec.c b/exec.c
index 9bcb4de..b5a44ad 100644
--- a/exec.c
+++ b/exec.c
@@ -2647,11 +2647,18 @@ ram_addr_t qemu_ram_alloc(ram_addr_t size)
                                 PROT_EXEC|PROT_READ|PROT_WRITE,
                                 MAP_SHARED | MAP_ANONYMOUS, -1, 0);
 #else
+#if TARGET_PAGE_BITS == TARGET_HPAGE_BITS
         new_block->host = qemu_vmalloc(size);
+#else
+	new_block->host = qemu_memalign(1 << TARGET_HPAGE_BITS, size);
+#endif
 #endif
 #ifdef MADV_MERGEABLE
         madvise(new_block->host, size, MADV_MERGEABLE);
 #endif
+#ifdef MADV_HUGEPAGE
+        madvise(new_block->host, size, MADV_HUGEPAGE);
+#endif
     }
     new_block->offset = last_ram_offset;
     new_block->length = size;
diff --git a/target-i386/cpu.h b/target-i386/cpu.h
index b64bd02..664655d 100644
--- a/target-i386/cpu.h
+++ b/target-i386/cpu.h
@@ -891,6 +891,7 @@ uint64_t cpu_get_tsc(CPUX86State *env);
 #define X86_DUMP_CCOP 0x0002 /* dump qemu flag cache */
 
 #define TARGET_PAGE_BITS 12
+#define TARGET_HPAGE_BITS (TARGET_PAGE_BITS+9)
 
 #define cpu_init cpu_x86_init
 #define cpu_exec cpu_x86_exec
---------

I also did a one liner change to kvm patch to use PageTransCompound
instead of PageHead (the former also is compiled away for 32bit kvm
builds).

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -470,6 +470,15 @@ static int host_mapping_level(struct kvm
 
 	page_size = kvm_host_page_size(kvm, gfn);
 
+	/* check for transparent hugepages */
+	if (page_size == PAGE_SIZE) {
+		struct page *page = gfn_to_page(kvm, gfn);
+
+		if (!is_error_page(page) && PageTransCompound(page))
+			page_size = KVM_HPAGE_SIZE(2);
+		kvm_release_page_clean(page);
+	}
+
 	for (i = PT_PAGE_TABLE_LEVEL;
 	     i < (PT_PAGE_TABLE_LEVEL + KVM_NR_PAGE_SIZES); ++i) {
 		if (page_size >= KVM_HPAGE_SIZE(i))



This is a kernel build in a 2.6.31 guest, on a 2.6.34-rc1 host. KVM
run with "-drive cache=on,if=virtio,boot=on and -smp 4 -m 2g -vnc :0"
(host has 4G of ram). CPU is Phenom (not II) with NPT (4 cores, 1
die). All reads are provided from host cache and cpu overhead of the
I/O is reduced thanks to virtio. Workload is just a "make clean
>/dev/null; time make -j20 >/dev/null". Results copied by hand because
I logged through vnc.

real 4m12.498s
14m28.106s
1m26.721s

real 4m12.000s
14m27.850s
1m25.729s

After the benchmark:

grep Anon /proc/meminfo 
AnonPages:        121300 kB
AnonHugePages:   1007616 kB
cat /debugfs/kvm/largepages 
2296

1.6G free in guest and 1.5free in host.

Then on host:

# echo never > /sys//kernel/mm/transparent_hugepage/enabled 
# echo never > /sys/kernel/mm/transparent_hugepage/khugepaged/enabled 

then I restart the VM and re-run the same workload:

real 4m25.040s
user 15m4.665s
sys 1m50.519s

real 4m29.653s
user 15m8.637s
sys 1m49.631s

(guest kernel was not so recent and it had no transparent hugepage
support because gcc normally won't take advantage of hugepages
according to /proc/meminfo, so I made the comparison with a distro
guest kernel with my usual .config I use in kvm guests)

So guest compile the kernel 6% faster with hugepages and the results
are trivially reproducible and stable enough (especially with hugepage
enabled, without it varies from 4m24 sto 4m30s as I tried a few times
more without hugepages in NTP when userland wasn't patched yet...).

Below another test that takes advantage of hugepage in guest too, so
running the same 2.6.34-rc1 with transparent hugepage support in both
host and guest. (this really shows the power of KVM design, we boost
the hypervisor and we get double boost for guest applications)

Workload: time dd if=/dev/zero of=/dev/null bs=128M count=100

Host hugepage no guest: 3.898
Host hugepage guest hugepage: 3.966 (-1.17%)
Host no hugepage no guest: 4.088 (-4.87%)
Host hugepage guest no hugepage: 4.312 (-10.1%)
Host no hugepage guest hugepage: 4.388 (-12.5%)
Host no hugepage guest no hugepage: 4.425 (-13.5%)

Workload: time dd if=/dev/zero of=/dev/null bs=4M count=1000

Host hugepage no guest: 1.207
Host hugepage guest hugepage: 1.245 (-3.14%)
Host no hugepage no guest: 1.261 (-4.47%)
Host no hugepage guest no hugepage: 1.323 (-9.61%)
Host no hugepage guest hugepage: 1.371 (-13.5%)
Host no hugepage guest no hugepage: 1.398 (-15.8%)

I've no local EPT system to test so I may run them over vpn later on
some large EPT system (and surely there are better benchs than a silly
dd... but this is a start and shows even basic stuff gets the boost).

The above is basically an "home-workstation/laptop" coverage. I
(partly) intentionally run these on a system that has a ~$100 CPU and
~$50 motherboard, to show the absolute worst case, to be sure that
100% of home end users (running KVM) will take a measurable advantage
from this effort.

On huge systems the percentage boost is expected much bigger than on
the home-workstation above test of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
