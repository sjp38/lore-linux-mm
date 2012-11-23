Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 3DE5A6B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 01:45:02 -0500 (EST)
Message-ID: <50AF1BEF.4050007@redhat.com>
Date: Fri, 23 Nov 2012 14:47:11 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] Latest numa/core release, v17
References: <1353624594-1118-1-git-send-email-mingo@kernel.org> <20121122225338.GA1226@gmail.com>
In-Reply-To: <20121122225338.GA1226@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 11/23/2012 06:53 AM, Ingo Molnar wrote:
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> This release mainly addresses one of the regressions Linus
>> (rightfully) complained about: the "4x JVM" SPECjbb run.
>>
>> [ Note to testers: if possible please still run with
>>    CONFIG_TRANSPARENT_HUGEPAGES=y enabled, to avoid the
>>    !THP regression that is still not fully fixed.
>>    It will be fixed next. ]
> I forgot to include the Git link:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

Hi Ingo, I tested the latest tip/master tree on 2 nodes with 8 
processors, closed CONFIG_TRANSPARENT_HUGEPAGE,
and found some issues:

one is that command `stress -i 20 -m 30 -v` caused some hung tasks:

------------- snip ---------------------------
[ 1726.278382] Node 0 DMA free:15880kB min:20kB low:24kB high:28kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15332kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB 
pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? yes
[ 1726.366825] lowmem_reserve[]: 0 1957 3973 3973
[ 1726.388610] Node 0 DMA32 free:10856kB min:2796kB low:3492kB 
high:4192kB active_anon:1479384kB inactive_anon:498788kB active_file:0kB 
inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:2004184kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB 
shmem:20kB slab_reclaimable:140kB slab_unreclaimable:96kB 
kernel_stack:8kB pagetables:80kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:3502066 all_unreclaimable? yes
[ 1726.490163] lowmem_reserve[]: 0 0 2016 2016
[ 1726.515235] Node 0 Normal free:2880kB min:2880kB low:3600kB 
high:4320kB active_anon:1453776kB inactive_anon:490196kB 
active_file:748kB inactive_file:1140kB unevictable:3740kB 
isolated(anon):0kB isolated(file):0kB present:2064384kB mlocked:3492kB 
dirty:0kB writeback:0kB mapped:2748kB shmem:2116kB 
slab_reclaimable:9260kB slab_unreclaimable:35880kB kernel_stack:1184kB 
pagetables:3308kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:3437106 all_unreclaimable? yes
[ 1726.629591] lowmem_reserve[]: 0 0 0 0
[ 1726.657650] Node 1 Normal free:5748kB min:5760kB low:7200kB 
high:8640kB active_anon:3383776kB inactive_anon:682376kB active_file:8kB 
inactive_file:340kB unevictable:8kB isolated(anon):384kB 
isolated(file):0kB present:4128768kB mlocked:8kB dirty:0kB writeback:0kB 
mapped:20kB shmem:12kB slab_reclaimable:9364kB 
slab_unreclaimable:13728kB kernel_stack:880kB pagetables:12492kB 
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:8696274 all_unreclaimable? yes
[ 1726.782732] lowmem_reserve[]: 0 0 0 0
[ 1726.814748] Node 0 DMA: 2*4kB 2*8kB 1*16kB 1*32kB 3*64kB 2*128kB 
0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15880kB
[ 1726.854951] Node 0 DMA32: 12*4kB 25*8kB 21*16kB 19*32kB 15*64kB 
8*128kB 4*256kB 1*512kB 0*1024kB 1*2048kB 1*4096kB = 10856kB
[ 1726.896378] Node 0 Normal: 556*4kB 11*8kB 6*16kB 7*32kB 2*64kB 
1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2888kB
[ 1726.937928] Node 1 Normal: 392*4kB 22*8kB 1*16kB 0*32kB 0*64kB 
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 5856kB
[ 1726.979519] 481162 total pagecache pages
[ 1727.013687] 479540 pages in swap cache
[ 1727.047898] Swap cache stats: add 2176770, delete 1697230, find 
701489/781867
[ 1727.085709] Free swap  = 4371040kB
[ 1727.119839] Total swap = 8175612kB
[ 1727.187872] 2097136 pages RAM
[ 1727.221789] 56226 pages reserved
[ 1727.256273] 1721904 pages shared
[ 1727.290826] 1549555 pages non-shared
[ 1727.325708] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents 
oom_score_adj name
[ 1727.366026] [  303]     0   303     9750      184      23 500         
-1000 systemd-udevd
[ 1727.407347] [  448]     0   448     6558      178      13 56         
-1000 auditd
[ 1727.447970] [  516]     0   516    61311      172      22 
105             0 rsyslogd
[ 1727.488827] [  519]     0   519    24696       35      15 
35             0 iscsiuio
[ 1727.529839] [  529]    81   529     8201      246      27 93          
-900 dbus-daemon
[ 1727.571553] [  530]     0   530     1264       93       9 
16             0 iscsid
[ 1727.612795] [  531]     0   531     1389      843       9 0           
-17 iscsid
[ 1727.654069] [  538]     0   538     1608      157      10 
29             0 mcelog
[ 1727.695659] [  543]     0   543     5906      138      16 
49             0 atd
[ 1727.736954] [  551]     0   551    30146      211      22 
123             0 crond
[ 1727.778589] [  569]     0   569    26612      223      83 
185             0 login
[ 1727.820932] [  587]     0   587    86085      334      84 
139             0 NetworkManager
[ 1727.863388] [  643]     0   643    21931      200      65 
171          -900 modem-manager
[ 1727.906015] [  644]     0   644     5812      183      16 
74             0 bluetoothd
[ 1727.948629] [  672]     0   672   118364      228     179 
1079             0 libvirtd
[ 1727.991230] [  691]     0   691    20059      189      40 198         
-1000 sshd
[ 1728.033700] [  996]     0   996    28950      196      17 
516             0 bash
[ 1728.076541] [ 1056]     0  1056     1803      112      10 
22             0 stress
[ 1728.119495] [ 1057]     0  1057     1803       27      10 
21             0 stress
[ 1728.162616] [ 1058]     0  1058    67340    54961     118 
12             0 stress
[ 1728.205521] [ 1059]     0  1059     1803       27      10 
21             0 stress
[ 1728.248414] [ 1060]     0  1060    67340    12209      35 
12             0 stress
[ 1728.291529] [ 1061]     0  1061     1803       27      10 
21             0 stress
[ 1728.335147] [ 1062]     0  1062    67340    23519      57 
12             0 stress
[ 1728.378537] [ 1063]     0  1063     1803       27      10 
21             0 stress
[ 1728.421877] [ 1064]     0  1064    67340     7673     138 
57944             0 stress
[ 1728.465325] [ 1065]     0  1065     1803       27      10 
21             0 stress
[ 1728.508955] [ 1066]     0  1066    67340       90      11 
12             0 stress
[ 1728.553187] [ 1067]     0  1067     1803       27      10 
21             0 stress
[ 1728.597554] [ 1068]     0  1068    67340    58628     126 
12             0 stress
[ 1728.640668] [ 1069]     0  1069     1803       27      10 
21             0 stress
[ 1728.683676] [ 1070]     0  1070    67340    59802     128 
12             0 stress
[ 1728.726534] [ 1071]     0  1071     1803       27      10 
21             0 stress
[ 1728.769082] [ 1072]     0  1072    67340     5924     138 
59693             0 stress
[ 1728.811455] [ 1073]     0  1073     1803       27      10 
21             0 stress
[ 1728.852798] [ 1074]     0  1074    67340    65103     138 
14             0 stress
[ 1728.892605] [ 1075]     0  1075     1803       27      10 
21             0 stress
[ 1728.931191] [ 1076]     0  1076    67340    60077     128 
13             0 stress
[ 1728.969491] [ 1077]     0  1077     1803       27      10 
21             0 stress
[ 1729.006394] [ 1078]     0  1078    67340    13262     138 
52355             0 stress
[ 1729.042189] [ 1079]     0  1079     1803       27      10 
21             0 stress
[ 1729.076890] [ 1080]     0  1080    67340    38640      87 
12             0 stress
[ 1729.111443] [ 1081]     0  1081     1803       27      10 
21             0 stress
[ 1729.144638] [ 1082]     0  1082    67340     8238     138 
57379             0 stress
[ 1729.176403] [ 1083]     0  1083     1803       27      10 
21             0 stress
[ 1729.206905] [ 1084]     0  1084    67340    55392     119 
12             0 stress
[ 1729.237086] [ 1085]     0  1085     1803       27      10 
21             0 stress
[ 1729.265883] [ 1086]     0  1086    67340     4169     138 
61447             0 stress
[ 1729.293362] [ 1087]     0  1087     1803       27      10 
21             0 stress
[ 1729.319405] [ 1088]     0  1088    67340    16042      42 
12             0 stress
[ 1729.345380] [ 1089]     0  1089     1803       27      10 
21             0 stress
[ 1729.370934] [ 1090]     0  1090    67340     1223      13 
12             0 stress
[ 1729.395553] [ 1091]     0  1091     1803       27      10 
21             0 stress
[ 1729.419544] [ 1092]     0  1092    67340     8318     138 
57298             0 stress
[ 1729.443863] [ 1093]     0  1093     1803       27      10 
21             0 stress
[ 1729.467471] [ 1094]     0  1094    67340     2342      16 
12             0 stress
[ 1729.491074] [ 1095]     0  1095     1803       27      10 
21             0 stress
[ 1729.514194] [ 1096]     0  1096    67340    59017     126 
12             0 stress
[ 1729.536998] [ 1097]     0  1097    67340    36245      82 
12             0 stress
[ 1729.559710] [ 1098]     0  1098    67340    57050     122 
12             0 stress
[ 1729.582264] [ 1099]     0  1099    67340    29239      68 
12             0 stress
[ 1729.604895] [ 1100]     0  1100    67340    30815      71 
12             0 stress
[ 1729.627532] [ 1101]     0  1101    67340     6881     138 
58735             0 stress
[ 1729.650016] [ 1102]     0  1102    67340    37447      84 
12             0 stress
[ 1729.672130] [ 1103]     0  1103    67340     6891      24 
12             0 stress
[ 1729.693897] [ 1104]     0  1104    67340    35463      80 
12             0 stress
[ 1729.715565] [ 1105]     0  1105    67340    11843      34 
12             0 stress
[ 1729.736992] [ 1106]     0  1106    67340    10279     138 
55338             0 stress
[ 1729.758383] [ 1198]     0  1198    88549     5957     185 
6739          -900 setroubleshootd
[ 1729.780776] [ 2309]     0  2309     3243      192      12 
0             0 systemd-cgroups
[ 1729.803176] [ 2312]     0  2312     3243      179      12 
0             0 systemd-cgroups
[ 1729.825560] [ 2314]     0  2314     3243      209      11 
0             0 systemd-cgroups
[ 1729.847848] [ 2315]     0  2315     3243      165      11 
0             0 systemd-cgroups
[ 1729.870223] [ 2317]     0  2317     1736       41       6 
0             0 systemd-cgroups
[ 1729.892316] [ 2319]     0  2319     2688       46       7 
0             0 systemd-cgroups
[ 1729.914310] [ 2320]     0  2320      681       34       4 
0             0 systemd-cgroups
[ 1729.936223] [ 2321]     0  2321       42        1       2 
0             0 systemd-cgroups
[ 1729.957811] Out of memory: Kill process 516 (rsyslogd) score 0 or 
sacrifice child
[ 1729.978407] Killed process 516 (rsyslogd) total-vm:245244kB, 
anon-rss:0kB, file-rss:688kB
[ 1923.469572] INFO: task kworker/4:2:232 blocked for more than 120 seconds.
[ 1923.490002] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[ 1923.511856] kworker/4:2     D ffff88027fc14080     0   232      2 
0x00000000
[ 1923.533216]  ffff88027977db88 0000000000000046 ffff8802797b5040 
ffff88027977dfd8
[ 1923.556100]  ffff88027977dfd8 ffff88027977dfd8 ffff880179063580 
ffff8802797b5040
[ 1923.578569]  ffff88027977db68 ffff88027977dd10 7fffffffffffffff 
ffff8802797b5040
[ 1923.601034] Call Trace:
[ 1923.618253]  [<ffffffff815e7b69>] schedule+0x29/0x70
[ 1923.638372]  [<ffffffff815e6114>] schedule_timeout+0x1f4/0x2b0
[ 1923.659539]  [<ffffffff815e79f0>] wait_for_common+0x120/0x170
[ 1923.680664]  [<ffffffff81096920>] ? try_to_wake_up+0x2d0/0x2d0
[ 1923.702224]  [<ffffffff815e7b3d>] wait_for_completion+0x1d/0x20
[ 1923.723820]  [<ffffffff8107b0b9>] call_usermodehelper_fns+0x1d9/0x200
[ 1923.746167]  [<ffffffff810d0b32>] cgroup_release_agent+0xe2/0x180
[ 1923.768233]  [<ffffffff8107e638>] process_one_work+0x148/0x490
[ 1923.790179]  [<ffffffff810d0a50>] ? init_root_id+0xb0/0xb0
[ 1923.811797]  [<ffffffff8107f16e>] worker_thread+0x15e/0x450
[ 1923.833733]  [<ffffffff8107f010>] ? busy_worker_rebind_fn+0x110/0x110
[ 1923.856703]  [<ffffffff81084350>] kthread+0xc0/0xd0
[ 1923.878067]  [<ffffffff81084290>] ? kthread_create_on_node+0x120/0x120
[ 1923.901388]  [<ffffffff815f12ac>] ret_from_fork+0x7c/0xb0
[ 1923.923544]  [<ffffffff81084290>] ? kthread_create_on_node+0x120/0x120
[ 1923.947290] INFO: task rs:main Q:Reg:534 blocked for more than 120 
seconds.
[ 1923.971646] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[ 1923.997338] rs:main Q:Reg   D ffff88027fc54080     0   534      1 
0x00000084
[ 1924.022565]  ffff880279913930 0000000000000082 ffff880279b29ac0 
ffff880279913fd8
[ 1924.049053]  ffff880279913fd8 ffff880279913fd8 ffff880279b2b580 
ffff880279b29ac0
[ 1924.075230]  000000000003b55f ffff880279b29ac0 ffff880279bedde0 
ffffffffffffffff
[ 1924.101476] Call Trace:
[ 1924.122766]  [<ffffffff815e7b69>] schedule+0x29/0x70
[ 1924.146894]  [<ffffffff815e8915>] rwsem_down_failed_common+0xb5/0x140
[ 1924.173018]  [<ffffffff815e89d5>] rwsem_down_read_failed+0x15/0x17
[ 1924.198572]  [<ffffffff812eb0c4>] call_rwsem_down_read_failed+0x14/0x30
[ 1924.224975]  [<ffffffff810fecf3>] ? taskstats_exit+0x383/0x420
[ 1924.250579]  [<ffffffff812e9e5f>] ? __get_user_8+0x1f/0x29
[ 1924.275797]  [<ffffffff815e6df4>] ? down_read+0x24/0x2b
[ 1924.300955]  [<ffffffff815eca16>] __do_page_fault+0x1c6/0x4e0
[ 1924.326726]  [<ffffffff811797ef>] ? alloc_pages_current+0xcf/0x140
[ 1924.353121]  [<ffffffff8118345e>] ? new_slab+0x20e/0x310
[ 1924.378729]  [<ffffffff815ecd3e>] do_page_fault+0xe/0x10
[ 1924.404424]  [<ffffffff815e9358>] page_fault+0x28/0x30
[ 1924.429991]  [<ffffffff810fecf3>] ? taskstats_exit+0x383/0x420
[ 1924.456539]  [<ffffffff812e9e5f>] ? __get_user_8+0x1f/0x29
[ 1924.482746]  [<ffffffff810c047d>] ? exit_robust_list+0x5d/0x160
[ 1924.509604]  [<ffffffff810feca9>] ? taskstats_exit+0x339/0x420
[ 1924.536514]  [<ffffffff8105e5d7>] mm_release+0x147/0x160
[ 1924.563242]  [<ffffffff81065186>] exit_mm+0x26/0x120
[ 1924.589384]  [<ffffffff81066787>] do_exit+0x167/0x8d0
[ 1924.615888]  [<ffffffff810be75b>] ? futex_wait+0x13b/0x2c0
[ 1924.642809]  [<ffffffff81183060>] ? kmem_cache_free+0x20/0x160
[ 1924.670213]  [<ffffffff8106733f>] do_group_exit+0x3f/0xa0
[ 1924.697387]  [<ffffffff81075eca>] get_signal_to_deliver+0x1ca/0x5e0
[ 1924.726012]  [<ffffffff8101437f>] do_signal+0x3f/0x610
[ 1924.753260]  [<ffffffff810c06ad>] ? do_futex+0x12d/0x580
[ 1924.780688]  [<ffffffff810149f0>] do_notify_resume+0x80/0xb0
[ 1924.808394]  [<ffffffff815f1612>] int_signal+0x12/0x17
[ 1924.835765] INFO: task rsyslogd:536 blocked for more than 120 seconds.
[ 1924.864967] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[ 1924.896012] rsyslogd        D ffff88017bc14080     0   536      1 
0x00000086
[ 1924.926767]  ffff8802791b7c38 0000000000000082 ffff88027a0a0000 
ffff8802791b7fd8
[ 1924.958361]  ffff8802791b7fd8 ffff8802791b7fd8 ffff880279b29ac0 
ffff88027a0a0000
[ 1924.990164]  ffff8802791b7c28 ffff88027a0a0000 ffff880279bedde0 
ffffffffffffffff
[ 1925.021929] Call Trace:
[ 1925.048178]  [<ffffffff815e7b69>] schedule+0x29/0x70
[ 1925.077075]  [<ffffffff815e8915>] rwsem_down_failed_common+0xb5/0x140
[ 1925.107125]  [<ffffffff815e89b3>] rwsem_down_write_failed+0x13/0x20
[ 1925.136665]  [<ffffffff812eb0f3>] call_rwsem_down_write_failed+0x13/0x20
[ 1925.166430]  [<ffffffff815e6dc2>] ? down_write+0x32/0x40
[ 1925.194797]  [<ffffffff8109ae0b>] task_numa_work+0xeb/0x270
[ 1925.223254]  [<ffffffff81081047>] task_work_run+0xa7/0xe0
[ 1925.251609]  [<ffffffff810762bb>] get_signal_to_deliver+0x5bb/0x5e0
[ 1925.280624]  [<ffffffff8115e619>] ? handle_mm_fault+0x149/0x210
[ 1925.309222]  [<ffffffff8101437f>] do_signal+0x3f/0x610
[ 1925.337048]  [<ffffffff8117cea1>] ? change_prot_numa+0x51/0x60
[ 1925.365604]  [<ffffffff8109aef6>] ? task_numa_work+0x1d6/0x270
[ 1925.394295]  [<ffffffff810149f0>] do_notify_resume+0x80/0xb0
[ 1925.422677]  [<ffffffff815e917c>] retint_signal+0x48/0x8c
[ 1925.450753] INFO: task NetworkManager:587 blocked for more than 120 
seconds.
[ 1925.480882] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[ 1925.512086] NetworkManager  D ffff88027fc54080     0   587      1 
0x00000080
[ 1925.542751]  ffff880279fb7dc8 0000000000000086 ffff880279f29ac0 
ffff880279fb7fd8
[ 1925.574086]  ffff880279fb7fd8 ffff880279fb7fd8 ffff8801752c1ac0 
ffff880279f29ac0
[ 1925.605328]  ffffea0005e82c40 ffff880279f29ac0 ffff8801793cd860 
ffffffffffffffff
[ 1925.636585] Call Trace:
[ 1925.662557]  [<ffffffff815e7b69>] schedule+0x29/0x70
[ 1925.691518]  [<ffffffff815e8915>] rwsem_down_failed_common+0xb5/0x140
[ 1925.721815]  [<ffffffff8115e619>] ? handle_mm_fault+0x149/0x210
[ 1925.751814]  [<ffffffff815e89b3>] rwsem_down_write_failed+0x13/0x20
[ 1925.781475]  [<ffffffff812eb0f3>] call_rwsem_down_write_failed+0x13/0x20
[ 1925.811421]  [<ffffffff815e6dc2>] ? down_write+0x32/0x40
[ 1925.839679]  [<ffffffff8109ae0b>] task_numa_work+0xeb/0x270
[ 1925.868180]  [<ffffffff810e307c>] ? __audit_syscall_exit+0x3ec/0x450
[ 1925.897544]  [<ffffffff81081047>] task_work_run+0xa7/0xe0
[ 1925.925674]  [<ffffffff810149e1>] do_notify_resume+0x71/0xb0
[ 1925.954159]  [<ffffffff815e917c>] retint_signal+0x48/0x8c
[ 2045.984126] INFO: task kworker/4:2:232 blocked for more than 120 seconds.
[ 2046.013951] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[ 2046.045339] kworker/4:2     D ffff88027fc14080     0   232      2 
0x00000000
[ 2046.075873]  ffff88027977db88 0000000000000046 ffff8802797b5040 
ffff88027977dfd8
[ 2046.107357]  ffff88027977dfd8 ffff88027977dfd8 ffff880179063580 
ffff8802797b5040
[ 2046.138576]  ffff88027977db68 ffff88027977dd10 7fffffffffffffff 
ffff8802797b5040
[ 2046.169696] Call Trace:
[ 2046.195647]  [<ffffffff815e7b69>] schedule+0x29/0x70
[ 2046.224276]  [<ffffffff815e6114>] schedule_timeout+0x1f4/0x2b0
[ 2046.253957]  [<ffffffff815e79f0>] wait_for_common+0x120/0x170
[ 2046.283497]  [<ffffffff81096920>] ? try_to_wake_up+0x2d0/0x2d0
[ 2046.313349]  [<ffffffff815e7b3d>] wait_for_completion+0x1d/0x20
[ 2046.343061]  [<ffffffff8107b0b9>] call_usermodehelper_fns+0x1d9/0x200
[ 2046.373636]  [<ffffffff810d0b32>] cgroup_release_agent+0xe2/0x180
[ 2046.403705]  [<ffffffff8107e638>] process_one_work+0x148/0x490
[ 2046.433485]  [<ffffffff810d0a50>] ? init_root_id+0xb0/0xb0
[ 2046.462879]  [<ffffffff8107f16e>] worker_thread+0x15e/0x450
[ 2046.492398]  [<ffffffff8107f010>] ? busy_worker_rebind_fn+0x110/0x110
[ 2046.522898]  [<ffffffff81084350>] kthread+0xc0/0xd0
[ 2046.551810]  [<ffffffff81084290>] ? kthread_create_on_node+0x120/0x120
[ 2046.582425]  [<ffffffff815f12ac>] ret_from_fork+0x7c/0xb0
[ 2046.612099]  [<ffffffff81084290>] ? kthread_create_on_node+0x120/0x120
----------------------- snip ----------------------------

the other is that oom02(LTP: testcases/kernel/mem/oom/oom02) made 
oom-killer kill unexpected processes:
(oom02 is designed to try to hog memory on one node), and oom02 always 
hung until you kill it manually.

------------ snip -----------------------
[12449.554508] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents 
oom_score_adj name
[12449.554524] [  303]     0   303     9750      296      23 414         
-1000 systemd-udevd
[12449.554527] [  448]     0   448     6558      224      13 35         
-1000 auditd
[12449.554532] [  519]     0   519    24696       82      15 
20             0 iscsiuio
[12449.554534] [  529]    81   529     8201      389      27 35          
-900 dbus-daemon
[12449.554536] [  530]     0   530     1264       94       9 
15             0 iscsid
[12449.554538] [  531]     0   531     1389      876       9 0           
-17 iscsid
[12449.554540] [  538]     0   538     1608      158      10 
28             0 mcelog
[12449.554542] [  543]     0   543     5906      138      16 
48             0 atd
[12449.554543] [  551]     0   551    30146      301      22 
56             0 crond
[12449.554545] [  569]     0   569    26612      224      83 
184             0 login
[12449.554547] [  587]     0   587   108127      917      91 
45             0 NetworkManager
[12449.554549] [  643]     0   643    21931      290      65 
120          -900 modem-manager
[12449.554551] [  644]     0   644     5812      222      16 
61             0 bluetoothd
[12449.554553] [  672]     0   672   118388      469     179 
935             0 libvirtd
[12449.554555] [  691]     0   691    20059      229      40 177         
-1000 sshd
[12449.554556] [  996]     0   996    28975      654      18 
186             0 bash
[12449.554558] [ 1198]     0  1198    88549     5958     185 
6738          -900 setroubleshootd
[12449.554563] [ 2332]     0  2332    74107     3729     152 
0             0 systemd-journal
[12449.554564] [ 2335]     0  2335     8222      388      20 
0             0 systemd-logind
[12449.554567] [20909]     0 20909    61311      456      22 
0             0 rsyslogd
[12449.554572] [12818]     0 12818   788031     6273      24 
0             0 oom02
[12449.554574] [13193]     0 13193    23143     3749      46 
0             0 dhclient
[12449.554576] [13217]     0 13217    33221     1188      67 
0             0 sshd
[12449.554577] [13221]     0 13221    28949      879      19 
0             0 bash
[12449.554579] [13308]     0 13308    23143     3749      45 
0             0 dhclient
[12449.554581] [13388]     0 13388    36864     1063      45 
0             0 vim
[12449.554583] Out of memory: Kill process 13193 (dhclient) score 1 or 
sacrifice child
[12449.554584] Killed process 13193 (dhclient) total-vm:92572kB, 
anon-rss:11976kB, file-rss:3020kB
[12451.878812] oom02 invoked oom-killer: gfp_mask=0x280da, order=0, 
oom_score_adj=0
[12451.878815] oom02 cpuset=/ mems_allowed=0-1
[12451.878818] Pid: 12818, comm: oom02 Tainted: G        W 
3.7.0-rc6numacorev17+ #5
[12451.878819] Call Trace:
[12451.878829]  [<ffffffff810d92d1>] ? 
cpuset_print_task_mems_allowed+0x91/0xa0
[12451.878834]  [<ffffffff815dd3b6>] dump_header.isra.12+0x70/0x19b
[12451.878838]  [<ffffffff812e37d3>] ? ___ratelimit+0xa3/0x120
[12451.878843]  [<ffffffff81139c0d>] oom_kill_process+0x1cd/0x320
[12451.878848]  [<ffffffff8106d3c5>] ? has_ns_capability_noaudit+0x15/0x20
[12451.878850]  [<ffffffff8113a377>] out_of_memory+0x447/0x480
[12451.878853]  [<ffffffff8113ff5c>] __alloc_pages_nodemask+0x94c/0x960
[12451.878858]  [<ffffffff8117b1a6>] alloc_pages_vma+0xb6/0x190
[12451.878861]  [<ffffffff8115e094>] handle_pte_fault+0x8f4/0xb90
[12451.878865]  [<ffffffff810fa237>] ? call_rcu_sched+0x17/0x20
[12451.878868]  [<ffffffff8118ed82>] ? put_filp+0x52/0x60
[12451.878870]  [<ffffffff8115e619>] handle_mm_fault+0x149/0x210
[12451.878873]  [<ffffffff815ec9c2>] __do_page_fault+0x172/0x4e0
[12451.878875]  [<ffffffff81183060>] ? kmem_cache_free+0x20/0x160
[12451.878878]  [<ffffffff81198396>] ? final_putname+0x26/0x50
[12451.878880]  [<ffffffff815ecd3e>] do_page_fault+0xe/0x10
[12451.878883]  [<ffffffff815e9358>] page_fault+0x28/0x30
--------------- snip ------------------

-------------- snip ------------------
[12451.956997] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents 
oom_score_adj name
[12451.957010] [  303]     0   303     9750      296      23 414         
-1000 systemd-udevd
[12451.957013] [  448]     0   448     6558      224      13 35         
-1000 auditd
[12451.957017] [  519]     0   519    24696       82      15 
20             0 iscsiuio
[12451.957019] [  529]    81   529     8201      389      27 35          
-900 dbus-daemon
[12451.957021] [  530]     0   530     1264       94       9 
15             0 iscsid
[12451.957022] [  531]     0   531     1389      876       9 0           
-17 iscsid
[12451.957024] [  538]     0   538     1608      158      10 
28             0 mcelog
[12451.957026] [  543]     0   543     5906      138      16 
48             0 atd
[12451.957028] [  551]     0   551    30146      301      22 
56             0 crond
[12451.957029] [  569]     0   569    26612      224      83 
184             0 login
[12451.957031] [  587]     0   587   110177      922      92 
45             0 NetworkManager
[12451.957033] [  643]     0   643    21931      290      65 
120          -900 modem-manager
[12451.957035] [  644]     0   644     5812      222      16 
61             0 bluetoothd
[12451.957036] [  672]     0   672   118388      469     179 
935             0 libvirtd
[12451.957038] [  691]     0   691    20059      229      40 177         
-1000 sshd
[12451.957040] [  996]     0   996    28975      654      18 
186             0 bash
[12451.957042] [ 1198]     0  1198    88549     5958     185 
6738          -900 setroubleshootd
[12451.957045] [ 2332]     0  2332    74107     3897     152 
0             0 systemd-journal
[12451.957047] [ 2335]     0  2335     8222      388      20 
0             0 systemd-logind
[12451.957049] [20909]     0 20909    61311      456      22 
0             0 rsyslogd
[12451.957052] [12818]     0 12818   788031     6273      24 
0             0 oom02
[12451.957054] [13217]     0 13217    33221     1188      67 
0             0 sshd
[12451.957055] [13221]     0 13221    28949      879      19 
0             0 bash
[12451.957057] [13388]     0 13388    36864     1063      45 
0             0 vim
[12451.957059] [13410]     0 13410    33476      510      58 0          
-900 nm-dispatcher.a
[12451.957061] Out of memory: Kill process 2335 (systemd-logind) score 0 
or sacrifice child
-------------------- snip ----------------------------

also I found oom-killer performed bad on numa/core tree, you can use 
LTP: testcases/kernel/mem/oom/oom* to verify it.

please let me know if you need more details or any other testing works.

Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
