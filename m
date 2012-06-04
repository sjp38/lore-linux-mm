Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3634A6B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 07:46:07 -0400 (EDT)
Date: Mon, 4 Jun 2012 19:46:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: kvm segfaults and bad page state in 3.4.0
Message-ID: <20120604114603.GA6988@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

I'm running lots of kvm instances for doing kernel boot tests.
Unfortunately the test system itself is not stable enough, I got scary
errors in both kvm and the host kernel. Like this. 

[294025.795382] kvm used greatest stack depth: 2896 bytes left
[310388.622083] kvm[1864]: segfault at c ip 00007f498e9f6a81 sp 00007f4994b9fca0 error 4 in kvm[7f498e960000+33b000]
[310692.050589] kvm[4332]: segfault at 10 ip 00007fca662620b9 sp 00007fca70472af0 error 6 in kvm[7fca661cc000+33b000]
[312608.950120] kvm[18931]: segfault at 8 ip 00007f95962a10a5 sp 00007f959d777170 error 4 in kvm[7f959620b000+33b000]
[312622.941640] kvm[19123]: segfault at 10 ip 00007f406f5580b9 sp 00007f4077d8b350 error 6 in kvm[7f406f4c2000+33b000]
[313917.860951] kvm[28789]: segfault at c ip 00007f718f4dfa81 sp 00007f7198459520 error 4 in kvm[7f718f449000+33b000]
[313919.177192] kvm used greatest stack depth: 2864 bytes left
[314061.390945] kvm used greatest stack depth: 2208 bytes left
[327479.676068] BUG: Bad page state in process kvm  pfn:59ac9
[327479.676455] page:ffffea000166b240 count:0 mapcount:0 mapping:          (null) index:0x7fd346bc6
[327479.677083] page flags: 0x100000000000014(referenced|dirty)
[327479.677575] Modules linked in:
[327479.677897] Pid: 11423, comm: kvm Not tainted 3.4.0 #131
[327479.678272] Call Trace:
[327479.678538]  [<ffffffff81107343>] bad_page+0xe6/0xfb
[327479.678897]  [<ffffffff811079c6>] get_page_from_freelist+0x534/0x6f6
[327479.679314]  [<ffffffff81107d92>] __alloc_pages_nodemask+0x20a/0x75e
[327479.679729]  [<ffffffff8108e121>] ? finish_task_switch+0x4c/0xf6
[327479.680136]  [<ffffffff81143477>] ? lookup_page_cgroup_used+0xe/0x24
[327479.680548]  [<ffffffff811079b5>] ? get_page_from_freelist+0x523/0x6f6
[327479.680970]  [<ffffffff811367c8>] alloc_pages_current+0xd2/0xf3
[327479.681369]  [<ffffffff811012e4>] __page_cache_alloc+0xa1/0xae
[327479.681761]  [<ffffffff8110b144>] __do_page_cache_readahead+0x107/0x20b
[327479.682188]  [<ffffffff8110b0cc>] ? __do_page_cache_readahead+0x8f/0x20b
[327479.682615]  [<ffffffff811293b0>] ? anon_vma_prepare+0xb4/0x137
[327479.683010]  [<ffffffff8110b521>] ra_submit+0x21/0x25
[327479.683375]  [<ffffffff81102f7a>] filemap_fault+0x18a/0x383
[327479.683757]  [<ffffffff8111d6b3>] __do_fault+0xc8/0x451
[327479.684128]  [<ffffffff81120103>] handle_pte_fault+0x2de/0x844
[327479.684522]  [<ffffffff8114446e>] ? mem_cgroup_count_vm_event+0x1a/0x96
[327479.684944]  [<ffffffff811218ac>] handle_mm_fault+0x1a6/0x1bb
[327479.685339]  [<ffffffff819b8c12>] do_page_fault+0x405/0x42a
[327479.685722]  [<ffffffff8112619e>] ? do_mmap_pgoff+0x299/0x2f3
[327479.686115]  [<ffffffff813fe03d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[327479.686534]  [<ffffffff819b5b45>] page_fault+0x25/0x30
[327479.686898] Disabling lock debugging due to kernel taint

The same host kernel, in another test box:

[770644.256817] kvm_get_msr_common: 2123 callbacks suppressed
[770644.257475] kvm: 31889: cpu0 unhandled rdmsr: 0x2
[770644.258103] kvm: 31889: cpu0 unhandled rdmsr: 0x3
[770644.258707] kvm: 31889: cpu0 unhandled rdmsr: 0x4
[770644.259322] kvm: 31889: cpu0 unhandled rdmsr: 0x5
[770644.259914] kvm: 31889: cpu0 unhandled rdmsr: 0x6
[770644.260499] kvm: 31889: cpu0 unhandled rdmsr: 0x7
[770644.261108] kvm: 31889: cpu0 unhandled rdmsr: 0x8
[770644.261700] kvm: 31889: cpu0 unhandled rdmsr: 0x9
[770644.262302] kvm: 31889: cpu0 unhandled rdmsr: 0xa
[770644.262883] kvm: 31889: cpu0 unhandled rdmsr: 0xb
[909290.636655] kvm[31619]: segfault at 40 ip 00007fcb3d8c4254 sp 00007fcb41bcaec0 error 4 in kvm[7fcb3d82e000+33b000]

Please drop me hints if I can help debugging it (a week later, after
returning from LinuxCon Japan), thank you.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
