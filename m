Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id DAB536B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:11:35 -0400 (EDT)
Message-ID: <5016DC5F.7030604@redhat.com>
Date: Mon, 30 Jul 2012 15:11:27 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com> <50120FA8.20409@redhat.com> <20120727102356.GD612@suse.de>
In-Reply-To: <20120727102356.GD612@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/27/2012 06:23 AM, Mel Gorman wrote:
> On Thu, Jul 26, 2012 at 11:48:56PM -0400, Larry Woodman wrote:
>> On 07/26/2012 02:37 PM, Rik van Riel wrote:
>>> On 07/23/2012 12:04 AM, Hugh Dickins wrote:
>>>
>>>> I spent hours trying to dream up a better patch, trying various
>>>> approaches.  I think I have a nice one now, what do you think?  And
>>>> more importantly, does it work?  I have not tried to test it at all,
>>>> that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
>>>>
>>>> If you like it, please take it over and add your comments and signoff
>>>> and send it in.  The second part won't come up in your testing,
>>>> and could
>>>> be made a separate patch if you prefer: it's a related point that struck
>>>> me while I was playing with a different approach.
>>>>
>>>> I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
>>>> but that too would be unfair.
>>>>
>>>> Subject-to-your-testing-
>>>> Signed-off-by: Hugh Dickins<hughd@google.com>
>>> This patch looks good to me.
>>>
>>> Larry, does Hugh's patch survive your testing?
>>>
>>>
>> Like I said earlier, no.
> That is a surprise. Can you try your test case on 3.4 and tell us if the
> patch fixes the problem there? I would like to rule out the possibility
> that the locking rules are slightly different in RHEL. If it hits on 3.4
> then it's also possible you are seeing a different bug, more on this later.
>

Sorry for the delay Mel, here is the BUG() traceback from the 3.4 kernel 
with your
patches:

--------------------------------------------------------------------------------------------------------------------------------------------
[ 1106.156569] ------------[ cut here ]------------
[ 1106.161731] kernel BUG at mm/filemap.c:135!
[ 1106.166395] invalid opcode: 0000 [#1] SMP
[ 1106.170975] CPU 22
[ 1106.173115] Modules linked in: bridge stp llc sunrpc binfmt_misc 
dcdbas microcode pcspkr acpi_pad acpi]
[ 1106.201770]
[ 1106.203426] Pid: 18001, comm: mpitest Tainted: G        W    3.3.0+ 
#4 Dell Inc. PowerEdge R620/07NDJ2
[ 1106.213822] RIP: 0010:[<ffffffff8112cfed>]  [<ffffffff8112cfed>] 
__delete_from_page_cache+0x15d/0x170
[ 1106.224117] RSP: 0018:ffff880428973b88  EFLAGS: 00010002
[ 1106.230032] RAX: 0000000000000001 RBX: ffffea0006b80000 RCX: 
00000000ffffffb0
[ 1106.237979] RDX: 0000000000016df1 RSI: 0000000000000009 RDI: 
ffff88043ffd9e00
[ 1106.245927] RBP: ffff880428973b98 R08: 0000000000000050 R09: 
0000000000000003
[ 1106.253876] R10: 000000000000000d R11: 0000000000000000 R12: 
ffff880428708150
[ 1106.261826] R13: ffff880428708150 R14: 0000000000000000 R15: 
ffffea0006b80000
[ 1106.269780] FS:  0000000000000000(0000) GS:ffff88042fd60000(0000) 
knlGS:0000000000000000
[ 1106.278794] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1106.285193] CR2: 0000003a1d38c4a8 CR3: 000000000187d000 CR4: 
00000000000406e0
[ 1106.293149] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1106.301097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1106.309046] Process mpitest (pid: 18001, threadinfo ffff880428972000, 
task ffff880428b5cc20)
[ 1106.318447] Stack:
[ 1106.320690]  ffffea0006b80000 0000000000000000 ffff880428973bc8 
ffffffff8112d040
[ 1106.328958]  ffff880428973bc8 00000000000002ab 00000000000002a0 
ffff880428973c18
[ 1106.337234]  ffff880428973cc8 ffffffff8125b405 ffff880400000001 
0000000000000000
[ 1106.345513] Call Trace:
[ 1106.348235]  [<ffffffff8112d040>] delete_from_page_cache+0x40/0x80
[ 1106.355128]  [<ffffffff8125b405>] truncate_hugepages+0x115/0x1f0
[ 1106.361826]  [<ffffffff8125b4f8>] hugetlbfs_evict_inode+0x18/0x30
[ 1106.368615]  [<ffffffff811ab1af>] evict+0x9f/0x1b0
[ 1106.373951]  [<ffffffff811ab3a3>] iput_final+0xe3/0x1e0
[ 1106.379773]  [<ffffffff811ab4de>] iput+0x3e/0x50
[ 1106.384922]  [<ffffffff811a8e18>] d_kill+0xf8/0x110
[ 1106.390356]  [<ffffffff811a8f12>] dput+0xe2/0x1b0
[ 1106.395595]  [<ffffffff81193612>] __fput+0x162/0x240
[ 1106.401124]  [<ffffffff81193715>] fput+0x25/0x30
[ 1106.406265]  [<ffffffff8118f6c3>] filp_close+0x63/0x90
[ 1106.411997]  [<ffffffff8106058f>] put_files_struct+0x7f/0xf0
[ 1106.418302]  [<ffffffff8106064c>] exit_files+0x4c/0x60
[ 1106.424025]  [<ffffffff810629d7>] do_exit+0x1a7/0x470
[ 1106.429652]  [<ffffffff81062cf5>] do_group_exit+0x55/0xd0
[ 1106.435665]  [<ffffffff81062d87>] sys_exit_group+0x17/0x20
[ 1106.441777]  [<ffffffff815d0229>] system_call_fastpath+0x16/0x1b
[ 1106.448474] Code: 66 0f 1f 44 00 00 48 8b 47 08 48 8b 00 48 8b 40 28 
44 8b 80 38 03 00 00 45 85 c0 0f
[ 1106.470022] RIP  [<ffffffff8112cfed>] 
__delete_from_page_cache+0x15d/0x170
[ 1106.477693]  RSP <ffff880428973b88>
--------------------------------------------------------------------------------------------------------------------------------------

I'll see if I can distribute the program that causes the panic, I dont 
have source, only binary.

Larry


BTW, the only way Ilve been able to get the panic to stop is:

--------------------------------------------------------------------------------------------------------------------------------------
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c36febb..cc023b8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2151,7 +2151,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, 
struct mm_struct *src,
                         goto nomem;

                 /* If the pagetables are shared don't copy or take 
references */
-               if (dst_pte == src_pte)
+               if (*(unsigned long *)dst_pte == *(unsigned long *)src_pte)
                         continue;
                 spin_lock(&dst->page_table_lock);
---------------------------------------------------------------------------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
