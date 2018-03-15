Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 456DE6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:56:56 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id d18-v6so1423347oth.12
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:56:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q5si1337985oti.457.2018.03.15.04.56.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 04:56:52 -0700 (PDT)
Subject: Re: KVM hang after OOM
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
 <b9ef3b5f-37c2-649a-2c90-8fbbf2bd3bed@i-love.sakura.ne.jp>
Message-ID: <178719aa-b669-c443-bf87-5728b71557c0@i-love.sakura.ne.jp>
Date: Thu, 15 Mar 2018 20:56:45 +0900
MIME-Version: 1.0
In-Reply-To: <b9ef3b5f-37c2-649a-2c90-8fbbf2bd3bed@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>

On 2018/03/12 19:22, Tetsuo Handa wrote:
> On 2018/03/12 3:11, Mikhail Gavrilov wrote:
>> $ uname -a
>> Linux localhost.localdomain 4.15.7-300.fc27.x86_64+debug #1 SMP Wed
>> Feb 28 17:32:16 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
>>
>>
>> How reproduce:
>> 1. start virtual machine
>> 2. open https://oom.sy24.ru/ in Firefox which will helps occurred OOM.
>> Sorry I can't attach here html page because my message will rejected
>> as message would contained HTML subpart.
>>
>> Actual result virtual machine hang and even couldn't be force off.
>>
>> Expected result virtual machine continue work.
>
> Looks like similar problem with http://lkml.kernel.org/r/20180212124359.GB3443@dhcp22.suse.cz .
> We are waiting for Michal Hocko to come back.
>
>

Since Michal Hocko is still busy, I made a bit of debug patch.

Can you try SysRq-i when you noticed io_schedule() deadlock? The intent of
doing so is to test whether the reason of sleeping is that someone who is
responsible to wake up failed to wake up or not. If someone failed to wake up,
io_schedule() deadlock situation will continue because of uninterruptible sleep.
If the reason is out of memory, terminating all processes should reclaim memory
and allow someone who is responsible to wake up to wake up and io_schedule()
deadlock situation should be solved.

Also, can you try a debug patch shown below? This patch calls dump_page() in
order to help understand state of the page in question. If someone failed to
unlock the page, this patch should report forever. If someone failed to wake
up, this patch should report only once (because of sleep with timeout).

----------------------------------------
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f622..192ed67f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,9 @@
 #include <linux/cleancache.h>
 #include <linux/shmem_fs.h>
 #include <linux/rmap.h>
+#include <linux/oom.h>          /* oom_lock */
+#include <linux/sched/debug.h>  /* sched_show_task() */
+#include <linux/sched/sysctl.h> /* sysctl_hung_task_timeout_secs */
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1076,6 +1079,7 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 	struct wait_page_queue wait_page;
 	wait_queue_entry_t *wait = &wait_page.wait;
 	int ret = 0;
+	unsigned long start = jiffies;
 
 	init_wait(wait);
 	wait->flags = lock ? WQ_FLAG_EXCLUSIVE : 0;
@@ -1084,6 +1088,10 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 	wait_page.bit_nr = bit_nr;
 
 	for (;;) {
+		unsigned long timeout = sysctl_hung_task_timeout_secs;
+		if (!timeout)
+			timeout = 60;
+
 		spin_lock_irq(&q->lock);
 
 		if (likely(list_empty(&wait->entry))) {
@@ -1095,8 +1103,17 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 
 		spin_unlock_irq(&q->lock);
 
-		if (likely(test_bit(bit_nr, &page->flags))) {
-			io_schedule();
+		if (likely(test_bit(bit_nr, &page->flags)) &&
+		    io_schedule_timeout(timeout * HZ) == 0) {
+			char buf[32];
+			struct task_struct *t = current;
+			snprintf(buf, sizeof(buf), "stuck on bit %u", bit_nr);
+			mutex_lock(&oom_lock);
+			pr_err("INFO: task %s:%d blocked for %lu seconds.\n",
+			       t->comm, t->pid, (jiffies - start) / HZ);
+			sched_show_task(t);
+			dump_page(page, buf);
+			mutex_unlock(&oom_lock);
 		}
 
 		if (lock) {
----------------------------------------

I tried to reproduce your problem using plain idle Fedora 27 guest (RAM 4GB + SWAP 4GB).
While the system apparently hang after OOM killer, the system seemed to be just under
swap memory thrashing situation, for heavy disk I/O had been observed from the host side.
Thus, my case might be different from your case.

----------------------------------------
# yum install yum-utils
# yumdownloader --source kernel
kernel-4.15.8-300.fc27.src.rpm
# rpm --checksig kernel-4.15.8-300.fc27.src.rpm
# yum-builddep kernel-4.15.8-300.fc27.src.rpm
# rpm -ivh kernel-4.15.8-300.fc27.src.rpm
# rngd -r /dev/urandom
# rpmbuild -bp ~/rpmbuild/SPECS/kernel.spec
# cd ~/rpmbuild/BUILD/kernel-4.15.fc27/linux-4.15.8-300.fc27.x86_64/
# make -s localmodconfig
# patch -p1
# make -sj8 && make -s modules_install install
----------------------------------------

----------------------------------------
[    0.000000] Linux version 4.15.8 (root@localhost.localdomain) (gcc version 7.3.1 20180303 (Red Hat 7.3.1-5) (GCC)) #1 SMP Thu Mar 15 14:56:32 JST 2018
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-4.15.8 root=/dev/mapper/fedora-root ro rd.lvm.lv=fedora/root rd.lvm.lv=fedora/swap console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8
(...snipped...)
Fedora 27 (Workstation Edition)
Kernel 4.15.8 on an x86_64 (ttyS0)

localhost login: [  209.887120] INFO: task pool:2315 blocked for 63 seconds.
[  209.892531] pool            R  running task        0  2315   1520 0x00000000
[  209.899481] Call Trace:
[  209.902185]  sched_show_task+0xf9/0x130
[  209.906256]  __lock_page_or_retry+0x423/0x450
[  209.910528]  ? page_cache_tree_insert+0xe0/0xe0
[  209.915676]  ? pagecache_get_page+0x30/0x320
[  209.920382]  filemap_fault+0x44b/0x8c0
[  209.921914]  ? page_add_file_rmap+0xbf/0x210
[  209.923568]  ? alloc_set_pte+0x45c/0x570
[  209.925098]  ? filemap_map_pages+0x425/0x4e0
[  209.926743]  ext4_filemap_fault+0x2c/0x3b
[  209.928297]  __do_fault+0x1f/0x120
[  209.929631]  __handle_mm_fault+0xd78/0x1280
[  209.931270]  handle_mm_fault+0xaa/0x1e0
[  209.932848]  __do_page_fault+0x25d/0x4e0
[  209.934615]  do_page_fault+0x32/0x110
[  209.936051]  ? page_fault+0x65/0x80
[  209.937421]  page_fault+0x7b/0x80
[  209.938728] RIP: 0033:0x7f1fb961b50b
[  209.940139] RSP: 002b:00007f1fa65ded80 EFLAGS: 00010246
[  209.942150] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[  209.944870] RDX: 000056326eab1d01 RSI: 0000000000000001 RDI: 000056326eab1cf0
[  209.947747] RBP: 0000000000000000 R08: 0000000000000083 R09: 0000000000000083
[  209.950405] R10: 00007f1fa65deca0 R11: 0000000000000246 R12: 00007ffd19418d2e
[  209.952478] R13: 00007ffd19418d2f R14: 000056326eaad630 R15: 00007ffd19418db0
[  209.954440] page:ffffe61cc47d7600 count:4 mapcount:0 mapping:ffff93eaaccadfe0 index:0x7
[  209.956668] flags: 0x17fffe000100a1(locked|waiters|lru|mappedtodisk)
[  209.958808] raw: 0017fffe000100a1 ffff93eaaccadfe0 0000000000000007 00000004ffffffff
[  209.961296] raw: ffffe61cc47d73e0 ffffe61cc47d7660 0000000000000000 ffff93eab51ec000
[  209.963796] page dumped because: stuck on bit 0
[  209.965368] page->mem_cgroup:ffff93eab51ec000
[  286.262807] sysrq: SysRq : Changing Loglevel
[  286.267231] sysrq: Loglevel set to 9
[  316.232499] hrtimer: interrupt took 3062939 ns
[  617.319540] Web Content invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  617.323056] Web Content cpuset=/ mems_allowed=0
[  617.324305] CPU: 6 PID: 2279 Comm: Web Content Not tainted 4.15.8 #1
[  617.326054] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  617.329287] Call Trace:
[  617.330071]  dump_stack+0x5c/0x79
[  617.331032]  dump_header+0x6e/0x289
[  617.332063]  oom_kill_process+0x218/0x420
[  617.333247]  out_of_memory+0x2ea/0x4f0
[  617.334331]  __alloc_pages_slowpath+0xa44/0xde0
[  617.335570]  ? pagecache_get_page+0x30/0x320
[  617.336758]  __alloc_pages_nodemask+0x28e/0x2b0
[  617.338277]  alloc_pages_vma+0x7c/0x200
[  617.339724]  __handle_mm_fault+0x98b/0x1280
[  617.341401]  handle_mm_fault+0xaa/0x1e0
[  617.342548]  __do_page_fault+0x25d/0x4e0
[  617.343714]  do_page_fault+0x32/0x110
[  617.344806]  ? page_fault+0x65/0x80
[  617.345848]  page_fault+0x7b/0x80
[  617.346949] RIP: 0033:0x7fe3dc0631d0
[  617.348039] RSP: 002b:00007ffcdf8fbce8 EFLAGS: 00010287
[  617.349659] RAX: 00007fe2d3b46cb0 RBX: 0000000000002710 RCX: 00007fe2d3400000
[  617.351786] RDX: 00000000000009c4 RSI: 0000000000000000 RDI: 00007fe2d3b45000
[  617.353849] RBP: 00007ffcdf8fcad0 R08: 0000000000000000 R09: 00007ffcdf8fcad0
[  617.355944] R10: 0000000000000000 R11: 00000000000009c4 R12: 0000000000002710
[  617.358001] R13: 00007fe2d3b46cb0 R14: 00007fe3dbf5aaa0 R15: 00000000000006c8
[  617.360216] Mem-Info:
[  617.360959] active_anon:671116 inactive_anon:135614 isolated_anon:95
[  617.360959]  active_file:0 inactive_file:0 isolated_file:112
[  617.360959]  unevictable:0 dirty:0 writeback:109 unstable:0
[  617.360959]  slab_reclaimable:9349 slab_unreclaimable:24588
[  617.360959]  mapped:0 shmem:3 pagetables:18513 bounce:0
[  617.360959]  free:21550 free_pcp:956 free_cma:0
[  617.370418] Node 0 active_anon:2684464kB inactive_anon:542456kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):380kB isolated(file):448kB mapped:0kB dirty:0kB writeback:436kB shmem:12kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  617.378204] Node 0 DMA free:15716kB min:268kB low:332kB high:396kB active_anon:24kB inactive_anon:96kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  617.385902] lowmem_reserve[]: 0 2954 3864 3864 3864
[  617.387310] Node 0 DMA32 free:54944kB min:51460kB low:64324kB high:77188kB active_anon:2107576kB inactive_anon:451104kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:1088kB present:3129152kB managed:3063584kB mlocked:0kB kernel_stack:7408kB pagetables:46044kB bounce:0kB free_pcp:1676kB local_pcp:0kB free_cma:0kB
[  617.395670] lowmem_reserve[]: 0 0 909 909 909
[  617.396971] Node 0 Normal free:15540kB min:15848kB low:19808kB high:23768kB active_anon:576960kB inactive_anon:90176kB active_file:0kB inactive_file:696kB unevictable:0kB writepending:24kB present:1048576kB managed:936284kB mlocked:0kB kernel_stack:7776kB pagetables:28008kB bounce:0kB free_pcp:2216kB local_pcp:152kB free_cma:0kB
[  617.405373] lowmem_reserve[]: 0 0 0 0 0
[  617.406519] Node 0 DMA: 1*4kB (M) 0*8kB 0*16kB 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 2*1024kB (UM) 0*2048kB 3*4096kB (M) = 15716kB
[  617.410339] Node 0 DMA32: 310*4kB (M) 34*8kB (UME) 127*16kB (UE) 73*32kB (UE) 24*64kB (UE) 7*128kB (UE) 2*256kB (ME) 1*512kB (U) 2*1024kB (ME) 1*2048kB (U) 10*4096kB (UM) = 54392kB
[  617.415091] Node 0 Normal: 181*4kB (UEH) 359*8kB (UMEH) 95*16kB (UEH) 117*32kB (UMEH) 33*64kB (UMEH) 9*128kB (UME) 5*256kB (UEH) 3*512kB (UM) 0*1024kB 0*2048kB 0*4096kB = 14940kB
[  617.419688] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  617.422199] 602 total pagecache pages
[  617.423339] 500 pages in swap cache
[  617.424403] Swap cache stats: add 1078498, delete 1077986, find 19251/34948
[  617.426459] Free swap  = 0kB
[  617.427297] Total swap = 4157436kB
[  617.428277] 1048429 pages RAM
[  617.429142] 0 pages HighMem/MovableOnly
[  617.430292] 44486 pages reserved
[  617.431294] 0 pages cma reserved
[  617.432278] 0 pages hwpoisoned
[  617.433214] [ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[  617.435749] [  613]     0   613    28285       74   233472      192             0 systemd-journal
[  617.438780] [  639]     0   639    25230       11   204800     1529         -1000 systemd-udevd
[  617.441368] [  716]     0   716    43953       13   114688      490             0 lvmetad
[  617.443784] [  762]     0   762    16049       25   135168       87         -1000 auditd
[  617.446265] [  764]     0   764    21122        0    73728       40             0 audispd
[  617.448778] [  772]     0   772     9652       21   118784       61             0 sedispatch
[  617.451264] [  787]     0   787   104417        0   323584      445             0 ModemManager
[  617.453756] [  788]     0   788   130671        1   389120      490             0 udisksd
[  617.456203] [  789]   172   789    46481        0   131072       84             0 rtkit-daemon
[  617.458733] [  791]    81   791    15408      306   147456      211          -900 dbus-daemon
[  617.461234] [  797]     0   797    51276        0   180224      129             0 gssproxy
[  617.463645] [  808]     0   808    24562        0   176128      374             0 VGAuthService
[  617.466202] [  809]     0   809    78151       98   241664      231             0 vmtoolsd
[  617.468636] [  810]     0   810    87021        1   364544     4873             0 firewalld
[  617.471107] [  813]    70   813    18576        0   159744      106             0 avahi-daemon
[  617.473627] [  815]     0   815    70715        2   352256      263             0 sssd
[  617.476034] [  816]     0   816     4198        1    69632       33             0 mcelog
[  617.478486] [  820]     0   820   116604        0   315392      402             0 abrtd
[  617.480720] [  827]   995   827    29457       17   122880       97             0 chronyd
[  617.483115] [  828]    70   828    18544        0   139264       86             0 avahi-daemon
[  617.485653] [  831]   997   831   141547        0   294912     1532             0 polkitd
[  617.488124] [  835]     0   835    72503       20   380928      537             0 sssd_be
[  617.490532] [  849]     0   849    69785       32   331776      340             0 abrt-dump-journ
[  617.493129] [  850]     0   850    67925       28   307200      337             0 abrt-dump-journ
[  617.495749] [  851]     0   851    67925       32   331776      336             0 abrt-dump-journ
[  617.498495] [  857]     0   857    70131       21   372736      328             0 sssd_nss
[  617.500905] [  864]     0   864    19719       40   188416      525             0 systemd-logind
[  617.503393] [  865]     0   865   106036        0   221184      239             0 accounts-daemon
[  617.505865] [  908]     0   908   184194        1   446464      743             0 NetworkManager
[  617.508433] [  927]     0   927   440572        1   823296     2167             0 libvirtd
[  617.510892] [  928]     0   928    22276        0   184320      207         -1000 sshd
[  617.513213] [  941]     0   941    35864       21   106496      140             0 crond
[  617.515454] [  943]     0   943   106017        0   241664      288             0 gdm
[  617.517651] [  960]     0   960    96490        1   299008      301             0 gdm-session-wor
[  617.520313] [ 1012]    42  1012    22369        1   217088      312             0 systemd
[  617.522712] [ 1022]    42  1022    34344        0   258048     1172             0 (sd-pam)
[  617.525142] [ 1034]    42  1034   105310        1   356352      325             0 gdm-wayland-ses
[  617.527658] [ 1062]    42  1062    18142        1   147456      242             0 dbus-daemon
[  617.530305] [ 1070]    42  1070   166336        0   421888      602             0 gnome-session-b
[  617.532902] [ 1099]     0  1099    19834        1   188416      475             0 dhclient
[  617.535344] [ 1101]    42  1101   953274     1221  1609728    14656             0 gnome-shell
[  617.537777] [ 1141]     0  1141    36365        1   290816      275             0 sshd
[  617.540211] [ 1153]     0  1153   104695        0   241664      322             0 upowerd
[  617.542637] [ 1161]     0  1161    19770        0   196608      286             0 systemd
[  617.545038] [ 1163]     0  1163    31225        0   253952     1169             0 (sd-pam)
[  617.547350] [ 1168]     0  1168    36371       32   278528      251             0 sshd
[  617.549655] [ 1169]     0  1169    33591        9    94208      535             0 bash
[  617.552040] [ 1177]    42  1177   208216       44   516096     3820             0 Xwayland
[  617.554492] [ 1213]    42  1213    88943        0   192512      207             0 at-spi-bus-laun
[  617.557103] [ 1218]    42  1218    18027        1   143360      142             0 dbus-daemon
[  617.559661] [ 1221]    42  1221    55770        1   204800      209             0 at-spi2-registr
[  617.562309] [ 1227]    42  1227   292888        1   344064      285             0 pulseaudio
[  617.564800] [ 1247]    42  1247   122023        0   356352      427             0 xdg-permission-
[  617.567274] [ 1254]    42  1254   118810       21   208896      595             0 ibus-daemon
[  617.569682] [ 1257]    42  1257    97414        0   184320      194             0 ibus-dconf
[  617.572168] [ 1260]    42  1260   149149        0   688128     2344             0 ibus-x11
[  617.574598] [ 1265]    42  1265    97381        0   184320      186             0 ibus-portal
[  617.576991] [ 1284]     0  1284    12545       15   143360      135             0 wpa_supplicant
[  617.579492] [ 1286]    42  1286   170296        0   724992     2465             0 gsd-wacom
[  617.582029] [ 1287]     0  1287   139149       14   491520      799             0 packagekitd
[  617.584523] [ 1289]    42  1289   186251        0   704512     2486             0 gsd-xsettings
[  617.587082] [ 1290]    42  1290   170801        0   716800     2393             0 gsd-a11y-keyboa
[  617.589693] [ 1291]    42  1291   127616        0   401408      388             0 gsd-a11y-settin
[  617.592388] [ 1292]    42  1292   149054        0   679936     2347             0 gsd-clipboard
[  617.594948] [ 1295]    42  1295   208380       26   753664     2372             0 gsd-color
[  617.597320] [ 1296]    42  1296   117670        1   434176      460             0 gsd-datetime
[  617.599838] [ 1297]    42  1297   127536        1   393216      369             0 gsd-housekeepin
[  617.602592] [ 1302]    42  1302   188713        0   741376     2407             0 gsd-keyboard
[  617.605138] [ 1310]    42  1310   337263        0   831488     2544             0 gsd-media-keys
[  617.607710] [ 1311]    42  1311   108575        0   376832      361             0 gsd-mouse
[  617.610175] [ 1312]    42  1312   192424       24   745472     2446             0 gsd-power
[  617.612625] [ 1316]    42  1316   118069        0   454656      460             0 gsd-print-notif
[  617.615262] [ 1317]    42  1317   108579        1   393216      361             0 gsd-rfkill
[  617.617698] [ 1318]    42  1318   127008        1   393216      370             0 gsd-screensaver
[  617.620247] [ 1323]    42  1323   104122        0   237568      250             0 gsd-sharing
[  617.622831] [ 1326]    42  1326   153276        0   458752      494             0 gsd-smartcard
[  617.625414] [ 1331]    42  1331   138208        0   483328      473             0 gsd-sound
[  617.627875] [ 1349]    42  1349    78964        0   176128      189             0 ibus-engine-sim
[  617.630500] [ 1405]   991  1405   108150        0   258048      535             0 colord
[  617.632914] [ 1434]     0  1434    30765        0    69632       31             0 agetty
[  617.635357] [ 1467]     0  1467   102707        1   344064      330             0 gdm-session-wor
[  617.637956] [ 1483]  1000  1483    22369        1   204800      321             0 systemd
[  617.640294] [ 1488]  1000  1488    71210        0   274432     1183             0 (sd-pam)
[  617.642631] [ 1499]  1000  1499    98795        1   192512      268             0 gnome-keyring-d
[  617.645292] [ 1503]  1000  1503   105342        0   352256      324             0 gdm-wayland-ses
[  617.647893] [ 1517]  1000  1517    18261      181   147456      199             0 dbus-daemon
[  617.650408] [ 1520]  1000  1520   166420      151   442368      482             0 gnome-session-b
[  617.653041] [ 1571]  1000  1571   100256        1   208896      247             0 gvfsd
[  617.655528] [ 1586]  1000  1586  1016566     2154  1720320    21173             0 gnome-shell
[  617.658035] [ 1603]  1000  1603   213032      405   602112     3953             0 Xwayland
[  617.660472] [ 1614]  1000  1614    88942        1   188416      207             0 at-spi-bus-laun
[  617.663117] [ 1619]  1000  1619    18060       11   151552      137             0 dbus-daemon
[  617.665695] [ 1622]  1000  1622    55770        0   196608      219             0 at-spi2-registr
[  617.668312] [ 1628]  1000  1628   497904        0   430080      392             0 pulseaudio
[  617.670800] [ 1645]  1000  1645   122044        0   348160      428             0 xdg-permission-
[  617.673317] [ 1647]  1000  1647   247911        0   974848     1921             0 gnome-shell-cal
[  617.675909] [ 1651]  1000  1651   137313       26   212992      662             0 ibus-daemon
[  617.678437] [ 1655]  1000  1655    97434        0   196608      209             0 ibus-dconf
[  617.680876] [ 1657]  1000  1657   149206        0   700416     2359             0 ibus-x11
[  617.683214] [ 1659]  1000  1659    97435        0   188416      192             0 ibus-portal
[  617.685669] [ 1679]  1000  1679   109553        0   278528      380             0 gvfs-udisks2-vo
[  617.688332] [ 1687]  1000  1687   253549        0  1093632     2003             0 evolution-sourc
[  617.690953] [ 1689]  1000  1689    99386        0   200704      214             0 gvfs-gphoto2-vo
[  617.693582] [ 1693]  1000  1693    96270        0   180224      185             0 gvfs-mtp-volume
[  617.696255] [ 1701]  1000  1701    95830        0   176128      194             0 gvfs-goa-volume
[  617.698913] [ 1705]  1000  1705   219480        0   688128     1403             0 goa-daemon
[  617.701400] [ 1713]  1000  1713   130446       60   425984      365             0 goa-identity-se
[  617.703970] [ 1715]  1000  1715   122018        0   241664      287             0 gvfs-afc-volume
[  617.706664] [ 1732]  1000  1732   127662        0   401408      401             0 gsd-mouse
[  617.709200] [ 1733]  1000  1733   192483      127   741376     2367             0 gsd-power
[  617.711660] [ 1734]  1000  1734   139152        0   479232      505             0 gsd-print-notif
[  617.714214] [ 1735]  1000  1735   163957        0   409600      407             0 gsd-rfkill
[  617.716588] [ 1736]  1000  1736   127054        0   385024      378             0 gsd-screensaver
[  617.719309] [ 1737]  1000  1737   141099        0   245760      384             0 gsd-sharing
[  617.721786] [ 1738]  1000  1738   153321        0   454656      495             0 gsd-smartcard
[  617.724221] [ 1739]  1000  1739   170365        0   716800     2485             0 gsd-wacom
[  617.726563] [ 1741]  1000  1741   186326        0   708608     2502             0 gsd-xsettings
[  617.729184] [ 1743]  1000  1743   138253        0   487424      486             0 gsd-sound
[  617.731642] [ 1772]  1000  1772   127662        0   401408      389             0 gsd-a11y-settin
[  617.734215] [ 1773]  1000  1773   170874        0   720896     2406             0 gsd-a11y-keyboa
[  617.736687] [ 1774]  1000  1774   226896      105   757760     2376             0 gsd-color
[  617.739050] [ 1775]  1000  1775   149130        0   692224     2356             0 gsd-clipboard
[  617.741694] [ 1778]  1000  1778   148277       53   438272      342             0 gsd-housekeepin
[  617.744302] [ 1780]  1000  1780   136758        0   479232      486             0 gsd-datetime
[  617.746771] [ 1782]  1000  1782   320983      113   823296     2443             0 gsd-media-keys
[  617.749310] [ 1785]  1000  1785   188787        0   720896     2417             0 gsd-keyboard
[  617.751874] [ 1799]     0  1799    57809       12   270336      356             0 cupsd
[  617.754243] [ 1835]  1000  1835   318486        1  1208320    10872             0 evolution-calen
[  617.756850] [ 1837]  1000  1837    78985        0   180224      207             0 ibus-engine-sim
[  617.759392] [ 1903]  1000  1903   154442        0   462848      469             0 gsd-printer
[  617.761954] [ 1919]  1000  1919   366545        1   839680    54447             0 tracker-miner-a
[  617.764613] [ 1925]  1000  1925   183657        4   413696     1748             0 tracker-miner-f
[  617.767215] [ 1927]  1000  1927   140518      209   589824     1562             0 vmtoolsd
[  617.769679] [ 1929]  1000  1929   161051        1   540672     1348             0 abrt-applet
[  617.772266] [ 1930]  1000  1930    69563        0   180224      253             0 gsd-disk-utilit
[  617.774883] [ 1950]  1000  1950   191060        1   356352     3292             0 tracker-store
[  617.777357] [ 1952]  1000  1952   298180        0  1077248     2683             0 evolution-alarm
[  617.779821] [ 1956]  1000  1956   215285     2108   937984     8547             0 gnome-software
[  617.782472] [ 1968]  1000  1968   139879        1   516096     3785             0 seapplet
[  617.784914] [ 1972]  1000  1972   395485        1   831488     2963             0 tracker-extract
[  617.787415] [ 1999]  1000  1999   340260        0  1097728    10842             0 evolution-calen
[  617.789943] [ 2009]     0  2009    89135        0   311296      431          -900 abrt-dbus
[  617.792465] [ 2032]  1000  2032    48069        1   147456      158             0 dconf-service
[  617.795025] [ 2034]  1000  2034   358685        0  1101824    10856             0 evolution-calen
[  617.797530] [ 2064]  1000  2064   288193        1  1069056     1956             0 evolution-addre
[  617.799992] [ 2077]  1000  2077   349890        0  1064960     2036             0 evolution-addre
[  617.802640] [ 2093]     0  2093   159752       34   524288      740             0 fwupd
[  617.805037] [ 2114]  1000  2114   579875     2029  1630208    29183             0 firefox
[  617.808215] [ 2204]  1000  2204  1198321   369608  6414336   297145             0 Web Content
[  617.810717] [ 2255]  1000  2255    47181       26   196608      112             0 gconfd-2
[  617.813148] [ 2279]  1000  2279  1401628   423539  7999488   445698             0 Web Content
[  617.815741] [ 2317]  1000  2317   519868      490   983040     4881             0 Web Content
[  617.818209] [ 2389]     0  2389    32947      128   282624        0             0 sssd_kcm
[  617.820631] Out of memory: Kill process 2279 (Web Content) score 426 or sacrifice child
[  617.823206] Killed process 2279 (Web Content) total-vm:5606512kB, anon-rss:1694156kB, file-rss:0kB, shmem-rss:0kB
[  618.020277] oom_reaper: reaped process 2279 (Web Content), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  754.652953] INFO: task gdbus:1963 blocked for 62 seconds.
[  754.655359] gdbus           R  running task        0  1963   1483 0x00000000
[  754.658282] Call Trace:
[  754.659282]  sched_show_task+0xf9/0x130
[  754.660812]  __lock_page_or_retry+0x423/0x450
[  754.663615]  ? page_cache_tree_insert+0xe0/0xe0
[  754.665607]  do_swap_page+0x5b6/0xa40
[  754.667166]  __handle_mm_fault+0x87c/0x1280
[  754.668812]  handle_mm_fault+0xaa/0x1e0
[  754.670563]  __do_page_fault+0x25d/0x4e0
[  754.672318]  do_page_fault+0x32/0x110
[  754.674069]  ? page_fault+0x65/0x80
[  754.675443]  page_fault+0x7b/0x80
[  754.676789] RIP: 0033:0x7ff81f922f67
[  754.678247] RSP: 002b:00007ff8151976d0 EFLAGS: 00010293
[  754.680264] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00007ff80c0008d0
[  754.682975] RDX: 0000564d62a0b9e0 RSI: 00007ff80c0008d0 RDI: 0000000000000001
[  754.686356] RBP: ffffffffffffff60 R08: 00007ff815197888 R09: 0000000000000011
[  754.699292] R10: 0000000000000010 R11: 0000000000000033 R12: 00007ff815197888
[  754.724044] R13: 0000000000000000 R14: 00007ff815197a80 R15: 00007ff815197888
[  754.726411] page:ffffe61cc435ac00 count:2 mapcount:0 mapping:0000000000000000 index:0x0
[  754.728747] flags: 0x17fffe000402a1(locked|waiters|lru|owner_priv_1|swapbacked)
[  754.730877] raw: 0017fffe000402a1 0000000000000000 0000000000000000 00000002ffffffff
[  754.733260] raw: ffffe61cc435ac60 ffffe61cc411d0e0 000000000002ecb7 0000000000000000
[  754.735494] page dumped because: stuck on bit 0
[  816.092318] INFO: task gdbus:1963 blocked for 124 seconds.
[  816.097742] gdbus           R  running task        0  1963   1483 0x00000000
[  816.104631] Call Trace:
[  816.107092]  sched_show_task+0xf9/0x130
[  816.110971]  __lock_page_or_retry+0x423/0x450
[  816.115267]  ? page_cache_tree_insert+0xe0/0xe0
[  816.120709]  do_swap_page+0x5b6/0xa40
[  816.124465]  __handle_mm_fault+0x87c/0x1280
[  816.129135]  handle_mm_fault+0xaa/0x1e0
[  816.131533]  __do_page_fault+0x25d/0x4e0
[  816.133243]  do_page_fault+0x32/0x110
[  816.134839]  ? page_fault+0x65/0x80
[  816.136378]  page_fault+0x7b/0x80
[  816.137835] RIP: 0033:0x7ff81f922f67
[  816.139383] RSP: 002b:00007ff8151976d0 EFLAGS: 00010293
[  816.141621] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00007ff80c0008d0
[  816.144630] RDX: 0000564d62a0b9e0 RSI: 00007ff80c0008d0 RDI: 0000000000000001
[  816.147653] RBP: ffffffffffffff60 R08: 00007ff815197888 R09: 0000000000000011
[  816.150673] R10: 0000000000000010 R11: 0000000000000033 R12: 00007ff815197888
[  816.153692] R13: 0000000000000000 R14: 00007ff815197a80 R15: 00007ff815197888
[  816.156716] page:ffffe61cc435ac00 count:2 mapcount:0 mapping:0000000000000000 index:0x0
[  816.160093] flags: 0x17fffe000402a1(locked|waiters|lru|owner_priv_1|swapbacked)
[  816.162318] raw: 0017fffe000402a1 0000000000000000 0000000000000000 00000002ffffffff
[  816.164586] raw: ffffe61cc435ac60 ffffe61cc43720a0 000000000002ecb7 0000000000000000
[  816.166868] page dumped because: stuck on bit 0
[ 1336.841310] sysrq: SysRq : Show Memory
[ 1336.843919] Mem-Info:
[ 1336.845313] active_anon:666669 inactive_anon:135943 isolated_anon:0
[ 1336.845313]  active_file:416 inactive_file:591 isolated_file:0
[ 1336.845313]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1336.845313]  slab_reclaimable:9555 slab_unreclaimable:25072
[ 1336.845313]  mapped:246 shmem:13 pagetables:18544 bounce:0
[ 1336.845313]  free:24109 free_pcp:984 free_cma:0
[ 1336.866984] Node 0 active_anon:2666676kB inactive_anon:543772kB active_file:1816kB inactive_file:2340kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1572kB dirty:0kB writeback:0kB shmem:52kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1336.886741] Node 0 DMA free:15720kB min:268kB low:332kB high:396kB active_anon:120kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1336.901945] lowmem_reserve[]: 0 2954 3864 3864 3864
[ 1336.903380] Node 0 DMA32 free:63972kB min:51460kB low:64324kB high:77188kB active_anon:2038972kB inactive_anon:510968kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:3063584kB mlocked:0kB kernel_stack:6880kB pagetables:45196kB bounce:0kB free_pcp:2076kB local_pcp:0kB free_cma:0kB
[ 1336.911514] lowmem_reserve[]: 0 0 909 909 909
[ 1336.912793] Node 0 Normal free:17116kB min:15848kB low:19808kB high:23768kB active_anon:627584kB inactive_anon:32804kB active_file:448kB inactive_file:2004kB unevictable:0kB writepending:0kB present:1048576kB managed:936284kB mlocked:0kB kernel_stack:7744kB pagetables:28980kB bounce:0kB free_pcp:1932kB local_pcp:32kB free_cma:0kB
[ 1336.922050] lowmem_reserve[]: 0 0 0 0 0
[ 1336.923182] Node 0 DMA: 2*4kB (M) 0*8kB 0*16kB 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 2*1024kB (UM) 0*2048kB 3*4096kB (M) = 15720kB
[ 1336.927603] Node 0 DMA32: 1164*4kB (UME) 489*8kB (UME) 127*16kB (UME) 50*32kB (UME) 43*64kB (UME) 12*128kB (UME) 3*256kB (UME) 3*512kB (UM) 6*1024kB (ME) 1*2048kB (U) 9*4096kB (UM) = 63848kB
[ 1336.932590] Node 0 Normal: 256*4kB (UMEH) 181*8kB (UME) 100*16kB (UMEH) 104*32kB (UMEH) 34*64kB (UMEH) 12*128kB (UME) 16*256kB (UME) 3*512kB (UM) 0*1024kB 0*2048kB 0*4096kB = 16744kB
[ 1336.937741] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1336.940400] 990 total pagecache pages
[ 1336.941483] 54 pages in swap cache
[ 1336.942611] Swap cache stats: add 1564554, delete 1564488, find 37795/66721
[ 1336.944869] Free swap  = 0kB
[ 1336.945720] Total swap = 4157436kB
[ 1336.946725] 1048429 pages RAM
[ 1336.947563] 0 pages HighMem/MovableOnly
[ 1336.948643] 44486 pages reserved
[ 1336.949549] 0 pages cma reserved
[ 1336.950465] 0 pages hwpoisoned
[ 1339.038124] sysrq: SysRq : Kill All Tasks
[ 1345.219353] kauditd_printk_skb: 4 callbacks suppressed
[ 1345.219355] audit: type=1131 audit(1521101183.830:268): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1345.435207] audit: type=1131 audit(1521101184.046:269): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1345.895461] audit: type=1131 audit(1521101184.506:270): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=lvm2-lvmetad comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.111947] audit: type=1131 audit(1521101184.723:271): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.163635] audit: type=1131 audit(1521101184.774:272): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=ModemManager comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.197119] audit: type=1131 audit(1521101184.808:273): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=udisks2 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.213456] audit: type=1131 audit(1521101184.824:274): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=rtkit-daemon comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.405816] audit: type=1131 audit(1521101185.017:275): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=dbus comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.543337] audit: type=1131 audit(1521101185.154:276): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=gssproxy comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1346.619190] audit: type=1131 audit(1521101185.230:277): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=vgauthd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[ 1350.617393] kauditd_printk_skb: 54 callbacks suppressed
[ 1350.617397] audit: type=1130 audit(1521101189.228:332): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=plymouth-quit comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1350.643554] audit: type=1131 audit(1521101189.228:333): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=plymouth-quit comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1351.532747] audit: type=1305 audit(1521101190.143:334): audit_enabled=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:syslogd_t:s0 res=1
[ 1351.982065] systemd-journald[2542]: File /var/log/journal/c34a3e77044e48009188cc8510309231/system.journal corrupted or uncleanly shut down, renaming and replacing.


Fedora 27 (Workstation Edition)
Kernel 4.15.8 on an x86_64 (ttyS0)

localhost login: [ 1356.402863] audit: type=1130 audit(1521101195.013:335): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=dbus comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1356.574118] audit: type=1130 audit(1521101195.185:336): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1356.595716] audit: type=1130 audit(1521101195.190:337): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1356.818119] audit: type=1130 audit(1521101195.429:338): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=sssd-secrets comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1356.832245] audit: type=1130 audit(1521101195.435:339): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-logind comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1357.053961] audit: type=1130 audit(1521101195.665:340): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1357.071389] audit: type=1130 audit(1521101195.682:341): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=getty@tty2 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1357.583456] audit: type=1130 audit(1521101196.194:342): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=ModemManager comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1357.919797] audit: type=1130 audit(1521101196.530:343): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=libvirtd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1358.029038] audit: type=1130 audit(1521101196.640:344): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager-dispatcher comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1361.428472] kauditd_printk_skb: 3 callbacks suppressed
[ 1361.428477] audit: type=1130 audit(1521101200.039:348): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=polkit comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1368.440467] audit: type=1130 audit(1521101207.051:349): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager-wait-online comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1379.011292] audit: type=1131 audit(1521101217.622:350): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager-dispatcher comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1389.091306] audit: type=1131 audit(1521101227.702:351): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-hostnamed comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1389.113601] audit: type=1130 audit(1521101227.707:352): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=sshd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1389.132071] audit: type=1131 audit(1521101227.707:353): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=sshd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1389.335759] audit: type=1130 audit(1521101227.946:354): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=sshd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1391.048021] audit: type=1130 audit(1521101229.659:355): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager-dispatcher comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1401.010558] audit: type=1131 audit(1521101239.621:356): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=NetworkManager-dispatcher comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[ 1513.479243] sysrq: SysRq : Show Blocked State
[ 1513.486357]   task                        PC stack   pid father
----------------------------------------
