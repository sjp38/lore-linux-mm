From: Xishi Qiu <qiuxishi@huawei.com>
Subject: mm, we use rcu access task_struct in mm_match_cgroup(), but not use
 rcu free in free_task_struct()
Date: Wed, 24 May 2017 09:40:55 +0800
Message-ID: <5924E4A7.7000601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "wencongyang (A)" <wencongyang2@huawei.com>
List-Id: linux-mm.kvack.org

Hi, I find we use rcu access task_struct in mm_match_cgroup(), but not use
rcu free in free_task_struct(), is it right?

Here is the backtrace.

PID: 2133   TASK: ffff881fe3353300  CPU: 2   COMMAND: "CPU 15/KVM"
 #0 [ffff881fe276b528] machine_kexec at ffffffff8105280b
 #1 [ffff881fe276b588] crash_kexec at ffffffff810f5072
 #2 [ffff881fe276b658] panic at ffffffff8163e23b
 #3 [ffff881fe276b6d8] oops_end at ffffffff8164d61b
 #4 [ffff881fe276b700] die at ffffffff8101872b
 #5 [ffff881fe276b730] do_general_protection at ffffffff8164cefe
 #6 [ffff881fe276b760] general_protection at ffffffff8164c7a8
    [exception RIP: mem_cgroup_from_task+22]
    RIP: ffffffff811db536  RSP: ffff881fe276b810  RFLAGS: 00010286
    RAX: 6b6b6b6b6b6b6b6b  RBX: ffffea007f988880  RCX: 0000000000020000
    RDX: 00000007fa607d67  RSI: 00000007fa607d67  RDI: ffff880fe36d72c0
    RBP: ffff881fe276b880   R8: 00000007fa607600   R9: a801fd67b3000000
    R10: 57fdec98cc59ecc0  R11: ffff880fe2e8dbd0  R12: ffffc9001cb74000
    R13: ffff881fdb8cfda0  R14: ffff881fe2581570  R15: 00000007fa607d67
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
 #7 [ffff881fe276b810] page_referenced at ffffffff811a6b8a
 #8 [ffff881fe276b888] shrink_page_list at ffffffff81180994
 #9 [ffff881fe276b9c0] shrink_inactive_list at ffffffff8118166a
#10 [ffff881fe276ba88] shrink_lruvec at ffffffff81182135
#11 [ffff881fe276bb88] shrink_zone at ffffffff81182596
#12 [ffff881fe276bbe0] do_try_to_free_pages at ffffffff81182a90
#13 [ffff881fe276bc58] try_to_free_mem_cgroup_pages at ffffffff81182fea
#14 [ffff881fe276bcf0] mem_cgroup_reclaim at ffffffff811dd8de
#15 [ffff881fe276bd30] __mem_cgroup_try_charge at ffffffff811ddd9c
#16 [ffff881fe276bdf0] __mem_cgroup_try_charge_swapin at ffffffff811df62b
#17 [ffff881fe276be28] mem_cgroup_try_charge_swapin at ffffffff811e0537
#18 [ffff881fe276be38] handle_mm_fault at ffffffff8119abdd
#19 [ffff881fe276bec8] __do_page_fault at ffffffff816502d6
#20 [ffff881fe276bf28] do_page_fault at ffffffff81650603
#21 [ffff881fe276bf50] page_fault at ffffffff8164c808
    RIP: 00007fdaba456500  RSP: 00007fdaaba6c978  RFLAGS: 00010246
    RAX: ffffffffffffffff  RBX: 0000000000000000  RCX: fffffffffffffbd0
    RDX: 0000000000000000  RSI: 000000000000ae80  RDI: 000000000000002c
    RBP: 00007fdaaba6c9f0   R8: 0000000000840c70   R9: 00000000000000be
    R10: 000000007fffffff  R11: 0000000000000246  R12: 0000000003622010
    R13: 000000000000ae80  R14: 00000000008274e0  R15: 0000000003622010
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
