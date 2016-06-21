Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45029828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:25:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l81so52979150qke.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:25:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id r85si19943474ywg.56.2016.06.21.08.25.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 08:25:36 -0700 (PDT)
Message-ID: <57695AEB.8030509@huawei.com>
Date: Tue, 21 Jun 2016 23:19:07 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/huge_memory: fix the memory leak due to the race
References: <1466517956-13875-1-git-send-email-zhongjiang@huawei.com> <20160621143701.GA6139@node.shutemov.name>
In-Reply-To: <20160621143701.GA6139@node.shutemov.name>
Content-Type: multipart/alternative;
	boundary="------------030506050708040908070402"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--------------030506050708040908070402
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 2016/6/21 22:37, Kirill A. Shutemov wrote:
> On Tue, Jun 21, 2016 at 10:05:56PM +0800, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> with great pressure, I run some test cases. As a result, I found
>> that the THP is not freed, it is detected by check_mm().
>>
>> BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512
>>
>> Consider the following race :
>>
>> 	CPU0                               CPU1
>>   __handle_mm_fault()
>>         wp_huge_pmd()
>>    	    do_huge_pmd_wp_page()
>> 		pmdp_huge_clear_flush_notify()
>>                 (pmd_none = true)
>> 					exit_mmap()
>> 					   unmap_vmas()
>> 					     zap_pmd_range()
>> 						pmd_none_or_trans_huge_or_clear_bad()
>> 						   (result in memory leak)
>>                 set_pmd_at()
>>
>> because of CPU0 have allocated huge page before pmdp_huge_clear_notify,
>> and it make the pmd entry to be null. Therefore, The memory leak can occur.
>>
>> The patch fix the scenario that the pmd entry can lead to be null.
> I don't think the scenario is possible.
>
> exit_mmap() called when all mm users have gone, so no parallel threads
> exist.
>
 Forget  this patch.  It 's my fault , it indeed don not exist.
 But I  hit the following problem.  we can see the memory leak when the process exit.
 
 
 Any suggestion will be apprecaited.
 Thanks
 zhongjiang

Authorized users only. All activities may be monitored and reported.
cluster-103 login: [23966.710772] mm/pgtable-generic.c:33: bad pmd ffff88217f4bdcd8(0000012c4d6001e2)
[29611.096341] BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512
[29611.103071] BUG: non-zero nr_ptes on freeing mm: 1
[35333.076266] mm/pgtable-generic.c:33: bad pmd ffff88218c2719c8(0000012ed7a001e2)
[35929.241588] mm/pgtable-generic.c:33: bad pmd ffff8811ba295bb8(0000092cd10001e2)
[36398.205178] mm/pgtable-generic.c:33: bad pmd ffff8821b94a4f20(00000014bae001e2)
[36469.518251] mm/pgtable-generic.c:33: bad pmd ffff8827dc401e78(0000190e000001e2)
[37856.015724] mm/pgtable-generic.c:33: bad pmd ffff8821a7468a68(0000032d40e001e2)
[40630.459617] mm/pgtable-generic.c:33: bad pmd ffff8820a53b4f68(000001264aa001e2)
[41973.235225] mm/pgtable-generic.c:33: bad pmd ffff8827d57d3b48(00000926f86001e2)
[42943.434794] mm/pgtable-generic.c:33: bad pmd ffff8827d14b4d40(000009268b6001e2)
[43142.718195] mm/pgtable-generic.c:33: bad pmd ffff8827e8efb0f8(00000014f8a001e2)
[43366.878885] mm/pgtable-generic.c:33: bad pmd ffff8827fc40e000(00000013cb8001e2)
[44153.258076] mm/pgtable-generic.c:33: bad pmd ffff8821aa8fee88(0000082f07e001e2)
[44693.401966] mm/pgtable-generic.c:33: bad pmd ffff8814a55d1dc0(0000092f558001e2)
[44835.648216] general protection fault: 0000 [#1] SMP
i tg3 libahci ptp libata pps_core megaraid_sas dm_mirror dm_region_hash dm_log dm_mod
[44835.698547] CPU: 366 PID: 613011 Comm: sh Not tainted 4.5.0-bisect+ #7
[44835.705073] Hardware name: To be filled by O.E.M. FusionServer9032/IT91SMUB, BIOS BLXSV102 04/26/2016
[44835.714289] task: ffff882813bc8000 ti: ffff8827fb7bc000 task.ti: ffff8827fb7bc000
[44835.721768] RIP: 0010:[<ffffffff8169aaef>] [<ffffffff8169aaef>] down_write+0x1f/0x40
[44835.729687] RSP: 0018:ffff8827fb7bfb48 EFLAGS: 00010246
[44835.735000] RAX: 8000082fddd9a02f RBX: 8000082fddd9a02f RCX: ffffea04b1358000
[44835.742127] RDX: ffffffff00000001 RSI: ffff88219bb8a760 RDI: 8000082fddd9a02f
[44835.749250] RBP: ffff8827fb7bfb50 R08: ffffffff81a64bf0 R09: ffffffff81a68c90
[44835.756379] R10: ffffffff81a68c7f R11: 0000000000000000 R12: 0000000000000000
[44835.763501] R13: ffffea0031f585c0 R14: ffffea04b1f50200 R15: ffffea04b1358000
[44835.770630] FS: 00007f0514771740(0000) GS:ffff8828f0e80000(0000) knlGS:0000000000000000
[44835.778698] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[44835.784445] CR2: 00007f0514778000 CR3: 00000021715fd000 CR4: 00000000001406e0
[44835.791577] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[44835.798701] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[44835.805823] Stack:
[44835.807859] ffffea04b1358000 ffff8827fb7bfc08 ffffffff811f5346 ffff8827cf0de180
[44835.815349] 0000000000f38713 ffff8827fb7bfbc8 ffffffff811c4a4f ffff8827d15f3c30
[44835.822844] 000000000000062d 000000000062d000 ffff882ffffbc000 ffffea04b1357fc0
[44835.830346] Call Trace:
[44835.832900] [<ffffffff811f5346>] split_huge_page_to_list+0x66/0xa20
[44835.839314] [<ffffffff811c4a4f>] ? rmap_walk+0x28f/0x3a0
[44835.844742] [<ffffffff811ed6ec>] migrate_pages+0x8dc/0x950
[44835.850364] [<ffffffff812023f0>] ? test_pages_isolated+0x1d0/0x1d0
[44835.856683] [<ffffffff816926db>] __offline_pages.constprop.28+0x4bb/0x7f0
[44835.863595] [<ffffffff811eac11>] offline_pages+0x11/0x20
[44835.869033] [<ffffffff81475527>] memory_subsys_offline+0x47/0x70
[44835.875184] [<ffffffff8145e10a>] device_offline+0x8a/0xb0
[44835.880696] [<ffffffff814752d6>] store_mem_state+0xc6/0xe0
[44835.886309] [<ffffffff8145b228>] dev_attr_store+0x18/0x30
[44835.891857] [<ffffffff8128958a>] sysfs_kf_write+0x3a/0x50
[44835.897361] [<ffffffff81288bf0>] kernfs_fop_write+0x120/0x170
[44835.903243] [<ffffffff8120b3f7>] __vfs_write+0x37/0x100
[44835.908609] [<ffffffff812b71dd>] ? security_file_permission+0x3d/0xc0
[44835.915209] [<ffffffff810c973f>] ? percpu_down_read+0x1f/0x50
[44835.921084] [<ffffffff8120c322>] vfs_write+0xa2/0x1a0
[44835.926276] [<ffffffff81003176>] ? do_audit_syscall_entry+0x66/0x70
[44835.932654] [<ffffffff8120d265>] SyS_write+0x55/0xc0
[44835.937723] [<ffffffff8169c66e>] entry_SYSCALL_64_fastpath+0x12/0x71

--------------030506050708040908070402
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    On 2016/6/21 22:37, Kirill A. Shutemov wrote:
    <blockquote cite="mid:20160621143701.GA6139@node.shutemov.name"
      type="cite">
      <pre wrap="">On Tue, Jun 21, 2016 at 10:05:56PM +0800, zhongjiang wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">From: zhong jiang <a class="moz-txt-link-rfc2396E" href="mailto:zhongjiang@huawei.com">&lt;zhongjiang@huawei.com&gt;</a>

with great pressure, I run some test cases. As a result, I found
that the THP is not freed, it is detected by check_mm().

BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512

Consider the following race :

	CPU0                               CPU1
  __handle_mm_fault()
        wp_huge_pmd()
   	    do_huge_pmd_wp_page()
		pmdp_huge_clear_flush_notify()
                (pmd_none = true)
					exit_mmap()
					   unmap_vmas()
					     zap_pmd_range()
						pmd_none_or_trans_huge_or_clear_bad()
						   (result in memory leak)
                set_pmd_at()

because of CPU0 have allocated huge page before pmdp_huge_clear_notify,
and it make the pmd entry to be null. Therefore, The memory leak can occur.

The patch fix the scenario that the pmd entry can lead to be null.
</pre>
      </blockquote>
      <pre wrap="">
I don't think the scenario is possible.

exit_mmap() called when all mm users have gone, so no parallel threads
exist.

</pre>
    </blockquote>
    <blockquote cite="mid:20160621143701.GA6139@node.shutemov.name"
      type="cite">
    </blockquote>
    <font style="FONT-SIZE: 14px" color="#ff0080" face="&#24494;&#36719;&#38597;&#40657;">&nbsp;Forget&nbsp;
      this patch.&nbsp; It 's my fault , it indeed don not exist. <br>
      &nbsp;But I&nbsp; hit the following problem.&nbsp; we can see the memory leak
      when the process exit.<br>
      &nbsp;<br>
      &nbsp;<br>
      &nbsp;Any suggestion will be apprecaited. <br>
      &nbsp;Thanks<br>
      &nbsp;zhongjiang<br>
      <br>
      Authorized users only. All activities may be monitored and
      reported.<br>
      cluster-103 login: [23966.710772] mm/pgtable-generic.c:33: bad pmd
      ffff88217f4bdcd8(0000012c4d6001e2)<br>
      [29611.096341] BUG: Bad rss-counter state mm:ffff8827edb70000
      idx:1 val:512<br>
      [29611.103071] BUG: non-zero nr_ptes on freeing mm: 1<br>
      [35333.076266] mm/pgtable-generic.c:33: bad pmd
      ffff88218c2719c8(0000012ed7a001e2)<br>
      [35929.241588] mm/pgtable-generic.c:33: bad pmd
      ffff8811ba295bb8(0000092cd10001e2)<br>
      [36398.205178] mm/pgtable-generic.c:33: bad pmd
      ffff8821b94a4f20(00000014bae001e2)<br>
      [36469.518251] mm/pgtable-generic.c:33: bad pmd
      ffff8827dc401e78(0000190e000001e2)<br>
      [37856.015724] mm/pgtable-generic.c:33: bad pmd
      ffff8821a7468a68(0000032d40e001e2)<br>
      [40630.459617] mm/pgtable-generic.c:33: bad pmd
      ffff8820a53b4f68(000001264aa001e2)<br>
      [41973.235225] mm/pgtable-generic.c:33: bad pmd
      ffff8827d57d3b48(00000926f86001e2)<br>
      [42943.434794] mm/pgtable-generic.c:33: bad pmd
      ffff8827d14b4d40(000009268b6001e2)<br>
      [43142.718195] mm/pgtable-generic.c:33: bad pmd
      ffff8827e8efb0f8(00000014f8a001e2)<br>
      [43366.878885] mm/pgtable-generic.c:33: bad pmd
      ffff8827fc40e000(00000013cb8001e2)<br>
      [44153.258076] mm/pgtable-generic.c:33: bad pmd
      ffff8821aa8fee88(0000082f07e001e2)<br>
      [44693.401966] mm/pgtable-generic.c:33: bad pmd
      ffff8814a55d1dc0(0000092f558001e2)<br>
      [44835.648216] general protection fault: 0000 [#1] SMP <br>
      i tg3 libahci ptp libata pps_core megaraid_sas dm_mirror
      dm_region_hash dm_log dm_mod<br>
      [44835.698547] CPU: 366 PID: 613011 Comm: sh Not tainted
      4.5.0-bisect+ #7<br>
      [44835.705073] Hardware name: To be filled by O.E.M.
      FusionServer9032/IT91SMUB, BIOS BLXSV102 04/26/2016<br>
      [44835.714289] task: ffff882813bc8000 ti: ffff8827fb7bc000
      task.ti: ffff8827fb7bc000<br>
      [44835.721768] RIP: 0010:[&lt;ffffffff8169aaef&gt;]
      [&lt;ffffffff8169aaef&gt;] down_write+0x1f/0x40<br>
      [44835.729687] RSP: 0018:ffff8827fb7bfb48 EFLAGS: 00010246<br>
      [44835.735000] RAX: 8000082fddd9a02f RBX: 8000082fddd9a02f RCX:
      ffffea04b1358000<br>
      [44835.742127] RDX: ffffffff00000001 RSI: ffff88219bb8a760 RDI:
      8000082fddd9a02f<br>
      [44835.749250] RBP: ffff8827fb7bfb50 R08: ffffffff81a64bf0 R09:
      ffffffff81a68c90<br>
      [44835.756379] R10: ffffffff81a68c7f R11: 0000000000000000 R12:
      0000000000000000<br>
      [44835.763501] R13: ffffea0031f585c0 R14: ffffea04b1f50200 R15:
      ffffea04b1358000<br>
      [44835.770630] FS: 00007f0514771740(0000)
      GS:ffff8828f0e80000(0000) knlGS:0000000000000000<br>
      [44835.778698] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
      [44835.784445] CR2: 00007f0514778000 CR3: 00000021715fd000 CR4:
      00000000001406e0<br>
      [44835.791577] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
      0000000000000000<br>
      [44835.798701] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
      0000000000000400<br>
      [44835.805823] Stack:<br>
      [44835.807859] ffffea04b1358000 ffff8827fb7bfc08 ffffffff811f5346
      ffff8827cf0de180<br>
      [44835.815349] 0000000000f38713 ffff8827fb7bfbc8 ffffffff811c4a4f
      ffff8827d15f3c30<br>
      [44835.822844] 000000000000062d 000000000062d000 ffff882ffffbc000
      ffffea04b1357fc0<br>
      [44835.830346] Call Trace:<br>
      [44835.832900] [&lt;ffffffff811f5346&gt;]
      split_huge_page_to_list+0x66/0xa20<br>
      [44835.839314] [&lt;ffffffff811c4a4f&gt;] ? rmap_walk+0x28f/0x3a0<br>
      [44835.844742] [&lt;ffffffff811ed6ec&gt;]
      migrate_pages+0x8dc/0x950<br>
      [44835.850364] [&lt;ffffffff812023f0&gt;] ?
      test_pages_isolated+0x1d0/0x1d0<br>
      [44835.856683] [&lt;ffffffff816926db&gt;]
      __offline_pages.constprop.28+0x4bb/0x7f0<br>
      [44835.863595] [&lt;ffffffff811eac11&gt;] offline_pages+0x11/0x20<br>
      [44835.869033] [&lt;ffffffff81475527&gt;]
      memory_subsys_offline+0x47/0x70<br>
      [44835.875184] [&lt;ffffffff8145e10a&gt;] device_offline+0x8a/0xb0<br>
      [44835.880696] [&lt;ffffffff814752d6&gt;]
      store_mem_state+0xc6/0xe0<br>
      [44835.886309] [&lt;ffffffff8145b228&gt;] dev_attr_store+0x18/0x30<br>
      [44835.891857] [&lt;ffffffff8128958a&gt;] sysfs_kf_write+0x3a/0x50<br>
      [44835.897361] [&lt;ffffffff81288bf0&gt;]
      kernfs_fop_write+0x120/0x170<br>
      [44835.903243] [&lt;ffffffff8120b3f7&gt;] __vfs_write+0x37/0x100<br>
      [44835.908609] [&lt;ffffffff812b71dd&gt;] ?
      security_file_permission+0x3d/0xc0<br>
      [44835.915209] [&lt;ffffffff810c973f&gt;] ?
      percpu_down_read+0x1f/0x50<br>
      [44835.921084] [&lt;ffffffff8120c322&gt;] vfs_write+0xa2/0x1a0<br>
      [44835.926276] [&lt;ffffffff81003176&gt;] ?
      do_audit_syscall_entry+0x66/0x70<br>
      [44835.932654] [&lt;ffffffff8120d265&gt;] SyS_write+0x55/0xc0<br>
      [44835.937723] [&lt;ffffffff8169c66e&gt;]
      entry_SYSCALL_64_fastpath+0x12/0x71<br>
    </font>
  </body>
</html>

--------------030506050708040908070402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
