Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 896D36B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 07:56:22 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1571520bkw.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 04:56:20 -0700 (PDT)
Message-ID: <4F7D8860.3040008@openvz.org>
Date: Thu, 05 Apr 2012 15:56:16 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [x86 PAT PATCH 1/2] x86, pat: remove the dependency on 'vm_pgoff'
 in track/untrack pfn vma routines
References: <20120331170947.7773.46399.stgit@zurg>  <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>  <1333413969-30761-2-git-send-email-suresh.b.siddha@intel.com>  <4F7A8C94.3040708@openvz.org> <1333495881.12400.19.camel@sbsiddha-desk.sc.intel.com>
In-Reply-To: <1333495881.12400.19.camel@sbsiddha-desk.sc.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

Suresh Siddha wrote:
> On Tue, 2012-04-03 at 09:37 +0400, Konstantin Khlebnikov wrote:
>> Suresh Siddha wrote:
>>> 'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
>>> for the pfn range. No need to depend on 'vm_pgoff'
>>>
>>> Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
>>> is non-zero or can use follow_phys() to get the starting value of the pfn
>>> range.
>>>
>>> Also the non zero 'size' argument can be used instead of recomputing
>>> it from vma.
>>>
>>> This cleanup also prepares the ground for the track/untrack pfn vma routines
>>> to take over the ownership of setting PAT specific vm_flag in the 'vma'.
>>>
>>> Signed-off-by: Suresh Siddha<suresh.b.siddha@intel.com>
>>> Cc: Venkatesh Pallipadi<venki@google.com>
>>> Cc: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> ---
>>>    arch/x86/mm/pat.c |   30 +++++++++++++++++-------------
>>>    1 files changed, 17 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
>>> index f6ff57b..617f42b 100644
>>> --- a/arch/x86/mm/pat.c
>>> +++ b/arch/x86/mm/pat.c
>>> @@ -693,14 +693,10 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
>>>    			unsigned long pfn, unsigned long size)
>>>    {
>>>    	unsigned long flags;
>>> -	resource_size_t paddr;
>>> -	unsigned long vma_size = vma->vm_end - vma->vm_start;
>>>
>>> -	if (is_linear_pfn_mapping(vma)) {
>>> -		/* reserve the whole chunk starting from vm_pgoff */
>>> -		paddr = (resource_size_t)vma->vm_pgoff<<   PAGE_SHIFT;
>>> -		return reserve_pfn_range(paddr, vma_size, prot, 0);
>>> -	}
>>> +	/* reserve the whole chunk starting from pfn */
>>> +	if (is_linear_pfn_mapping(vma))
>>> +		return reserve_pfn_range(pfn, size, prot, 0);
>>
>> you mix here pfn and paddr: old code passes paddr as first argument of reserve_pfn_range().
>
> oops. That was my oversight. I updated the two patches to address this.
> Also I cleared VM_PAT flag as part of the untrack_pfn_vma(), so that the
> use cases (like the i915 case) which just evict the pfn's (by using
> unmap_mapping_range) with out actually removing the vma will do the
> free_pfn_range() only when it is required.
>
> Attached (to this e-mail) are the -v2 versions of the PAT patches. I
> tested these on my SNB laptop.

With this patches I see new ranges in /sys/kernel/debug/x86/pat_memtype_list
This is 4k single-page vma mappged by X11. kernel fills them via vm_insert_pfn().
Is this ok? Maybe we shouldn't use PAT for small VMA?

before patch
# wc ~/pat_memtype_list
52  156 1936 /root/pat_memtype_list

after patch
# wc /sys/kernel/debug/x86/pat_memtype_list
257 771 10136 /sys/kernel/debug/x86/pat_memtype_list

# diff -u  ~/pat_memtype_list /sys/kernel/debug/x86/pat_memtype_list
--- /root/pat_memtype_list	2012-03-31 14:22:30.439956357 +0400
+++ /sys/kernel/debug/x86/pat_memtype_list	2012-04-05 19:43:28.380983643 +0400
@@ -27,6 +27,201 @@
  write-combining @ 0xe0023000-0xe0043000
  write-combining @ 0xe0044000-0xe0064000
  write-combining @ 0xe0064000-0xe046c000
+write-combining @ 0xe0970000-0xe0971000
+write-combining @ 0xe097e000-0xe097f000
+write-combining @ 0xe0982000-0xe0983000
+write-combining @ 0xe0983000-0xe0984000
+write-combining @ 0xe0984000-0xe0985000
+write-combining @ 0xe0985000-0xe0986000
+write-combining @ 0xe0986000-0xe0987000
+write-combining @ 0xe0987000-0xe0988000
+write-combining @ 0xe0988000-0xe0989000
+write-combining @ 0xe0989000-0xe098a000
+write-combining @ 0xe098a000-0xe098b000
+write-combining @ 0xe098b000-0xe098c000
+write-combining @ 0xe098c000-0xe098d000
+write-combining @ 0xe098d000-0xe098e000
+write-combining @ 0xe098e000-0xe098f000
+write-combining @ 0xe098f000-0xe0990000
+write-combining @ 0xe0990000-0xe0991000
+write-combining @ 0xe0991000-0xe0992000
+write-combining @ 0xe0992000-0xe0993000
+write-combining @ 0xe0993000-0xe0994000
+write-combining @ 0xe0994000-0xe0995000
+write-combining @ 0xe0995000-0xe0996000
+write-combining @ 0xe0996000-0xe0997000
+write-combining @ 0xe0997000-0xe0998000
+write-combining @ 0xe0998000-0xe0999000
+write-combining @ 0xe0999000-0xe099a000
+write-combining @ 0xe099a000-0xe099b000
+write-combining @ 0xe099b000-0xe099c000
+write-combining @ 0xe099c000-0xe099d000
+write-combining @ 0xe099d000-0xe099e000
+write-combining @ 0xe099e000-0xe099f000
+write-combining @ 0xe099f000-0xe09a0000
+write-combining @ 0xe09a0000-0xe09a1000
+write-combining @ 0xe09a1000-0xe09a2000
+write-combining @ 0xe09a2000-0xe09a3000
+write-combining @ 0xe09a3000-0xe09a4000
+write-combining @ 0xe09a4000-0xe09a5000
+write-combining @ 0xe09a5000-0xe09a6000
+write-combining @ 0xe09a6000-0xe09a7000
+write-combining @ 0xe09a7000-0xe09a8000
+write-combining @ 0xe138a000-0xe138b000
+write-combining @ 0xe13f3000-0xe13f4000
+write-combining @ 0xe17f4000-0xe17f5000
+write-combining @ 0xe1804000-0xe1805000
+write-combining @ 0xe1805000-0xe1806000
+write-combining @ 0xe1806000-0xe1807000
+write-combining @ 0xe1807000-0xe1808000
+write-combining @ 0xe1808000-0xe1809000
+write-combining @ 0xe1809000-0xe180a000
+write-combining @ 0xe180c000-0xe180d000
+write-combining @ 0xe180d000-0xe180e000
+write-combining @ 0xe180f000-0xe1810000
+write-combining @ 0xe181a000-0xe181b000
+write-combining @ 0xe181b000-0xe181c000
+write-combining @ 0xe181c000-0xe181d000
+write-combining @ 0xe1d51000-0xe1d52000
+write-combining @ 0xe1d52000-0xe1d53000
+write-combining @ 0xe1d53000-0xe1d54000
+write-combining @ 0xe1d54000-0xe1d55000
+write-combining @ 0xe1d86000-0xe1d87000
+write-combining @ 0xe1d88000-0xe1d89000
+write-combining @ 0xe1d89000-0xe1d8a000
+write-combining @ 0xe1d8b000-0xe1d8c000
+write-combining @ 0xe1d8c000-0xe1d8d000
+write-combining @ 0xe1d8e000-0xe1d8f000
+write-combining @ 0xe1d8f000-0xe1d90000
+write-combining @ 0xe1dc0000-0xe1dc1000
+write-combining @ 0xe1dc1000-0xe1dc2000
+write-combining @ 0xe1dc2000-0xe1dc3000
+write-combining @ 0xe1dc4000-0xe1dc5000
+write-combining @ 0xe1dc5000-0xe1dc6000
+write-combining @ 0xe1dc7000-0xe1dc8000
+write-combining @ 0xe1dc8000-0xe1dc9000
+write-combining @ 0xe1e11000-0xe1e12000
+write-combining @ 0xe1e87000-0xe1e88000
+write-combining @ 0xe1e88000-0xe1e89000
+write-combining @ 0xe1e89000-0xe1e8a000
+write-combining @ 0xe1e8a000-0xe1e8b000
+write-combining @ 0xe1f3b000-0xe1f3c000
+write-combining @ 0xe20a8000-0xe20a9000
+write-combining @ 0xe2158000-0xe2159000
+write-combining @ 0xe2159000-0xe215a000
+write-combining @ 0xe215a000-0xe215b000
+write-combining @ 0xe2204000-0xe2205000
+write-combining @ 0xe2314000-0xe2315000
+write-combining @ 0xe2315000-0xe2316000
+write-combining @ 0xe2317000-0xe2318000
+write-combining @ 0xe2318000-0xe2319000
+write-combining @ 0xe2319000-0xe231a000
+write-combining @ 0xe233a000-0xe233b000
+write-combining @ 0xe233c000-0xe233d000
+write-combining @ 0xe233d000-0xe233e000
+write-combining @ 0xe2355000-0xe2356000
+write-combining @ 0xe2357000-0xe2358000
+write-combining @ 0xe2358000-0xe2359000
+write-combining @ 0xe235e000-0xe235f000
+write-combining @ 0xe2361000-0xe2362000
+write-combining @ 0xe2362000-0xe2363000
+write-combining @ 0xe2363000-0xe2364000
+write-combining @ 0xe2366000-0xe2367000
+write-combining @ 0xe2367000-0xe2368000
+write-combining @ 0xe2368000-0xe2369000
+write-combining @ 0xe2369000-0xe236a000
+write-combining @ 0xe236f000-0xe2370000
+write-combining @ 0xe2371000-0xe2372000
+write-combining @ 0xe237d000-0xe237e000
+write-combining @ 0xe2382000-0xe2383000
+write-combining @ 0xe2383000-0xe2384000
+write-combining @ 0xe2386000-0xe2387000
+write-combining @ 0xe2387000-0xe2388000
+write-combining @ 0xe2389000-0xe238a000
+write-combining @ 0xe23c7000-0xe23c8000
+write-combining @ 0xe23ca000-0xe23cb000
+write-combining @ 0xe23cb000-0xe23cc000
+write-combining @ 0xe23cc000-0xe23cd000
+write-combining @ 0xe23cd000-0xe23ce000
+write-combining @ 0xe23ce000-0xe23cf000
+write-combining @ 0xe23d3000-0xe23d4000
+write-combining @ 0xe23d4000-0xe23d5000
+write-combining @ 0xe23d5000-0xe23d6000
+write-combining @ 0xe2453000-0xe2454000
+write-combining @ 0xe2a5e000-0xe2a5f000
+write-combining @ 0xe2a5f000-0xe2a60000
+write-combining @ 0xe2a60000-0xe2a61000
+write-combining @ 0xe2a61000-0xe2a62000
+write-combining @ 0xe2a62000-0xe2a63000
+write-combining @ 0xe2a63000-0xe2a64000
+write-combining @ 0xe2a64000-0xe2a65000
+write-combining @ 0xe2a65000-0xe2a66000
+write-combining @ 0xe2a66000-0xe2a67000
+write-combining @ 0xe2a67000-0xe2a68000
+write-combining @ 0xe2a68000-0xe2a69000
+write-combining @ 0xe2a69000-0xe2a6a000
+write-combining @ 0xe2a6a000-0xe2a6b000
+write-combining @ 0xe2a6b000-0xe2a6c000
+write-combining @ 0xe2a6c000-0xe2a6d000
+write-combining @ 0xe2a6d000-0xe2a6e000
+write-combining @ 0xe2a74000-0xe2a75000
+write-combining @ 0xe2a75000-0xe2a76000
+write-combining @ 0xe2a7b000-0xe2a7c000
+write-combining @ 0xe2a81000-0xe2a82000
+write-combining @ 0xe2a82000-0xe2a83000
+write-combining @ 0xe2a83000-0xe2a84000
+write-combining @ 0xe2a84000-0xe2a85000
+write-combining @ 0xe2a85000-0xe2a86000
+write-combining @ 0xe2af6000-0xe2af7000
+write-combining @ 0xe2af7000-0xe2af8000
+write-combining @ 0xe2af8000-0xe2af9000
+write-combining @ 0xe2b27000-0xe2b28000
+write-combining @ 0xe2bd4000-0xe2bd5000
+write-combining @ 0xe2bd5000-0xe2bd6000
+write-combining @ 0xe2bd6000-0xe2bd7000
+write-combining @ 0xe2bd7000-0xe2bd8000
+write-combining @ 0xe2bd8000-0xe2bd9000
+write-combining @ 0xe2bd9000-0xe2bda000
+write-combining @ 0xe2f19000-0xe2f1a000
+write-combining @ 0xe372c000-0xe372d000
+write-combining @ 0xe372d000-0xe372e000
+write-combining @ 0xe372e000-0xe372f000
+write-combining @ 0xe384a000-0xe384b000
+write-combining @ 0xe384b000-0xe384c000
+write-combining @ 0xe384d000-0xe384e000
+write-combining @ 0xe384e000-0xe384f000
+write-combining @ 0xe384f000-0xe3850000
+write-combining @ 0xe3851000-0xe3852000
+write-combining @ 0xe3852000-0xe3853000
+write-combining @ 0xe3853000-0xe3854000
+write-combining @ 0xe3854000-0xe3855000
+write-combining @ 0xe3855000-0xe3856000
+write-combining @ 0xe3856000-0xe3857000
+write-combining @ 0xe385e000-0xe385f000
+write-combining @ 0xe385f000-0xe3860000
+write-combining @ 0xe3860000-0xe3861000
+write-combining @ 0xe3861000-0xe3862000
+write-combining @ 0xe3862000-0xe3863000
+write-combining @ 0xe3863000-0xe3864000
+write-combining @ 0xe39e8000-0xe39e9000
+write-combining @ 0xe39e9000-0xe39ea000
+write-combining @ 0xe39ed000-0xe39ee000
+write-combining @ 0xe39ee000-0xe39ef000
+write-combining @ 0xe39ef000-0xe39f0000
+write-combining @ 0xe39f1000-0xe39f2000
+write-combining @ 0xe39f3000-0xe39f4000
+write-combining @ 0xe3bf4000-0xe3bf5000
+write-combining @ 0xe4040000-0xe4041000
+write-combining @ 0xe4381000-0xe4382000
+write-combining @ 0xe4382000-0xe4383000
+write-combining @ 0xe4383000-0xe4384000
+write-combining @ 0xe4e91000-0xe4e92000
+write-combining @ 0xe4e94000-0xe4e95000
+write-combining @ 0xe52db000-0xe52dc000
+write-combining @ 0xe555e000-0xe555f000
+write-combining @ 0xe57df000-0xe57e0000
+write-combining @ 0xe57e0000-0xe57e1000
+write-combining @ 0xe57e1000-0xe57e2000
  uncached-minus @ 0xf0000000-0xf0400000
  uncached-minus @ 0xf0000000-0xf0080000
  uncached-minus @ 0xf0200000-0xf0400000

# pmap $(pidof X)
4539:   /usr/bin/X :0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
00007f8c059ee000      4K rw-s-  /dev/dri/card0
00007f8c059ef000      4K rw-s-  /dev/dri/card0
00007f8c059f0000      4K rw-s-  /dev/dri/card0
00007f8c059f5000      4K rw-s-  /dev/dri/card0
00007f8c059f6000      4K rw-s-  /dev/dri/card0
00007f8c059f7000      4K rw-s-  /dev/dri/card0
00007f8c059f8000      4K rw-s-  /dev/dri/card0
00007f8c059f9000      4K rw-s-  /dev/dri/card0
00007f8c059fc000      4K rw-s-  /dev/dri/card0
00007f8c059ff000      4K rw-s-  /dev/dri/card0
00007f8c05a00000    384K rw-s-    [ shmid=0xd000b ]
00007f8c05a60000    384K rw-s-    [ shmid=0xc800a ]
00007f8c05afb000      4K rw-s-  /dev/dri/card0
00007f8c05afd000      4K rw-s-  /dev/dri/card0
00007f8c05afe000      4K rw-s-  /dev/dri/card0
00007f8c05b01000      4K rw-s-  /dev/dri/card0
00007f8c05b02000      4K rw-s-  /dev/dri/card0
00007f8c05b07000      4K rw-s-  /dev/dri/card0
00007f8c05b13000      4K rw-s-  /dev/dri/card0
00007f8c05b15000      4K rw-s-  /dev/dri/card0
00007f8c05b1b000      4K rw-s-  /dev/dri/card0
00007f8c05b1c000      4K rw-s-  /dev/dri/card0
00007f8c05b1d000      4K rw-s-  /dev/dri/card0
00007f8c05b1e000      4K rw-s-  /dev/dri/card0
00007f8c05b21000      4K rw-s-  /dev/dri/card0
00007f8c05b22000      4K rw-s-  /dev/dri/card0
00007f8c05b23000      4K rw-s-  /dev/dri/card0
00007f8c05b26000      4K rw-s-  /dev/dri/card0
00007f8c05b2c000      4K rw-s-  /dev/dri/card0
00007f8c05b2d000      4K rw-s-  /dev/dri/card0
00007f8c05b2e000      4K rw-s-  /dev/dri/card0
00007f8c05b2f000      4K rw-s-  /dev/dri/card0
00007f8c05b30000      4K rw-s-  /dev/dri/card0
00007f8c05b31000      4K rw-s-  /dev/dri/card0
00007f8c05b32000      4K rw-s-  /dev/dri/card0
00007f8c05b33000      4K rw-s-  /dev/dri/card0
00007f8c05b34000      4K rw-s-  /dev/dri/card0
00007f8c05b35000      4K rw-s-  /dev/dri/card0
00007f8c05de2000    384K rw-s-    [ shmid=0xe000f ]
00007f8c05e5e000     64K rw-s-  /dev/dri/card0
00007f8c05e6e000     16K rw-s-  /dev/dri/card0
00007f8c05e72000     28K rw-s-  /dev/dri/card0
00007f8c05e7e000      8K rw-s-  /dev/dri/card0
00007f8c05e80000      8K rw-s-  /dev/dri/card0
00007f8c05e82000      8K rw-s-  /dev/dri/card0
00007f8c05ebd000      8K rw-s-  /dev/dri/card0
00007f8c05ee2000     16K rw-s-  /dev/dri/card0
00007f8c05ee6000     28K rw-s-  /dev/dri/card0
00007f8c05f0c000    256K rw-s-  /dev/dri/card0
00007f8c05f4c000    384K rw-s-    [ shmid=0xd800c ]
00007f8c05fac000    284K rw---    [ anon ]
00007f8c05ff6000     24K rw-s-  /dev/dri/card0
00007f8c05ffc000     24K rw-s-  /dev/dri/card0
00007f8c06002000     24K rw-s-  /dev/dri/card0
00007f8c06008000     24K rw-s-  /dev/dri/card0
00007f8c06032000     16K rw-s-  /dev/dri/card0
00007f8c06036000    384K rw-s-    [ shmid=0xc0009 ]
00007f8c06096000    160K rw-s-  /dev/dri/card0
00007f8c060be000    384K rw-s-    [ shmid=0xb8008 ]
00007f8c0611e000      4K rw-s-  /dev/dri/card0
00007f8c0611f000      4K rw-s-  /dev/dri/card0
00007f8c06120000      4K rw-s-  /dev/dri/card0
00007f8c06121000      4K rw-s-  /dev/dri/card0
00007f8c06122000      4K rw-s-  /dev/dri/card0
00007f8c06123000      4K rw-s-  /dev/dri/card0
00007f8c06124000      4K rw-s-  /dev/dri/card0
00007f8c06125000      4K rw-s-  /dev/dri/card0
00007f8c06126000      4K rw-s-  /dev/dri/card0
00007f8c06127000      4K rw-s-  /dev/dri/card0
00007f8c06128000      4K rw-s-  /dev/dri/card0
00007f8c06129000      4K rw-s-  /dev/dri/card0
00007f8c0612a000      4K rw-s-  /dev/dri/card0
00007f8c0612b000      4K rw-s-  /dev/dri/card0
00007f8c0612c000   5120K rw-s-  /dev/dri/card0
00007f8c0662c000     44K r-x--  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06637000   2044K -----  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06836000      4K r----  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06837000      4K rw---  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06838000     40K r-x--  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06842000   2044K -----  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a41000      4K r----  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a42000      4K rw---  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a43000     84K r-x--  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06a58000   2044K -----  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c57000      4K r----  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c58000      4K rw---  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c59000      8K rw---    [ anon ]
00007f8c06c5b000     28K r-x--  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06c62000   2044K -----  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e61000      4K r----  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e62000      4K rw---  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e63000   5120K rw-s-  /dev/dri/card0
00007f8c07363000     52K r-x--  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07370000   2048K -----  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07570000      4K rw---  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07571000     48K r-x--  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0757d000   2044K -----  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0777c000      4K rw---  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0777d000   5120K rw-s-  /dev/dri/card0
00007f8c07c7d000    928K r-x--  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07d65000   2048K -----  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f65000     32K r----  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f6d000      8K rw---  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f6f000     84K rw---    [ anon ]
00007f8c07f84000    156K r-x--  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c07fab000   2048K -----  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ab000      8K r----  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ad000      4K rw---  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ae000   3752K r-x--  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08558000   2044K -----  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08757000    108K rw---  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08772000     72K rw---    [ anon ]
00007f8c08784000    136K r-x--  /usr/lib/xorg/modules/libfb.so
00007f8c087a6000   2044K -----  /usr/lib/xorg/modules/libfb.so
00007f8c089a5000      4K r----  /usr/lib/xorg/modules/libfb.so
00007f8c089a6000      4K rw---  /usr/lib/xorg/modules/libfb.so
00007f8c089a7000    112K r-x--  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c089c3000   2048K -----  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc3000      4K r----  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc4000      4K rw---  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc5000    312K r-x--  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08c13000   2048K -----  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08e13000     16K rw---  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08e17000     20K r-x--  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c08e1c000   2044K -----  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901b000      4K r----  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901c000      4K rw---  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901d000     44K r-x--  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09028000   2044K -----  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09227000      4K r----  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09228000      4K rw---  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09229000     40K r-x--  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09233000   2048K -----  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09433000      4K r----  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09434000      4K rw---  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09435000     28K r-x--  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0943c000   2044K -----  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963b000      4K r----  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963c000      4K rw---  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963d000    376K r-x--  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0969b000   2048K -----  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989b000      4K r----  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989c000     12K rw---  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989f000      8K rw---    [ anon ]
00007f8c098a1000     20K r-x--  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c098a6000   2044K -----  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa5000      4K r----  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa6000      4K rw---  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa7000    120K r-x--  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09ac5000   2044K -----  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc4000      4K r----  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc5000      4K rw---  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc6000      4K rw---    [ anon ]
00007f8c09cc7000    140K r-x--  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09cea000   2044K -----  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09ee9000      4K r----  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09eea000      8K rw---  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09eec000     84K r-x--  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c09f01000   2048K -----  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c0a101000      4K rw---  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c0a102000     12K rw---    [ anon ]
00007f8c0a105000     24K r-x--  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a10b000   2044K -----  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a30a000      8K rw---  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a30c000     60K r-x--  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a31b000   2044K -----  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a51a000      8K rw---  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a51c000    612K r-x--  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a5b5000   2044K -----  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7b4000     24K r----  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7ba000      4K rw---  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7bb000     88K r-x--  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a7d1000   2044K -----  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a9d0000      4K rw---  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a9d1000     12K r-x--  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0a9d4000   2044K -----  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0abd3000      4K rw---  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0abd4000   1524K r-x--  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0ad51000   2048K -----  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af51000     16K r----  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af55000      4K rw---  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af56000     20K rw---    [ anon ]
00007f8c0af5b000     28K r-x--  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0af62000   2044K -----  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b161000      4K r----  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b162000      4K rw---  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b163000    516K r-x--  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b1e4000   2044K -----  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e3000      4K r----  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e4000      4K rw---  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e5000     92K r-x--  /lib/libaudit.so.0.0.0
00007f8c0b3fc000   2044K -----  /lib/libaudit.so.0.0.0
00007f8c0b5fb000      4K r----  /lib/libaudit.so.0.0.0
00007f8c0b5fc000      4K rw---  /lib/libaudit.so.0.0.0
00007f8c0b5fd000     20K r-x--  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b602000   2044K -----  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b801000      4K r----  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b802000      4K rw---  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b803000      8K r-x--  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0b805000   2044K -----  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba04000      4K r----  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba05000      4K rw---  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba06000    236K r-x--  /usr/lib/libXfont.so.1.4.1
00007f8c0ba41000   2044K -----  /usr/lib/libXfont.so.1.4.1
00007f8c0bc40000      4K r----  /usr/lib/libXfont.so.1.4.1
00007f8c0bc41000      8K rw---  /usr/lib/libXfont.so.1.4.1
00007f8c0bc43000    520K r-x--  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0bcc5000   2044K -----  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0bec4000     24K rw---  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0beca000     92K r-x--  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0bee1000   2044K -----  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e0000      4K r----  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e1000      4K rw---  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e2000     16K rw---    [ anon ]
00007f8c0c0e6000     32K r-x--  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c0ee000   2044K -----  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ed000      4K r----  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ee000      4K rw---  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ef000      8K r-x--  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c2f1000   2048K -----  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f1000      4K r----  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f2000      4K rw---  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f3000    488K r-x--  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c56d000   2048K -----  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c76d000     16K rw---  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c771000     56K r-x--  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c77f000   2044K -----  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c97e000      4K r----  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c97f000      4K rw---  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c980000    124K r-x--  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0c99f000      4K rw-s-  /dev/dri/card0
00007f8c0c9a0000      4K rw-s-  /dev/dri/card0
00007f8c0c9a1000      4K rw-s-  /dev/dri/card0
00007f8c0c9a2000      4K rw-s-  /dev/dri/card0
00007f8c0c9a3000      4K rw-s-  /dev/dri/card0
00007f8c0c9a4000    384K rw-s-    [ shmid=0xb0007 ]
00007f8c0ca04000    384K rw-s-    [ shmid=0xa8006 ]
00007f8c0ca64000      4K rw-s-  /dev/dri/card0
00007f8c0ca65000      4K rw-s-  /dev/dri/card0
00007f8c0ca66000      4K rw-s-  /dev/dri/card0
00007f8c0ca67000      4K rw-s-  /dev/dri/card0
00007f8c0ca68000      4K rw-s-  /dev/dri/card0
00007f8c0ca69000      4K rw-s-  /dev/dri/card0
00007f8c0ca6a000      4K rw-s-  /dev/dri/card0
00007f8c0ca6b000      4K rw-s-  /dev/dri/card0
00007f8c0ca6c000      4K rw-s-  /dev/dri/card0
00007f8c0ca6d000      4K rw-s-  /dev/dri/card0
00007f8c0ca6e000      4K rw-s-  /dev/dri/card0
00007f8c0ca6f000      4K rw-s-  /dev/dri/card0
00007f8c0ca70000      4K rw-s-  /dev/dri/card0
00007f8c0ca71000      4K rw-s-  /dev/dri/card0
00007f8c0ca72000      4K rw-s-  /dev/dri/card0
00007f8c0ca73000      4K rw-s-  /dev/dri/card0
00007f8c0ca74000      4K rw-s-  /dev/dri/card0
00007f8c0ca75000      4K rw-s-  /dev/dri/card0
00007f8c0ca76000      4K rw-s-  /dev/dri/card0
00007f8c0ca77000      4K rw-s-  /dev/dri/card0
00007f8c0ca78000      4K rw-s-  /dev/dri/card0
00007f8c0ca79000      4K rw-s-  /dev/dri/card0
00007f8c0ca7a000      4K rw-s-  /dev/dri/card0
00007f8c0ca7b000      4K rw-s-  /dev/dri/card0
00007f8c0ca7c000      4K rw-s-  /dev/dri/card0
00007f8c0ca7d000      4K rw-s-  /dev/dri/card0
00007f8c0ca7e000      4K rw-s-  /dev/dri/card0
00007f8c0ca7f000      4K rw-s-  /dev/dri/card0
00007f8c0ca80000      4K rw-s-  /dev/dri/card0
00007f8c0ca81000      4K rw-s-  /dev/dri/card0
00007f8c0ca82000      4K rw-s-  /dev/dri/card0
00007f8c0ca83000      4K rw-s-  /dev/dri/card0
00007f8c0ca84000      4K rw-s-  /dev/dri/card0
00007f8c0ca85000      4K rw-s-  /dev/dri/card0
00007f8c0ca86000      4K rw-s-  /dev/dri/card0
00007f8c0ca87000      4K rw-s-  /dev/dri/card0
00007f8c0ca88000      4K rw-s-  /dev/dri/card0
00007f8c0ca89000    384K rw-s-    [ shmid=0xa0005 ]
00007f8c0cae9000      4K rw-s-  /dev/dri/card0
00007f8c0caea000      4K rw-s-  /dev/dri/card0
00007f8c0caeb000      4K rw-s-  /dev/dri/card0
00007f8c0caec000      4K rw-s-  /dev/dri/card0
00007f8c0caf0000      4K rw-s-  /dev/dri/card0
00007f8c0caf1000      4K rw-s-  /dev/dri/card0
00007f8c0caf2000      4K rw-s-  /dev/dri/card0
00007f8c0caf3000      4K rw-s-  /dev/dri/card0
00007f8c0caf4000      4K rw-s-  /dev/dri/card0
00007f8c0caf5000      4K rw-s-  /dev/dri/card0
00007f8c0caf6000      4K rw-s-  /dev/dri/card0
00007f8c0caf7000      4K rw-s-  /dev/dri/card0
00007f8c0caf8000      4K rw-s-  /dev/dri/card0
00007f8c0caf9000      4K rw-s-  /dev/dri/card0
00007f8c0cafa000      4K rw-s-  /dev/dri/card0
00007f8c0cafb000      4K rw-s-  /dev/dri/card0
00007f8c0cafc000      4K rw-s-  /dev/dri/card0
00007f8c0cafd000      4K rw-s-  /dev/dri/card0
00007f8c0cafe000      4K rw-s-  /dev/dri/card0
00007f8c0caff000      4K rw-s-  /dev/dri/card0
00007f8c0cb00000      4K rw-s-  /dev/dri/card0
00007f8c0cb01000      4K rw-s-  /dev/dri/card0
00007f8c0cb02000      4K rw-s-  /dev/dri/card0
00007f8c0cb03000      4K rw-s-  /dev/dri/card0
00007f8c0cb04000      4K rw-s-  /dev/dri/card0
00007f8c0cb05000      4K rw-s-  /dev/dri/card0
00007f8c0cb06000      4K rw-s-  /dev/dri/card0
00007f8c0cb07000      4K rw-s-  /dev/dri/card0
00007f8c0cb08000      4K rw-s-  /dev/dri/card0
00007f8c0cb09000      4K rw-s-  /dev/dri/card0
00007f8c0cb0a000      4K rw-s-  /dev/dri/card0
00007f8c0cb0b000    264K rw---    [ anon ]
00007f8c0cb4d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb4e000     28K rw-s-  /drm mm object (deleted)
00007f8c0cb55000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb56000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb57000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb58000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb59000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb60000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb61000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb62000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb63000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb64000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb65000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb66000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb67000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb68000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb69000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb70000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb71000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb72000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb73000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb74000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb75000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb76000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb77000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb78000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb79000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb80000     24K rw---    [ anon ]
00007f8c0cb86000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb87000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb88000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb89000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb90000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb91000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb92000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb93000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb94000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb95000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb96000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb97000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb98000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb99000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9c000     12K rw---    [ anon ]
00007f8c0cb9f000      4K r----  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0cba0000      4K rw---  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0cba1000      4K rw---    [ anon ]
00007f8c0cba2000   1956K r-x--  /usr/bin/Xorg
00007f8c0cf8a000     12K r----  /usr/bin/Xorg
00007f8c0cf8d000     44K rw---  /usr/bin/Xorg
00007f8c0cf98000     76K rw---    [ anon ]
00007f8c0e9c6000   6600K rw---    [ anon ]
00007fffadf48000    132K rw---    [ stack ]
00007fffadffc000      4K r-x--    [ anon ]
ffffffffff600000      4K r-x--    [ anon ]
  total           121332K
root@zurg:/home/blind# pmap $(pidof X) | less
root@zurg:/home/blind# pmap $(pidof X) | less
root@zurg:/home/blind# pmap $(pidof X)
4539:   /usr/bin/X :0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
00007f8c059ee000      4K rw-s-  /dev/dri/card0
00007f8c059ef000      4K rw-s-  /dev/dri/card0
00007f8c059f0000      4K rw-s-  /dev/dri/card0
00007f8c059f6000      4K rw-s-  /dev/dri/card0
00007f8c059f7000      4K rw-s-  /dev/dri/card0
00007f8c059f8000      4K rw-s-  /dev/dri/card0
00007f8c059f9000      4K rw-s-  /dev/dri/card0
00007f8c059fc000      4K rw-s-  /dev/dri/card0
00007f8c059ff000      4K rw-s-  /dev/dri/card0
00007f8c05a00000    384K rw-s-    [ shmid=0xd000b ]
00007f8c05a60000    384K rw-s-    [ shmid=0xc800a ]
00007f8c05afb000      4K rw-s-  /dev/dri/card0
00007f8c05afd000      4K rw-s-  /dev/dri/card0
00007f8c05afe000      4K rw-s-  /dev/dri/card0
00007f8c05b01000      4K rw-s-  /dev/dri/card0
00007f8c05b02000      4K rw-s-  /dev/dri/card0
00007f8c05b07000      4K rw-s-  /dev/dri/card0
00007f8c05b13000      4K rw-s-  /dev/dri/card0
00007f8c05b1b000      4K rw-s-  /dev/dri/card0
00007f8c05b1c000      4K rw-s-  /dev/dri/card0
00007f8c05b1d000      4K rw-s-  /dev/dri/card0
00007f8c05b1e000      4K rw-s-  /dev/dri/card0
00007f8c05b21000      4K rw-s-  /dev/dri/card0
00007f8c05b22000      4K rw-s-  /dev/dri/card0
00007f8c05b23000      4K rw-s-  /dev/dri/card0
00007f8c05b26000      4K rw-s-  /dev/dri/card0
00007f8c05b2c000      4K rw-s-  /dev/dri/card0
00007f8c05b2d000      4K rw-s-  /dev/dri/card0
00007f8c05b2e000      4K rw-s-  /dev/dri/card0
00007f8c05b2f000      4K rw-s-  /dev/dri/card0
00007f8c05b30000      4K rw-s-  /dev/dri/card0
00007f8c05b31000      4K rw-s-  /dev/dri/card0
00007f8c05b32000      4K rw-s-  /dev/dri/card0
00007f8c05b33000      4K rw-s-  /dev/dri/card0
00007f8c05b34000      4K rw-s-  /dev/dri/card0
00007f8c05b35000      4K rw-s-  /dev/dri/card0
00007f8c05b42000     28K rw-s-  /dev/dri/card0
00007f8c05b8d000    256K rw-s-  /dev/dri/card0
00007f8c05bcd000      8K rw---    [ anon ]
00007f8c05bde000    160K rw-s-  /dev/dri/card0
00007f8c05c2a000    224K rw-s-  /dev/dri/card0
00007f8c05c68000    160K rw-s-  /dev/dri/card0
00007f8c05c90000      4K rw-s-  /dev/dri/card0
00007f8c05c91000     16K rw-s-  /dev/dri/card0
00007f8c05c9c000    160K rw-s-  /dev/dri/card0
00007f8c05cc6000    160K rw-s-  /dev/dri/card0
00007f8c05d06000     48K rw-s-  /dev/dri/card0
00007f8c05d4a000    224K rw-s-  /dev/dri/card0
00007f8c05d82000    384K rw-s-    [ shmid=0xf8010 ]
00007f8c05de2000    384K rw-s-    [ shmid=0xe000f ]
00007f8c05e52000      4K rw-s-  /dev/dri/card0
00007f8c05e56000      4K rw-s-  /dev/dri/card0
00007f8c05e57000      4K rw-s-  /dev/dri/card0
00007f8c05e58000      4K rw-s-  /dev/dri/card0
00007f8c05e59000      4K rw-s-  /dev/dri/card0
00007f8c05e5c000      4K rw-s-  /dev/dri/card0
00007f8c05e5d000      4K rw-s-  /dev/dri/card0
00007f8c05e5e000     64K rw-s-  /dev/dri/card0
00007f8c05e6e000     16K rw-s-  /dev/dri/card0
00007f8c05e72000     28K rw-s-  /dev/dri/card0
00007f8c05e79000      4K rw-s-  /dev/dri/card0
00007f8c05e7e000      8K rw-s-  /dev/dri/card0
00007f8c05e80000      8K rw-s-  /dev/dri/card0
00007f8c05e82000      8K rw-s-  /dev/dri/card0
00007f8c05e84000      4K rw-s-  /dev/dri/card0
00007f8c05e8b000      4K rw-s-  /dev/dri/card0
00007f8c05e8c000      4K rw-s-  /dev/dri/card0
00007f8c05e8e000      4K rw-s-  /dev/dri/card0
00007f8c05e91000      4K rw-s-  /dev/dri/card0
00007f8c05e92000      4K rw-s-  /dev/dri/card0
00007f8c05e93000     16K rw-s-  /dev/dri/card0
00007f8c05e9a000      4K rw-s-  /dev/dri/card0
00007f8c05e9b000      4K rw-s-  /dev/dri/card0
00007f8c05ea1000     32K rw-s-  /dev/dri/card0
00007f8c05eb3000      4K rw-s-  /dev/dri/card0
00007f8c05eb4000      4K rw-s-  /dev/dri/card0
00007f8c05eb5000     16K rw-s-  /dev/dri/card0
00007f8c05eb9000     16K rw-s-  /dev/dri/card0
00007f8c05ebe000      8K rw---    [ anon ]
00007f8c05ec2000      4K rw-s-  /dev/dri/card0
00007f8c05ec3000      4K rw-s-  /dev/dri/card0
00007f8c05ec6000     80K rw-s-  /dev/dri/card0
00007f8c05eda000     16K rw-s-  /dev/dri/card0
00007f8c05ede000     16K rw-s-  /dev/dri/card0
00007f8c05ee2000     16K rw-s-  /dev/dri/card0
00007f8c05ee6000     28K rw-s-  /dev/dri/card0
00007f8c05eed000      4K rw-s-  /dev/dri/card0
00007f8c05eee000      4K rw-s-  /dev/dri/card0
00007f8c05eef000      4K rw-s-  /dev/dri/card0
00007f8c05ef0000     20K rw-s-  /dev/dri/card0
00007f8c05ef5000     20K rw-s-  /dev/dri/card0
00007f8c05efb000      4K rw-s-  /dev/dri/card0
00007f8c05efc000     16K rw-s-  /dev/dri/card0
00007f8c05f00000      4K rw-s-  /dev/dri/card0
00007f8c05f01000      4K rw-s-  /dev/dri/card0
00007f8c05f02000      4K rw-s-  /dev/dri/card0
00007f8c05f04000      4K rw-s-  /dev/dri/card0
00007f8c05f05000      4K rw-s-  /dev/dri/card0
00007f8c05f08000      4K rw-s-  /dev/dri/card0
00007f8c05f0c000    256K rw-s-  /dev/dri/card0
00007f8c05f4c000    384K rw-s-    [ shmid=0xd800c ]
00007f8c05fac000    276K rw---    [ anon ]
00007f8c05ff1000      8K rw-s-  /dev/dri/card0
00007f8c05ff3000      4K rw-s-  /dev/dri/card0
00007f8c05ff4000      4K rw-s-  /dev/dri/card0
00007f8c05ff5000      4K rw-s-  /dev/dri/card0
00007f8c05ff6000     24K rw-s-  /dev/dri/card0
00007f8c05ffc000     24K rw-s-  /dev/dri/card0
00007f8c06002000     24K rw-s-  /dev/dri/card0
00007f8c06008000     24K rw-s-  /dev/dri/card0
00007f8c0600e000      4K rw-s-  /dev/dri/card0
00007f8c06010000      8K rw-s-  /dev/dri/card0
00007f8c06012000      8K rw-s-  /dev/dri/card0
00007f8c06014000      8K rw-s-  /dev/dri/card0
00007f8c06016000      4K rw-s-  /dev/dri/card0
00007f8c06017000      4K rw-s-  /dev/dri/card0
00007f8c06018000      4K rw-s-  /dev/dri/card0
00007f8c06019000      4K rw-s-  /dev/dri/card0
00007f8c0601a000      4K rw-s-  /dev/dri/card0
00007f8c0601b000      4K rw-s-  /dev/dri/card0
00007f8c0601c000      4K rw-s-  /dev/dri/card0
00007f8c0601d000      4K rw-s-  /dev/dri/card0
00007f8c0601e000      4K rw-s-  /dev/dri/card0
00007f8c0601f000      4K rw-s-  /dev/dri/card0
00007f8c06020000     20K rw-s-  /dev/dri/card0
00007f8c06025000      4K rw-s-  /dev/dri/card0
00007f8c06026000      4K rw-s-  /dev/dri/card0
00007f8c06027000     12K rw-s-  /dev/dri/card0
00007f8c0602a000      4K rw-s-  /dev/dri/card0
00007f8c0602b000      4K rw-s-  /dev/dri/card0
00007f8c0602c000      4K rw-s-  /dev/dri/card0
00007f8c0602d000      4K rw-s-  /dev/dri/card0
00007f8c0602e000      4K rw-s-  /dev/dri/card0
00007f8c0602f000      4K rw-s-  /dev/dri/card0
00007f8c06030000      4K rw-s-  /dev/dri/card0
00007f8c06031000      4K rw-s-  /dev/dri/card0
00007f8c06032000      4K rw-s-  /dev/dri/card0
00007f8c06033000      4K rw-s-  /dev/dri/card0
00007f8c06034000      4K rw-s-  /dev/dri/card0
00007f8c06035000      4K rw-s-  /dev/dri/card0
00007f8c06036000    384K rw-s-    [ shmid=0xc0009 ]
00007f8c06096000      4K rw-s-  /dev/dri/card0
00007f8c06097000      4K rw-s-  /dev/dri/card0
00007f8c0609b000      4K rw-s-  /dev/dri/card0
00007f8c060a4000      4K rw-s-  /dev/dri/card0
00007f8c060a5000      4K rw-s-  /dev/dri/card0
00007f8c060a9000     16K rw-s-  /dev/dri/card0
00007f8c060ad000      4K rw-s-  /dev/dri/card0
00007f8c060ae000      4K rw-s-  /dev/dri/card0
00007f8c060af000      4K rw-s-  /dev/dri/card0
00007f8c060b0000      4K rw-s-  /dev/dri/card0
00007f8c060b1000      4K rw-s-  /dev/dri/card0
00007f8c060b2000     16K rw-s-  /dev/dri/card0
00007f8c060b6000     16K rw-s-  /dev/dri/card0
00007f8c060ba000      4K rw-s-  /dev/dri/card0
00007f8c060bb000      4K rw-s-  /dev/dri/card0
00007f8c060be000    384K rw-s-    [ shmid=0xb8008 ]
00007f8c0611e000      4K rw-s-  /dev/dri/card0
00007f8c0611f000      4K rw-s-  /dev/dri/card0
00007f8c06120000      4K rw-s-  /dev/dri/card0
00007f8c06121000      4K rw-s-  /dev/dri/card0
00007f8c06122000      4K rw-s-  /dev/dri/card0
00007f8c06123000      4K rw-s-  /dev/dri/card0
00007f8c06124000      4K rw-s-  /dev/dri/card0
00007f8c06125000      4K rw-s-  /dev/dri/card0
00007f8c06126000      4K rw-s-  /dev/dri/card0
00007f8c06127000      4K rw-s-  /dev/dri/card0
00007f8c06128000      4K rw-s-  /dev/dri/card0
00007f8c06129000      4K rw-s-  /dev/dri/card0
00007f8c0612a000      4K rw-s-  /dev/dri/card0
00007f8c0612b000      4K rw-s-  /dev/dri/card0
00007f8c0612c000   5120K rw-s-  /dev/dri/card0
00007f8c0662c000     44K r-x--  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06637000   2044K -----  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06836000      4K r----  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06837000      4K rw---  /lib/x86_64-linux-gnu/libnss_files-2.13.so
00007f8c06838000     40K r-x--  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06842000   2044K -----  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a41000      4K r----  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a42000      4K rw---  /lib/x86_64-linux-gnu/libnss_nis-2.13.so
00007f8c06a43000     84K r-x--  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06a58000   2044K -----  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c57000      4K r----  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c58000      4K rw---  /lib/x86_64-linux-gnu/libnsl-2.13.so
00007f8c06c59000      8K rw---    [ anon ]
00007f8c06c5b000     28K r-x--  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06c62000   2044K -----  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e61000      4K r----  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e62000      4K rw---  /lib/x86_64-linux-gnu/libnss_compat-2.13.so
00007f8c06e63000   5120K rw-s-  /dev/dri/card0
00007f8c07363000     52K r-x--  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07370000   2048K -----  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07570000      4K rw---  /usr/lib/xorg/modules/input/synaptics_drv.so
00007f8c07571000     48K r-x--  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0757d000   2044K -----  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0777c000      4K rw---  /usr/lib/xorg/modules/input/evdev_drv.so
00007f8c0777d000   5120K rw-s-  /dev/dri/card0
00007f8c07c7d000    928K r-x--  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07d65000   2048K -----  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f65000     32K r----  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f6d000      8K rw---  /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
00007f8c07f6f000     84K rw---    [ anon ]
00007f8c07f84000    156K r-x--  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c07fab000   2048K -----  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ab000      8K r----  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ad000      4K rw---  /lib/x86_64-linux-gnu/libexpat.so.1.6.0
00007f8c081ae000   3752K r-x--  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08558000   2044K -----  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08757000    108K rw---  /usr/lib/x86_64-linux-gnu/dri/i965_dri.so
00007f8c08772000     72K rw---    [ anon ]
00007f8c08784000    136K r-x--  /usr/lib/xorg/modules/libfb.so
00007f8c087a6000   2044K -----  /usr/lib/xorg/modules/libfb.so
00007f8c089a5000      4K r----  /usr/lib/xorg/modules/libfb.so
00007f8c089a6000      4K rw---  /usr/lib/xorg/modules/libfb.so
00007f8c089a7000    112K r-x--  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c089c3000   2048K -----  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc3000      4K r----  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc4000      4K rw---  /usr/lib/x86_64-linux-gnu/libdrm_intel.so.1.0.0
00007f8c08bc5000    312K r-x--  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08c13000   2048K -----  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08e13000     16K rw---  /usr/lib/xorg/modules/drivers/intel_drv.so
00007f8c08e17000     20K r-x--  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c08e1c000   2044K -----  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901b000      4K r----  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901c000      4K rw---  /usr/lib/xorg/modules/extensions/libdri2.so
00007f8c0901d000     44K r-x--  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09028000   2044K -----  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09227000      4K r----  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09228000      4K rw---  /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0
00007f8c09229000     40K r-x--  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09233000   2048K -----  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09433000      4K r----  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09434000      4K rw---  /usr/lib/xorg/modules/extensions/libdri.so
00007f8c09435000     28K r-x--  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0943c000   2044K -----  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963b000      4K r----  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963c000      4K rw---  /usr/lib/xorg/modules/extensions/librecord.so
00007f8c0963d000    376K r-x--  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0969b000   2048K -----  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989b000      4K r----  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989c000     12K rw---  /usr/lib/xorg/modules/extensions/libglx.so
00007f8c0989f000      8K rw---    [ anon ]
00007f8c098a1000     20K r-x--  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c098a6000   2044K -----  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa5000      4K r----  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa6000      4K rw---  /usr/lib/xorg/modules/extensions/libdbe.so
00007f8c09aa7000    120K r-x--  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09ac5000   2044K -----  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc4000      4K r----  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc5000      4K rw---  /lib/x86_64-linux-gnu/libselinux.so.1
00007f8c09cc6000      4K rw---    [ anon ]
00007f8c09cc7000    140K r-x--  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09cea000   2044K -----  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09ee9000      4K r----  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09eea000      8K rw---  /usr/lib/xorg/modules/extensions/libextmod.so
00007f8c09eec000     84K r-x--  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c09f01000   2048K -----  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c0a101000      4K rw---  /lib/x86_64-linux-gnu/libgcc_s.so.1
00007f8c0a102000     12K rw---    [ anon ]
00007f8c0a105000     24K r-x--  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a10b000   2044K -----  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a30a000      8K rw---  /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0
00007f8c0a30c000     60K r-x--  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a31b000   2044K -----  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a51a000      8K rw---  /lib/x86_64-linux-gnu/libbz2.so.1.0.4
00007f8c0a51c000    612K r-x--  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a5b5000   2044K -----  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7b4000     24K r----  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7ba000      4K rw---  /usr/lib/x86_64-linux-gnu/libfreetype.so.6.8.1
00007f8c0a7bb000     88K r-x--  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a7d1000   2044K -----  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a9d0000      4K rw---  /usr/lib/x86_64-linux-gnu/libz.so.1.2.6
00007f8c0a9d1000     12K r-x--  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0a9d4000   2044K -----  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0abd3000      4K rw---  /lib/x86_64-linux-gnu/libgpg-error.so.0.8.0
00007f8c0abd4000   1524K r-x--  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0ad51000   2048K -----  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af51000     16K r----  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af55000      4K rw---  /lib/x86_64-linux-gnu/libc-2.13.so
00007f8c0af56000     20K rw---    [ anon ]
00007f8c0af5b000     28K r-x--  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0af62000   2044K -----  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b161000      4K r----  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b162000      4K rw---  /lib/x86_64-linux-gnu/librt-2.13.so
00007f8c0b163000    516K r-x--  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b1e4000   2044K -----  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e3000      4K r----  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e4000      4K rw---  /lib/x86_64-linux-gnu/libm-2.13.so
00007f8c0b3e5000     92K r-x--  /lib/libaudit.so.0.0.0
00007f8c0b3fc000   2044K -----  /lib/libaudit.so.0.0.0
00007f8c0b5fb000      4K r----  /lib/libaudit.so.0.0.0
00007f8c0b5fc000      4K rw---  /lib/libaudit.so.0.0.0
00007f8c0b5fd000     20K r-x--  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b602000   2044K -----  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b801000      4K r----  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b802000      4K rw---  /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0
00007f8c0b803000      8K r-x--  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0b805000   2044K -----  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba04000      4K r----  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba05000      4K rw---  /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0
00007f8c0ba06000    236K r-x--  /usr/lib/libXfont.so.1.4.1
00007f8c0ba41000   2044K -----  /usr/lib/libXfont.so.1.4.1
00007f8c0bc40000      4K r----  /usr/lib/libXfont.so.1.4.1
00007f8c0bc41000      8K rw---  /usr/lib/libXfont.so.1.4.1
00007f8c0bc43000    520K r-x--  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0bcc5000   2044K -----  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0bec4000     24K rw---  /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.24.4
00007f8c0beca000     92K r-x--  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0bee1000   2044K -----  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e0000      4K r----  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e1000      4K rw---  /lib/x86_64-linux-gnu/libpthread-2.13.so
00007f8c0c0e2000     16K rw---    [ anon ]
00007f8c0c0e6000     32K r-x--  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c0ee000   2044K -----  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ed000      4K r----  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ee000      4K rw---  /usr/lib/x86_64-linux-gnu/libpciaccess.so.0.11.0
00007f8c0c2ef000      8K r-x--  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c2f1000   2048K -----  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f1000      4K r----  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f2000      4K rw---  /lib/x86_64-linux-gnu/libdl-2.13.so
00007f8c0c4f3000    488K r-x--  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c56d000   2048K -----  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c76d000     16K rw---  /lib/x86_64-linux-gnu/libgcrypt.so.11.7.0
00007f8c0c771000     56K r-x--  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c77f000   2044K -----  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c97e000      4K r----  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c97f000      4K rw---  /lib/x86_64-linux-gnu/libudev.so.0.13.0
00007f8c0c980000    124K r-x--  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0c99f000      4K rw-s-  /dev/dri/card0
00007f8c0c9a0000      4K rw-s-  /dev/dri/card0
00007f8c0c9a1000      4K rw-s-  /dev/dri/card0
00007f8c0c9a2000      4K rw-s-  /dev/dri/card0
00007f8c0c9a3000      4K rw-s-  /dev/dri/card0
00007f8c0c9a4000    384K rw-s-    [ shmid=0xb0007 ]
00007f8c0ca04000    384K rw-s-    [ shmid=0xa8006 ]
00007f8c0ca64000      4K rw-s-  /dev/dri/card0
00007f8c0ca65000      4K rw-s-  /dev/dri/card0
00007f8c0ca66000      4K rw-s-  /dev/dri/card0
00007f8c0ca67000      4K rw-s-  /dev/dri/card0
00007f8c0ca68000      4K rw-s-  /dev/dri/card0
00007f8c0ca69000      4K rw-s-  /dev/dri/card0
00007f8c0ca6a000      4K rw-s-  /dev/dri/card0
00007f8c0ca6b000      4K rw-s-  /dev/dri/card0
00007f8c0ca6c000      4K rw-s-  /dev/dri/card0
00007f8c0ca6d000      4K rw-s-  /dev/dri/card0
00007f8c0ca6e000      4K rw-s-  /dev/dri/card0
00007f8c0ca6f000      4K rw-s-  /dev/dri/card0
00007f8c0ca70000      4K rw-s-  /dev/dri/card0
00007f8c0ca71000      4K rw-s-  /dev/dri/card0
00007f8c0ca72000      4K rw-s-  /dev/dri/card0
00007f8c0ca73000      4K rw-s-  /dev/dri/card0
00007f8c0ca74000      4K rw-s-  /dev/dri/card0
00007f8c0ca75000      4K rw-s-  /dev/dri/card0
00007f8c0ca76000      4K rw-s-  /dev/dri/card0
00007f8c0ca77000      4K rw-s-  /dev/dri/card0
00007f8c0ca78000      4K rw-s-  /dev/dri/card0
00007f8c0ca79000      4K rw-s-  /dev/dri/card0
00007f8c0ca7a000      4K rw-s-  /dev/dri/card0
00007f8c0ca7b000      4K rw-s-  /dev/dri/card0
00007f8c0ca7c000      4K rw-s-  /dev/dri/card0
00007f8c0ca7d000      4K rw-s-  /dev/dri/card0
00007f8c0ca7e000      4K rw-s-  /dev/dri/card0
00007f8c0ca7f000      4K rw-s-  /dev/dri/card0
00007f8c0ca80000      4K rw-s-  /dev/dri/card0
00007f8c0ca81000      4K rw-s-  /dev/dri/card0
00007f8c0ca82000      4K rw-s-  /dev/dri/card0
00007f8c0ca83000      4K rw-s-  /dev/dri/card0
00007f8c0ca84000      4K rw-s-  /dev/dri/card0
00007f8c0ca85000      4K rw-s-  /dev/dri/card0
00007f8c0ca86000      4K rw-s-  /dev/dri/card0
00007f8c0ca87000      4K rw-s-  /dev/dri/card0
00007f8c0ca88000      4K rw-s-  /dev/dri/card0
00007f8c0ca89000    384K rw-s-    [ shmid=0xa0005 ]
00007f8c0cae9000      4K rw-s-  /dev/dri/card0
00007f8c0caea000      4K rw-s-  /dev/dri/card0
00007f8c0caeb000      4K rw-s-  /dev/dri/card0
00007f8c0caec000      4K rw-s-  /dev/dri/card0
00007f8c0caed000      4K rw-s-  /dev/dri/card0
00007f8c0caee000      4K rw-s-  /dev/dri/card0
00007f8c0caef000      4K rw-s-  /dev/dri/card0
00007f8c0caf0000      4K rw-s-  /dev/dri/card0
00007f8c0caf1000      4K rw-s-  /dev/dri/card0
00007f8c0caf2000      4K rw-s-  /dev/dri/card0
00007f8c0caf3000      4K rw-s-  /dev/dri/card0
00007f8c0caf4000      4K rw-s-  /dev/dri/card0
00007f8c0caf5000      4K rw-s-  /dev/dri/card0
00007f8c0caf6000      4K rw-s-  /dev/dri/card0
00007f8c0caf7000      4K rw-s-  /dev/dri/card0
00007f8c0caf8000      4K rw-s-  /dev/dri/card0
00007f8c0caf9000      4K rw-s-  /dev/dri/card0
00007f8c0cafa000      4K rw-s-  /dev/dri/card0
00007f8c0cafb000      4K rw-s-  /dev/dri/card0
00007f8c0cafc000      4K rw-s-  /dev/dri/card0
00007f8c0cafd000      4K rw-s-  /dev/dri/card0
00007f8c0cafe000      4K rw-s-  /dev/dri/card0
00007f8c0caff000      4K rw-s-  /dev/dri/card0
00007f8c0cb00000      4K rw-s-  /dev/dri/card0
00007f8c0cb01000      4K rw-s-  /dev/dri/card0
00007f8c0cb02000      4K rw-s-  /dev/dri/card0
00007f8c0cb03000      4K rw-s-  /dev/dri/card0
00007f8c0cb04000      4K rw-s-  /dev/dri/card0
00007f8c0cb05000      4K rw-s-  /dev/dri/card0
00007f8c0cb06000      4K rw-s-  /dev/dri/card0
00007f8c0cb07000      4K rw-s-  /dev/dri/card0
00007f8c0cb08000      4K rw-s-  /dev/dri/card0
00007f8c0cb09000      4K rw-s-  /dev/dri/card0
00007f8c0cb0a000      4K rw-s-  /dev/dri/card0
00007f8c0cb0b000    264K rw---    [ anon ]
00007f8c0cb4d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb4e000     28K rw-s-  /drm mm object (deleted)
00007f8c0cb55000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb56000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb57000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb58000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb59000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb5f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb60000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb61000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb62000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb63000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb64000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb65000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb66000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb67000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb68000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb69000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb6f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb70000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb71000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb72000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb73000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb74000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb75000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb76000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb77000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb78000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb79000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb7f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb80000     24K rw---    [ anon ]
00007f8c0cb86000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb87000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb88000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb89000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8c000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8d000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8e000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb8f000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb90000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb91000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb92000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb93000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb94000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb95000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb96000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb97000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb98000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb99000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9a000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9b000      4K rw-s-  /drm mm object (deleted)
00007f8c0cb9c000     12K rw---    [ anon ]
00007f8c0cb9f000      4K r----  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0cba0000      4K rw---  /lib/x86_64-linux-gnu/ld-2.13.so
00007f8c0cba1000      4K rw---    [ anon ]
00007f8c0cba2000   1956K r-x--  /usr/bin/Xorg
00007f8c0cf8a000     12K r----  /usr/bin/Xorg
00007f8c0cf8d000     44K rw---  /usr/bin/Xorg
00007f8c0cf98000     76K rw---    [ anon ]
00007f8c0e9c6000   7108K rw---    [ anon ]
00007fffadf48000    132K rw---    [ stack ]
00007fffadffc000      4K r-x--    [ anon ]
ffffffffff600000      4K r-x--    [ anon ]
  total           124132K

>
> thanks,
> suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
