Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.56.224.149])
	by e1.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g9AL35kC294940
	for <linux-mm@kvack.org>; Thu, 10 Oct 2002 17:03:06 -0400
Received: from localhost.localdomain (plars.austin.ibm.com [9.53.216.72])
	by northrelay01.pok.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id g9AL33U9213720
	for <linux-mm@kvack.org>; Thu, 10 Oct 2002 17:03:03 -0400
Subject: 2.5.41-mm2 BUG at mm/memory.c:275
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 10 Oct 2002 15:57:22 -0500
Message-Id: <1034283443.30975.97.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I was running ltp on 2.5.41-mm2 and got this new bug.  This was on the
same machine, 8-way PIII-700 16GB. The only two changes in the config
since mm1 were max cpu's set to 8, shared pte on, turned on slab debug
and -g in CCFLAGS.

kernel BUG at mm/memory.c:275!
invalid operand: 0000

CPU:    3
EIP:    0060:[<c012a336>]    Not tainted
EFLAGS: 00010287
EIP is at pte_unshare+0x216/0x630
eax: f6dab5a4   ebx: f7c8b70c   ecx: 4ca00000   edx: f7c8b70c
esi: f7c8b70c   edi: cb8d2450   ebp: 4c906000   esp: f1cd1e38
ds: 0068   es: 0068   ss: 0068
Process mmstress (pid: 4229, threadinfo=f1cd0000 task=f7c920a0)
Stack: f1d764a0 00000012 4ca00000 00000008 4c800000 4c800000 f6dab5a4
cbc16584
       cb8d2450 00000286 c03580e0 00000000 f1cd1e9c f1cd1ea4 c0475b68
c013921b
       c03580e0 00000001 00000001 d63bc065 00000003 f1d76320 4c906000
c012b0ae
Call Trace:
 [<c013921b>] __pagevec_free+0x1b/0x30
 [<c012b0ae>] zap_pte_range+0x19e/0x410
 [<c012b38c>] zap_pmd_range+0x6c/0x80
 [<c012b3e0>] unmap_page_range+0x40/0x60
 [<c012e7a5>] unmap_region+0xd5/0x160
 [<c012ea3c>] do_munmap+0xdc/0x100
 [<c012eaa4>] sys_munmap+0x44/0x70
 [<c01071d3>] syscall_call+0x7/0xb

Code: 0f 0b 13 01 b9 75 2f c0 8b 7c 24 20 8b 47 04 c7 44 24 04 00

It looks like it was running mmstress at the time the error occurred. 
Here was the last output I had from the test execution:

INFO: run mmstress -h for all options

        test1: Test case tests the race condition between
                simultaneous read faults in the same address space.
        test2: Test case tests the race condition between
                simultaneous write faults in the same address space.
        test3: Test case tests the race condition between
                simultaneous COW faults in the same address space.
        test4: Test case tests the race condition between
                simultaneous READ faults in the same address space.
                The file maped is /dev/zero
        test5: Test case tests the race condition between
                simultaneous fork - exit faults in the same address
space.

Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
